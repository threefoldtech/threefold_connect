import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/locked_token.dart';

/// Production ThreeFold token services endpoint that stores the unlock
/// (pre-authorized) transactions for time-locked escrow accounts.
const String _unlockServiceUrl =
    'https://tokenservices.threefold.io/threefoldfoundation';

/// Asset codes we consider when looking for locked balances.
const List<String> _allowedAssetCodes = ['TFT', 'TFTA', 'FreeTFT'];

final StellarSDK _sdk = StellarSDK.PUBLIC;
final Network _network = Network.PUBLIC;

/// Discovers all escrow accounts that the wallet (identified by [stellarAddress])
/// is a signer of, and returns the locked balances together with their unlock
/// information.
Future<List<LockedToken>> getLockedTokens(String stellarAddress) async {
  logger.i('[LockedTokens] Looking up escrow accounts for $stellarAddress');
  final Page<AccountResponse> accounts =
      await _sdk.accounts.forSigner(stellarAddress).limit(200).execute();
  logger.i(
      '[LockedTokens] forSigner returned ${accounts.records.length} signed account(s)');

  final List<LockedToken> lockedTokens = [];
  for (final account in accounts.records) {
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
    logger.i(
        '[LockedTokens] Escrow ${account.accountId}: ${balance.balance} ${balance.assetCode}, '
        'unlockHash=${unlockHash ?? 'none'}');

    final detailed = await _getLockedTokenDetails(
      address: account.accountId,
      assetCode: balance.assetCode!,
      assetIssuer: balance.assetIssuer!,
      amount: double.parse(balance.balance),
      unlockHash: unlockHash,
    );
    if (detailed != null) lockedTokens.add(detailed);
  }

  logger.i('[LockedTokens] Found ${lockedTokens.length} locked balance(s)');
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
      canBeUnlocked: minTime != null && nowSeconds >= minTime,
    );
  } catch (e) {
    logger.e('Could not fetch unlock transaction for $address: $e');
    return null;
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
  final String xdr = data['transaction_xdr'];
  final tx = AbstractTransaction.fromEnvelopeXdrString(xdr);
  if (tx is! Transaction) {
    throw Exception('Unexpected unlock transaction type');
  }
  return tx;
}

/// Unlocks the provided [lockedTokens] for the wallet owning [secret].
///
/// Returns the list of tokens that were successfully unlocked. Tokens whose
/// time-lock has not expired yet, or that fail to submit, are skipped.
Future<List<LockedToken>> unlockTokens(
    List<LockedToken> lockedTokens, String secret) async {
  final keyPair = KeyPair.fromSecretSeed(secret);
  final List<LockedToken> unlocked = [];

  for (final lockedToken in lockedTokens) {
    try {
      // Step 1: submit the pre-authorized unlock transaction (if still locked).
      if (lockedToken.unlockHash != null) {
        final submitted = await _submitUnlockTransaction(lockedToken);
        if (!submitted) continue;
        lockedToken.unlockHash = null;
      }

      // Step 2: drain the escrow account into the main account.
      await _transferLockedBalance(keyPair, lockedToken);
      unlocked.add(lockedToken);
    } catch (e) {
      logger.e('Failed to unlock tokens from ${lockedToken.address}: $e');
      continue;
    }
  }

  return unlocked;
}

/// Submits the stored unlock transaction to the Stellar network. Returns `false`
/// when the time-lock has not expired yet.
Future<bool> _submitUnlockTransaction(LockedToken lockedToken) async {
  final unlockTx = await _fetchUnlockTransaction(lockedToken.unlockHash!);
  final minTime = unlockTx.preconditions?.timeBounds?.minTime;
  final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  if (minTime == null || nowSeconds < minTime) {
    logger.i('Tokens from ${lockedToken.address} cannot be unlocked yet');
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

  final builder = TransactionBuilder(account);

  if (lockedToken.amount > 0) {
    builder.addOperation(
      PaymentOperationBuilder(
              keyPair.accountId, asset, lockedToken.amount.toStringAsFixed(7))
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
