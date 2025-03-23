import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

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
    return Offer(
      id: response.id,
      seller: response.baseAccount ?? 'Unknown',
      sellingAsset: _getAssetNameFromTrade(
        response.baseAssetType,
        response.baseAssetCode,
        response.baseAssetIssuer,
      ),
      buyingAsset: _getAssetNameFromTrade(
        response.counterAssetType,
        response.counterAssetCode,
        response.counterAssetIssuer,
      ),
      amount: response.baseAmount,
      price: response.price.numerator.toString() + '/' + response.price.denominator.toString(),
      lastModifiedTime: response.ledgerCloseTime,
    );
  }

  static String getAssetName(Asset asset) {
    if (asset is AssetTypeNative) {
      return 'XLM';
    } else if (asset is AssetTypeCreditAlphaNum) {
      return asset.code;
    }
    return 'Unknown Asset';
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
