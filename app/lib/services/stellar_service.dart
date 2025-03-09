import 'package:stellar_client/models/transaction.dart';
import 'package:stellar_client/models/vesting_account.dart';
import 'package:stellar_client/stellar_client.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/market_data.dart';
import 'package:threebotlogin/models/order_book.dart';
import 'dart:convert';
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

Future<List<ITransaction>> listTransactions(
    String secret, int offset, int limit) async {
  final client = Client(NetworkType.PUBLIC, secret);
  return await client.getTransactions(
      assetCodeFilter: 'TFT', limit: limit, offset: offset);
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

Future<Stream<OrderBook>> getOrderBook(
    String secret, String sellingAssetCode, String buyingAssetCode) async {
  final client = Client(NetworkType.PUBLIC, secret);
  final stream = await client.getOrderBook(
      sellingAssetCode: sellingAssetCode, buyingAssetCode: buyingAssetCode);

  return stream.map((orderBookResponse) {
    return OrderBook(
      base: orderBookResponse.base.toString(),
      counter: orderBookResponse.counter.toString(),
      bids: orderBookResponse.bids
          .map((offer) => OrderOffer(
                amount: offer.amount,
                price: offer.price,
                priceR: PriceR(
                  numerator: offer.priceR.numerator!,
                  denominator: offer.priceR.denominator!,
                ),
              ))
          .toList(),
      asks: orderBookResponse.asks
          .map((offer) => OrderOffer(
                amount: offer.amount,
                price: offer.price,
                priceR: PriceR(
                  numerator: offer.priceR.numerator!,
                  denominator: offer.priceR.denominator!,
                ),
              ))
          .toList(),
    );
  });
}

Future<double> getLastTradedTFTPrice() async {
  const String baseUrl = 'https://horizon.stellar.org';
  const String baseAssetCode = 'USDC';
  const String baseAssetIssuer =
      'GA5ZSEJYB37JRC5AVCIA5MOP4RHTM335X2KGX3IHOJAPP5RE34K4KZVN';
  const String counterAssetCode = 'TFT';
  const String counterAssetIssuer =
      'GBOVQKJYHXRR3DX6NOX2RRYFRCUMSADGDESTDNBDS6CDVLGVESRTAC47';

  final String requestUrl = '$baseUrl/trades?base_asset_type=credit_alphanum4'
      '&base_asset_code=$baseAssetCode'
      '&base_asset_issuer=$baseAssetIssuer'
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

        final double pricePerUSDC = counterAmount / baseAmount;
        print('Last traded price for 1 USDC in TFT: $pricePerUSDC');
        return pricePerUSDC;
      } else {
        print('No recent trades found.');
        return 0;
      }
    } else {
      print('Error fetching last traded price: ${response.statusCode}');
      throw Exception('Error getting price');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Error getting price');
  }
}

Future<TftMarketData?> fetchTftMarketData() async {
  final url = Uri.parse('https://horizon.stellar.org/trades?'
      'base_asset_type=credit_alphanum4&base_asset_code=TFT&base_asset_issuer=GBOVQKJYHXRR3DX6NOX2RRYFRCUMSADGDESTDNBDS6CDVLGVESRTAC47'
      '&counter_asset_type=credit_alphanum4&counter_asset_code=USDC&counter_asset_issuer=GA5ZSEJYB37JRC5AVCIA5MOP4RHTM335X2KGX3IHOJAPP5RE34K4KZVN'
      '&order=desc'
      '&limit=200');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> trades = data['_embedded']?['records'] ?? [];

      if (trades.isNotEmpty) {
        return TftMarketData.fromTrades(trades);
      }
    }

    print("Error: No trade data found.");
  } catch (e) {
    print("Error fetching market data: $e");
  }

  return null;
}
