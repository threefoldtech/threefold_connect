class TftMarketData {
  final double lastPrice;
  final double lastUsdPrice;
  final double change24h;
  final double high24h;
  final double low24h;
  final double volume24h;

  TftMarketData({
    required this.lastPrice,
    required this.lastUsdPrice,
    required this.change24h,
    required this.high24h,
    required this.low24h,
    required this.volume24h,
  });

  factory TftMarketData.fromTrades(List<dynamic> trades) {
    if (trades.isEmpty) return TftMarketData.empty();

    final latestTrade = trades.first;
    final double lastUsdcPrice = double.parse(latestTrade['base_amount']) /
        double.parse(latestTrade['counter_amount']);
    final double lastPrice = 1 / lastUsdcPrice;

    double high24h = lastUsdcPrice;
    double low24h = lastUsdcPrice;
    double volume24h = 0;

    final oldestTrade = trades.last;
    final double oldestUsdcPrice = double.parse(oldestTrade['base_amount']) /
        double.parse(oldestTrade['counter_amount']);

    for (var trade in trades) {
      double usdcPrice = double.parse(trade['base_amount']) /
          double.parse(trade['counter_amount']);
      high24h = usdcPrice > high24h ? usdcPrice : high24h;
      low24h = usdcPrice < low24h ? usdcPrice : low24h;
      volume24h += double.parse(trade['counter_amount']);
    }

    final double change24h =
        ((lastUsdcPrice - oldestUsdcPrice) / oldestUsdcPrice) * 100;

    return TftMarketData(
      lastPrice: 1 / lastPrice,
      lastUsdPrice: lastUsdcPrice,
      change24h: change24h,
      high24h: high24h,
      low24h: low24h,
      volume24h: volume24h / 1000,
    );
  }

  factory TftMarketData.empty() {
    return TftMarketData(
      lastPrice: 0,
      lastUsdPrice: 0,
      change24h: 0,
      high24h: 0,
      low24h: 0,
      volume24h: 0,
    );
  }
}
