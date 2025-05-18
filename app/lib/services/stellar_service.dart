import 'dart:convert';
import 'dart:typed_data';

import 'package:stellar_client/models/transaction.dart';
import 'package:stellar_client/models/vesting_account.dart';
import 'package:stellar_client/stellar_client.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/market_data.dart';
import 'package:threebotlogin/models/offer.dart';
import 'package:threebotlogin/models/order_book.dart';
import 'package:http/http.dart' as http;

const String tftAssetCode = 'TFT';
const String tftAssetIssuer =
    'GBOVQKJYHXRR3DX6NOX2RRYFRCUMSADGDESTDNBDS6CDVLGVESRTAC47';
const String usdcAssetCode = 'USDC';
const String usdcAssetIssuer =
    'GA5ZSEJYB37JRC5AVCIA5MOP4RHTM335X2KGX3IHOJAPP5RE34K4KZVN';
const horizonUrl = 'https://horizon.stellar.org';

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

Future<Map<String, String>> getBalanceByClient(Client client) async {
  try {
    final stellarBalances = await client.getBalance();
    final balances = <String, String>{'TFT': '-1', 'USDC': '-1', 'XLM': '-1'};

    for (final balance in stellarBalances) {
      if (balance.assetCode == 'TFT' ||
          balance.assetCode == 'USDC' ||
          balance.assetCode == 'XLM') {
        balances[balance.assetCode] =
            double.parse(balance.balance) == 0 ? '0' : balance.balance;
      }
    }
    return balances;
  } catch (e) {
    logger.i("Couldn't load the account balance due to $e");
    return {'TFT': '-2', 'USDC': '-2', 'XLM': '-2'};
  }
}

Future<String> getBalance(String secret) async {
  final client = Client(NetworkType.PUBLIC, secret);
  final balances = await getBalanceByClient(client);
  return balances['TFT'] ?? '-1';
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

Future<bool> initialize(String secret) async {
  final client = Client(NetworkType.PUBLIC, secret);
  return await client.activateThroughThreefoldService();
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
    return '-2';
  }
  return '-1';
}

Future<int> getTFTPriceFromXLM() async {
  final String requestUrl = '$horizonUrl/trades?base_asset_type=native'
      '&counter_asset_type=credit_alphanum4'
      '&counter_asset_code=$tftAssetCode'
      '&counter_asset_issuer=$tftAssetIssuer'
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

Future<bool> addTFTTrustline(String secret, String assetCode) async {
  final client = Client(NetworkType.PUBLIC, secret);
  return await client.addTrustLineThroughThreefoldService(assetCode);
}

Future<Stream<OrderBook>> listOrderBook(
    Asset sellingAsset, Asset buyingAsset) async {
  final stream = await getOrderBook(
      horizonUrl: horizonUrl,
      sellingAsset: sellingAsset,
      buyingAsset: buyingAsset);

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
  final String requestUrl =
      '$horizonUrl/trades?base_asset_type=credit_alphanum4'
      '&base_asset_code=$usdcAssetCode'
      '&base_asset_issuer=$usdcAssetIssuer'
      '&counter_asset_type=credit_alphanum4'
      '&counter_asset_code=$tftAssetCode'
      '&counter_asset_issuer=$tftAssetIssuer'
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

        if (baseAmount == 0 || baseAmount.isNaN) {
          logger.e('Invalid base amount: $baseAmount');
          return 0;
        }

        final double pricePerUSDC = counterAmount / baseAmount;
        if (pricePerUSDC.isInfinite || pricePerUSDC.isNaN) {
          logger.e('Invalid price calculation: $pricePerUSDC');
          return 0;
        }
        return 1 / pricePerUSDC;
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

Future<TftMarketData?> fetchTftMarketData() async {
  final url = Uri.parse('$horizonUrl/trades?'
      'base_asset_type=credit_alphanum4&base_asset_code=$usdcAssetCode&base_asset_issuer=$usdcAssetIssuer'
      '&counter_asset_type=credit_alphanum4&counter_asset_code=$tftAssetCode&counter_asset_issuer=$tftAssetIssuer'
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

    logger.i('Error: No trade data found.');
  } catch (e) {
    logger.e('Error fetching market data: $e');
  }

  return null;
}

Future<List<Offer>> getActiveOrders(String secret) async {
  final client = Client(NetworkType.PUBLIC, secret);
  final orders = await client.listMyOffers();
  return orders.map((order) => Offer.fromOfferResponse(order)).toList();
}

Future<List<Offer>> getOrdersHistory(
    String secret, Asset sellingAsset, Asset buyingAsset) async {
  final client = Client(NetworkType.PUBLIC, secret);
  final orders = await getTradingHistory(
      network: NetworkType.PUBLIC,
      accountId: client.accountId,
      baseAsset: sellingAsset,
      counterAsset: buyingAsset);
  return orders.map((order) => Offer.fromTradeResponse(order)).toList();
}

Future<bool> createOrder(String secret, String sellingAssetCode,
    String buyingAssetCode, String amount, String price) async {
  final client = Client(NetworkType.PUBLIC, secret);
  return await client.createOrder(
      sellingAssetCode: sellingAssetCode,
      buyingAssetCode: buyingAssetCode,
      amount: amount,
      price: price);
}

Future<bool> cancelOrder(String secret, String offerID) async {
  final client = Client(NetworkType.PUBLIC, secret);
  return await client.cancelOrder(offerId: offerID);
}

Future<bool> updateOrder(
    String secret, String amount, String price, String offerID) async {
  final client = Client(NetworkType.PUBLIC, secret);
  return await client.updateOrder(
      amount: amount, price: price, offerId: offerID);
}
