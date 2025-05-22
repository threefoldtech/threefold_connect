import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:threebotlogin/services/stellar_service.dart';

class Offer {
  final String id;
  final String seller;
  final String sellingAsset;
  final String buyingAsset;
  final String amount;
  final String price;
  final String lastModifiedTime;

  Offer({
    required this.id,
    required this.seller,
    required this.sellingAsset,
    required this.buyingAsset,
    required this.amount,
    required this.price,
    required this.lastModifiedTime,
  });

  factory Offer.fromOfferResponse(OfferResponse response) {
    return Offer(
      id: response.id,
      seller: response.seller,
      sellingAsset: getAssetName(response.selling),
      buyingAsset: getAssetName(response.buying),
      amount: response.amount,
      price: response.price,
      lastModifiedTime: response.lastModifiedTime,
    );
  }

  factory Offer.fromTradeResponse(TradeResponse response) {
    final bool userIsSeller =
        response.baseAccount == response.links.base.href.split('/').last;
    final String sellingAsset = userIsSeller
        ? _getAssetNameFromTrade(response.baseAssetType, response.baseAssetCode,
            response.baseAssetIssuer)
        : _getAssetNameFromTrade(response.counterAssetType,
            response.counterAssetCode, response.counterAssetIssuer);

    final String buyingAsset = userIsSeller
        ? _getAssetNameFromTrade(response.counterAssetType,
            response.counterAssetCode, response.counterAssetIssuer)
        : _getAssetNameFromTrade(response.baseAssetType, response.baseAssetCode,
            response.baseAssetIssuer);
    final String amount =
        userIsSeller ? response.baseAmount : response.counterAmount;

    String priceStr;
    try {
      Price priceObj = response.price;
      priceStr = (priceObj.numerator! / priceObj.denominator!).toString();
    } catch (e) {
      priceStr = '0';
    }

    return Offer(
      id: response.id,
      seller: userIsSeller ? response.baseAccount! : response.counterAccount!,
      sellingAsset: sellingAsset,
      buyingAsset: buyingAsset,
      amount: amount,
      price: priceStr,
      lastModifiedTime: response.ledgerCloseTime,
    );
  }

  static String _getAssetNameFromTrade(
      String type, String? code, String? issuer) {
    if (type == 'native') {
      return 'XLM';
    } else if (code != null && issuer != null) {
      return code;
    }
    return 'Unknown Asset';
  }
}
