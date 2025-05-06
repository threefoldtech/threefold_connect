import 'dart:convert';
import 'dart:typed_data';

import 'package:stellar_client/models/transaction.dart';
import 'package:stellar_client/models/vesting_account.dart';
import 'package:stellar_client/stellar_client.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:http/http.dart' as http;

bool isValidStellarSecret(String seed) {
  try {
    StrKey.decodeStellarSecretSeed(seed);
    return true;
  } catch (e) {
    logger.e('Secret is invalid. $e');
  }
  return false;
}

bool isValidStellarAddress(String address) {
  try {
    StrKey.decodeStellarAccountId(address);
    return true;
  } catch (e) {
    logger.e('Address is invalid. $e');
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
    logger.i("Couldn't load the account balance due to $e");
  }
  return '-1';
}

Future<String> getBalance(String secret) async {
  final client = Client(NetworkType.PUBLIC, secret);
  return getBalanceByClient(client);
}

Stream<ITransaction> listTransactions(
    String secret, String? pagingToken, int limit) async* {
  final client = Client(NetworkType.PUBLIC, secret);

  await for (var response in client.getTransactions(
    assetCodeFilter: 'TFT',
    limit: limit,
    pagingToken: pagingToken,
  )) {
    yield response;
  }
}

Future<List<VestingAccount>?> listVestedAccounts(String secret) async {
  final client = Client(NetworkType.PUBLIC, secret);
  final accounts = await client.getVestingAccounts();
  return accounts;
}

Future<void> transfer(String secret, String dest, String amount,
    {String? memo, Uint8List? memoHash}) async {
  final client = Client(NetworkType.PUBLIC, secret);
  await client.transferThroughThreefoldService(
    destinationAddress: dest,
    amount: amount,
    currency: 'TFT',
    memoText: memo,
    memoHash: memoHash,
  );
}

Future<void> initialize(String secret) async {
  final client = Client(NetworkType.PUBLIC, secret);
  await client.activateThroughThreefoldService();
}

Future<String> getBalanceByAccountId(String accountId) async {
  try {
    final stellarBalances = await getBalanceByAccountID(
        network: NetworkType.PUBLIC, accountId: accountId);
    for (final balance in stellarBalances) {
      if (balance.assetCode == 'TFT') {
        if (double.parse(balance.balance) == 0) return '0';
        return balance.balance;
      }
    }
  } catch (e) {
    logger.i("Couldn't load the account balance due to $e");
  }
  return '-1';
}

Future<bool> activateThroughtThreefoldService(String secret) async {
  final client = Client(NetworkType.PUBLIC, secret);
  try {
    return await client.activateThroughThreefoldService();
  } catch (e) {
    logger.e(e);
    return false;
  }
}

Future<int> getTFTPriceFromXLM() async {
  const String baseUrl = 'https://horizon.stellar.org';
  const String counterAssetCode = 'TFT';
  const String counterAssetIssuer =
      'GBOVQKJYHXRR3DX6NOX2RRYFRCUMSADGDESTDNBDS6CDVLGVESRTAC47';
  final String requestUrl = '$baseUrl/trades?base_asset_type=native'
      '&counter_asset_type=credit_alphanum4'
      '&counter_asset_code=$counterAssetCode'
      '&counter_asset_issuer=$counterAssetIssuer'
      '&order=desc&limit=1';

  try {
    final response = await http.get(Uri.parse(requestUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> trades = data['_embedded']?['records'] ?? [];

      if (trades.isNotEmpty) {
        final trade = trades[0];
        final double baseAmount = double.parse(trade['base_amount']);
        final double counterAmount = double.parse(trade['counter_amount']);

        final double pricePerTFT = counterAmount / baseAmount;
        logger.i('Last traded price for 1 XLM in TFT: $pricePerTFT');
        final int roundedPrice = pricePerTFT.ceil();

        return roundedPrice;
      } else {
        logger.i('No recent trades found.');
        return 0;
      }
    } else {
      logger.e('Error fetching last traded price: ${response.statusCode}');
      throw Exception('Error getting price');
    }
  } catch (e) {
    logger.e('Error: $e');
    throw Exception('Error getting price');
  }
}
