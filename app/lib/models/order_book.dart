class OrderBook {
  final String base;
  final String counter;
  final List<OrderOffer> bids;
  final List<OrderOffer> asks;

  OrderBook({
    required this.base,
    required this.counter,
    required this.bids,
    required this.asks,
  });

  factory OrderBook.fromJson(Map<String, dynamic> json) {
    return OrderBook(
      base: json['base'],
      counter: json['counter'],
      bids: (json['bids'] as List<dynamic>)
          .map((e) => OrderOffer.fromJson(e))
          .toList(),
      asks: (json['asks'] as List<dynamic>)
          .map((e) => OrderOffer.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base': base,
      'counter': counter,
      'bids': bids.map((e) => e.toJson()).toList(),
      'asks': asks.map((e) => e.toJson()).toList(),
    };
  }
}

class OrderOffer {
  final String amount;
  final String price;
  final PriceR priceR;

  OrderOffer({
    required this.amount,
    required this.price,
    required this.priceR,
  });

  factory OrderOffer.fromJson(Map<String, dynamic> json) {
    return OrderOffer(
      amount: json['amount'],
      price: json['price'],
      priceR: PriceR.fromJson(json['price_r']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'price': price,
      'price_r': priceR.toJson(),
    };
  }
}

class PriceR {
  final int numerator;
  final int denominator;

  PriceR({
    required this.numerator,
    required this.denominator,
  });

  factory PriceR.fromJson(Map<String, dynamic> json) {
    return PriceR(
      numerator: json['n'],
      denominator: json['d'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'n': numerator,
      'd': denominator,
    };
  }
}

