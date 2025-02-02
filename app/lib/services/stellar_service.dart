import 'package:stellar_client/models/transaction.dart';
import 'package:stellar_client/models/vesting_account.dart';
import 'package:stellar_client/stellar_client.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:threebotlogin/helpers/logger.dart';

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

Future<void> createOrder(
  String secret,
  String sellingAssetCode,
  String buyingAssetCode,
  String amount,
  String price,
) async {
  final client = Client(NetworkType.PUBLIC, secret);
  try {
    await client.createOrder(
        sellingAssetCode: sellingAssetCode,
        buyingAssetCode: buyingAssetCode,
        amount: amount,
        price: price);
  } catch (e) {
    logger.e('Error creating order due to $e');
  }
}

Future<void> cancelOrder(
  String secret,
  String sellingAssetCode,
  String buyingAssetCode,
  String offerId,
) async {
  final client = Client(NetworkType.PUBLIC, secret);
  try {
    await client.cancelOrder(
      sellingAssetCode: sellingAssetCode,
      buyingAssetCode: buyingAssetCode,
      offerId: offerId,
    );
  } catch (e) {
    logger.e('Error cancelling order due to $e');
  }
}

Future<void> updateOrder(
  String secret,
  String sellingAssetCode,
  String buyingAssetCode,
  String amount,
  String price,
  String offerId,
) async {
  final client = Client(NetworkType.PUBLIC, secret);
  try {
    await client.updateOrder(
      sellingAssetCode: sellingAssetCode,
      buyingAssetCode: buyingAssetCode,
      amount: amount,
      price: price,
      offerId: offerId,
    );
  } catch (e) {
    logger.e('Error updating order due to $e');
  }
}

Future<Stream<OrderBookResponse>> getOrderBook(
  String secret,
  String sellingAssetCode,
  String buyingAssetCode,
) async {
  final client = Client(NetworkType.PUBLIC, secret);
  try {
    final orders = await client.getOrderBook(
        sellingAssetCode: sellingAssetCode, buyingAssetCode: buyingAssetCode);
    return orders;
  } catch (e) {
    logger.e('Error fetching order book due to $e');
    throw Exception('Error fetching order book');
  }
}

Future<List<OfferResponse>> listMyOffers(String secret) async {
  final client = Client(NetworkType.PUBLIC, secret);
  try {
    return await client.listMyOffers();
  } catch (e) {
    logger.e('Error fetching offers due to $e');
    throw Exception('Error fetching offers');
  }
}
