class TftMarketData {
  final double lastPrice;
  final double volume24h;
  final double high24h;
  final double low24h;

  TftMarketData({
    required this.lastPrice,
    required this.volume24h,
    required this.high24h,
    required this.low24h,
  });

  factory TftMarketData.fromJson(Map<String, dynamic> json) {
    return TftMarketData(
      lastPrice: double.parse(json['close'] ?? '0'),
      volume24h: double.parse(json['base_volume'] ?? '0'),
      high24h: double.parse(json['high'] ?? '0'),
      low24h: double.parse(json['low'] ?? '0'),
    );
  }
}
