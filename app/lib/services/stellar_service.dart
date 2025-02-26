import 'package:stellar_client/models/transaction.dart';
import 'package:stellar_client/models/vesting_account.dart';
import 'package:stellar_client/stellar_client.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:threebotlogin/helpers/logger.dart';
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

Future<double> loadTFTPrice() async {
    const String srcCode = 'USDC';
    const String srcIssuer =
        'GA5ZSEJYB37JRC5AVCIA5MOP4RHTM335X2KGX3IHOJAPP5RE34K4KZVN';
    const String dstCode = 'TFT';
    const String dstIssuer =
        'GBOVQKJYHXRR3DX6NOX2RRYFRCUMSADGDESTDNBDS6CDVLGVESRTAC47';
    const String dstAmount = '1';

    final String requestUrl = 'https://horizon.stellar.org/paths/strict-receive'
        '?source_assets=$srcCode%3A$srcIssuer'
        '&destination_asset_type=credit_alphanum4'
        '&destination_asset_issuer=$dstIssuer'
        '&destination_asset_code=$dstCode'
        '&destination_amount=$dstAmount';

    try {
      final response = await http.get(Uri.parse(requestUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final records = data['_embedded']?['records'];

        if (records != null && records.isNotEmpty) {
          final price = records
              .map((r) => double.parse(r['source_amount']))
              .reduce((a, b) => a < b ? a : b);
          print('TFT Price in USDC: $price');
          return price;    
        } else {
          print('No price data available.');
          return 0;
        }
      } else {
        print('Error fetching price: ${response.statusCode}');
              throw Exception('Error gettung price');

      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error gettung price');
    }
  }