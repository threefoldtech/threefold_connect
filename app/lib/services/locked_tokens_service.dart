import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/locked_token.dart';

/// Production ThreeFold token services endpoint that stores the unlock
/// (pre-authorized) transactions for time-locked escrow accounts.
const String _unlockServiceUrl =
    'https://tokenservices.threefold.io/threefoldfoundation';

/// Asset codes we consider when looking for locked balances. Restricted to
/// `TFT` only: the UI represents a single "Locked TFT" balance, and allowing a
/// second asset on an escrow would leave a trailing trustline that makes the
/// `AccountMerge` in [_transferLockedBalance] fail.
const List<String> _allowedAssetCodes = ['TFT'];

final StellarSDK _sdk = StellarSDK.PUBLIC;
final Network _network = Network.PUBLIC;

/// Discovers all escrow accounts that the wallet (identified by [stellarAddress])
/// is a signer of, and returns the locked balances together with their unlock
/// information.
Future<List<LockedToken>> getLockedTokens(String stellarAddress) async {
  logger.d('[LockedTokens] Looking up escrow accounts for $stellarAddress');

  // Discover every account the wallet signs, following Horizon pagination so
  // wallets signing more than one page of escrows are not silently truncated.
  final http.Client httpClient = http.Client();
  final List<AccountResponse> signedAccounts = [];
  Page<AccountResponse>? page =
      await _sdk.accounts.forSigner(stellarAddress).limit(200).execute();
  while (page != null && page.records.isNotEmpty) {
    signedAccounts.addAll(page.records);
    page = await page.getNextPage(httpClient);
  }
  logger.d(
      '[LockedTokens] forSigner returned ${signedAccounts.length} signed account(s)');

  // Resolve the unlock details for every escrow concurrently: each one may need
  // a token-service round-trip, and doing them serially would block the Assets
  // screen on the slowest escrow.
  final List<Future<LockedToken?>> pending = [];
  for (final account in signedAccounts) {
    // Skip the wallet's own account.
    if (account.accountId == stellarAddress) continue;
    // Skip vesting accounts, those are handled separately.
    if (account.data.keys.contains('tft-vesting')) continue;

    Balance? balance;
    for (final b in account.balances) {
      final amount = double.tryParse(b.balance) ?? 0;
      if (b.assetType != 'native' &&
          b.assetCode != null &&
          b.assetIssuer != null &&
          _allowedAssetCodes.contains(b.assetCode) &&
          amount > 0) {
        balance = b;
        break;
      }
    }
    if (balance == null) continue;

    String? unlockHash;
    for (final signer in account.signers) {
      if (signer.type == 'preauth_tx') {
        unlockHash = signer.key;
        break;
      }
    }
    logger.d(
        '[LockedTokens] Escrow ${account.accountId}: ${balance.balance} ${balance.assetCode}, '
        'unlockHash=${unlockHash ?? 'none'}');

    pending.add(_getLockedTokenDetails(
      address: account.accountId,
      assetCode: balance.assetCode!,
      assetIssuer: balance.assetIssuer!,
      amount: double.parse(balance.balance),
      unlockHash: unlockHash,
    ));
  }

  final lockedTokens =
      (await Future.wait(pending)).whereType<LockedToken>().toList();

  logger.d('[LockedTokens] Found ${lockedTokens.length} locked balance(s)');
  return lockedTokens;
}

/// Builds a [LockedToken] for a single escrow account, resolving the unlock
/// time from the stored unlock transaction (if any).
Future<LockedToken?> _getLockedTokenDetails({
  required String address,
  required String assetCode,
  required String assetIssuer,
  required double amount,
  required String? unlockHash,
}) async {
  // No pre-auth signer means the funds can be claimed immediately.
  if (unlockHash == null) {
    return LockedToken(
      address: address,
      assetCode: assetCode,
      assetIssuer: assetIssuer,
      amount: amount,
      unlockHash: null,
      unlockFrom: null,
      canBeUnlocked: true,
    );
  }

  try {
    final unlockTx = await _fetchUnlockTransaction(unlockHash);
    final minTime = unlockTx.preconditions?.timeBounds?.minTime;
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return LockedToken(
      address: address,
      assetCode: assetCode,
      assetIssuer: assetIssuer,
      amount: amount,
      unlockHash: unlockHash,
      unlockFrom: minTime,
      // No lower time bound means the unlock tx is claimable immediately.
      canBeUnlocked: minTime == null || nowSeconds >= minTime,
    );
  } catch (e) {
    logger.e('Could not fetch unlock transaction for $address: $e');
    // A transient token-service failure must not make a real locked balance
    // disappear from the list. Surface it as locked with an unknown unlock
    // time instead of dropping it; the unlock button stays disabled.
    return LockedToken(
      address: address,
      assetCode: assetCode,
      assetIssuer: assetIssuer,
      amount: amount,
      unlockHash: unlockHash,
      unlockFrom: null,
      canBeUnlocked: false,
    );
  }
}

/// Fetches the stored unlock (pre-authorized) transaction for [unlockHash] from
/// the ThreeFold unlock service and parses it from XDR.
Future<Transaction> _fetchUnlockTransaction(String unlockHash) async {
  final response = await http.post(
    Uri.parse('$_unlockServiceUrl/unlock_service/get_unlockhash_transaction'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'args': {'unlockhash': unlockHash}
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(
        'Unlock service returned ${response.statusCode}: ${response.body}');
  }

  final data = jsonDecode(response.body);
  final xdr = data['transaction_xdr'];
  if (xdr is! String || xdr.isEmpty) {
    throw Exception('Unlock service response missing transaction_xdr');
  }
  final tx = AbstractTransaction.fromEnvelopeXdrString(xdr);
  if (tx is! Transaction) {
    throw Exception('Unexpected unlock transaction type');
  }
  return tx;
}

/// The per-escrow outcome of an [unlockTokens] attempt.
enum UnlockOutcome {
  /// The escrow was unlocked and fully drained into the main wallet.
  unlocked,

  /// The time-lock has not expired yet; nothing was submitted on-chain.
  notYet,

  /// The pre-authorized unlock was submitted (so the escrow is unlocked
  /// on-chain) but the follow-up drain transaction failed. The funds are not
  /// lost — retrying will claim them, since the escrow now has no time-lock.
  unlockedButTransferFailed,

  /// The unlock could not even be submitted; nothing changed on-chain.
  failed,
}

/// The result of attempting to unlock a single [LockedToken].
class UnlockResult {
  UnlockResult(this.token, this.outcome);

  final LockedToken token;
  final UnlockOutcome outcome;
}

/// Unlocks the provided [lockedTokens] for the wallet owning [secret].
///
/// Returns one [UnlockResult] per input token describing what happened. The
/// unlock is a two-step, non-atomic process: submitting the pre-authorized
/// transaction (step 1) is irreversible and consumes the escrow's `preauth_tx`
/// signer, after which the balance still has to be drained (step 2). When step
/// 2 fails the escrow is left unlocked-but-undrained — reported distinctly as
/// [UnlockOutcome.unlockedButTransferFailed] so the UI can tell the user to
/// retry to claim, rather than reporting an outright failure.
Future<List<UnlockResult>> unlockTokens(
    List<LockedToken> lockedTokens, String secret) async {
  final keyPair = KeyPair.fromSecretSeed(secret);
  final List<UnlockResult> results = [];

  for (final lockedToken in lockedTokens) {
    // Step 1: submit the pre-authorized unlock transaction (if still locked).
    if (lockedToken.unlockHash != null) {
      bool submitted;
      try {
        submitted = await _submitUnlockTransaction(lockedToken);
      } catch (e) {
        logger.e('Failed to submit unlock tx for ${lockedToken.address}: $e');
        results.add(UnlockResult(lockedToken, UnlockOutcome.failed));
        continue;
      }
      if (!submitted) {
        results.add(UnlockResult(lockedToken, UnlockOutcome.notYet));
        continue;
      }
      // The pre-auth signer is now consumed: the escrow is unlocked on-chain.
      lockedToken.unlockHash = null;
    }

    // Step 2: drain the escrow account into the main account. A failure here
    // leaves the escrow unlocked but undrained; a later retry will claim it.
    try {
      await _transferLockedBalance(keyPair, lockedToken);
      results.add(UnlockResult(lockedToken, UnlockOutcome.unlocked));
    } catch (e) {
      logger.e('Failed to transfer balance from ${lockedToken.address}: $e');
      results
          .add(UnlockResult(lockedToken, UnlockOutcome.unlockedButTransferFailed));
    }
  }

  return results;
}

/// Submits the stored unlock transaction to the Stellar network. Returns `false`
/// when the time-lock has not expired yet.
Future<bool> _submitUnlockTransaction(LockedToken lockedToken) async {
  final unlockTx = await _fetchUnlockTransaction(lockedToken.unlockHash!);
  final minTime = unlockTx.preconditions?.timeBounds?.minTime;
  final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  // A null lower bound means it is claimable immediately; only block when a
  // time-lock exists and has not expired yet.
  if (minTime != null && nowSeconds < minTime) {
    logger.d('Tokens from ${lockedToken.address} cannot be unlocked yet');
    return false;
  }

  final response = await _sdk.submitTransaction(unlockTx);
  if (!response.success) {
    throw Exception('Failed to submit unlock transaction');
  }
  return true;
}

/// Transfers the locked balance from the escrow account back to the main
/// account: pays out the balance, removes the trustline and merges the escrow
/// account. All operations are sourced from the escrow account and signed by
/// the main keypair (which is an authorized signer on the escrow account).
Future<void> _transferLockedBalance(
    KeyPair keyPair, LockedToken lockedToken) async {
  final asset = Asset.createNonNativeAsset(
      lockedToken.assetCode, lockedToken.assetIssuer);
  final account = await _sdk.accounts.account(keyPair.accountId);

  // Read the exact balance string straight from the escrow at drain time.
  // Stellar amounts are 7-dp fixed point and a `double` only represents every
  // stroop exactly below ~900M TFT; re-serializing the listed `double` could
  // leave dust (ChangeTrust('0') fails) or overpay (op_underfunded). Using the
  // live string keeps the payout stroop-exact so the account can be merged.
  final escrow = await _sdk.accounts.account(lockedToken.address);
  String? balanceString;
  for (final b in escrow.balances) {
    if (b.assetType != 'native' &&
        b.assetCode == lockedToken.assetCode &&
        b.assetIssuer == lockedToken.assetIssuer) {
      balanceString = b.balance;
      break;
    }
  }

  final builder = TransactionBuilder(account);

  if (balanceString != null && (double.tryParse(balanceString) ?? 0) > 0) {
    builder.addOperation(
      PaymentOperationBuilder(keyPair.accountId, asset, balanceString)
          .setSourceAccount(lockedToken.address)
          .build(),
    );
  }

  builder.addOperation(
    ChangeTrustOperationBuilder(asset, '0')
        .setSourceAccount(lockedToken.address)
        .build(),
  );

  builder.addOperation(
    AccountMergeOperationBuilder(keyPair.accountId)
        .setSourceAccount(lockedToken.address)
        .build(),
  );

  final transaction = builder.build();
  transaction.sign(keyPair, _network);

  final response = await _sdk.submitTransaction(transaction);
  if (!response.success) {
    throw Exception('Failed to transfer locked balance');
  }
}
