class TftMarketData {
  final double lastPrice;
  final double lastUsdPrice;
  final double high24h;
  final double low24h;

  TftMarketData({
    required this.lastPrice,
    required this.lastUsdPrice,
    required this.high24h,
    required this.low24h,
  });

  factory TftMarketData.fromTrades(List<dynamic> trades) {
    if (trades.isEmpty) return TftMarketData.empty();

    final latestTrade = trades.first;
    final double lastUsdcPrice = double.parse(latestTrade['base_amount']) /
        double.parse(latestTrade['counter_amount']);
    final double lastPrice = 1 / lastUsdcPrice;

    double high24h = lastUsdcPrice;
    double low24h = lastUsdcPrice;

    for (var trade in trades) {
      double usdcPrice = double.parse(trade['base_amount']) /
          double.parse(trade['counter_amount']);
      high24h = usdcPrice > high24h ? usdcPrice : high24h;
      low24h = usdcPrice < low24h ? usdcPrice : low24h;
    }

    return TftMarketData(
      lastPrice: 1 / lastPrice,
      lastUsdPrice: lastUsdcPrice,
      high24h: high24h,
      low24h: low24h,
    );
  }

  factory TftMarketData.empty() {
    return TftMarketData(
      lastPrice: 0,
      lastUsdPrice: 0,
      high24h: 0,
      low24h: 0,
    );
  }
}
