import 'package:stellar_client/models/transaction.dart';
import 'package:stellar_client/models/vesting_account.dart';
import 'package:stellar_client/stellar_client.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

bool isValidStellarSecret(String seed) {
  try {
    StrKey.decodeStellarSecretSeed(seed);
    return true;
  } catch (e) {
    print('Secret is invalid. $e');
  }
  return false;
}

bool isValidStellarAddress(String address) {
  try {
    StrKey.decodeStellarAccountId(address);
    return true;
  } catch (e) {
    print('Address is invalid. $e');
  }
  return false;
}

Future<String> getBalanceByClient(Client client) async {
  try {
    final stellarBalances = await client.getBalance();
    for (final balance in stellarBalances) {
      if (balance.assetCode == 'TFT') {
        if (double.parse(balance.balance) == 0) return '0';
        return balance.balance;
      }
    }
  } catch (e) {
    print("Couldn't load the account balance.");
  }
  return '-1';
}

Future<String> getBalance(String secret) async {
  final client = Client(NetworkType.PUBLIC, secret);
  return getBalanceByClient(client);
}

Future<List<ITransaction>> listTransactions(String secret) async {
  final client = Client(NetworkType.PUBLIC, secret);
  final transactions = await client.getTransactions(assetCodeFilter: 'TFT');
  return transactions;
}

Future<List<VestingAccount>?> listVestedAccounts(String secret) async {
  final client = Client(NetworkType.PUBLIC, secret);
  final accounts = await client.getVestingAccounts();
  return accounts;
}

Future<void> transfer(
    String secret, String dest, String amount, String memo) async {
  final client = Client(NetworkType.PUBLIC, secret);
  await client.transferThroughThreefoldService(
    destinationAddress: dest,
    amount: amount,
    currency: 'TFT',
    memoText: memo,
  );
}

Future<void> initialize(String secret) async {
  final client = Client(NetworkType.PUBLIC, secret);
  await client.activateThroughThreefoldService();
}
