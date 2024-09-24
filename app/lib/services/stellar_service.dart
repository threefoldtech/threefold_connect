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

Future<String> getBalanceByClient(Client client) async {
  try {
    final stellarBalances = await client.getBalance();
    for (final balance in stellarBalances) {
      if (balance.assetCode == 'TFT') {
        return balance.balance;
      }
    }
  } catch (e) {
    print("Couldn't load the account balance.");
  }
  return '0';
}

Future<List<OperationResponse>> listTransactions(String secret) async {
  final client = Client(NetworkType.PUBLIC, secret);
  final transactions = await client.getTransactions(assetCodeFilter: 'TFT');
  print(transactions);
  return transactions;
}
