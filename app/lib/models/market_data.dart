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
    final double lastPrice =
        double.parse(latestTrade['base_amount']) / double.parse(latestTrade['counter_amount']);
    final double lastUsdPrice = 1 / lastPrice;

    double high24h = lastPrice;
    double low24h = lastPrice;
    double volume24h = 0;
    double firstPrice = lastPrice;

    for (var trade in trades) {
      double price = double.parse(trade['base_amount']) / double.parse(trade['counter_amount']);
      high24h = price > high24h ? price : high24h;
      low24h = price < low24h ? price : low24h;
      volume24h += double.parse(trade['counter_amount']);
      firstPrice = price;
    }

    final double change24h = ((lastPrice - firstPrice) / firstPrice) * 100;

    return TftMarketData(
      lastPrice: lastPrice,
      lastUsdPrice: lastUsdPrice,
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