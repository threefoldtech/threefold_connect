import 'dart:async';

import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/market_data.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/stellar_service.dart';
import 'package:threebotlogin/widgets/market/buy_tft.dart';
import 'package:threebotlogin/widgets/market/order.dart';
import 'package:threebotlogin/widgets/market/wallet_selection.dart';

class OverviewWidget extends StatefulWidget {
  const OverviewWidget({super.key, required this.wallets});
  final List<Wallet> wallets;

  @override
  State<OverviewWidget> createState() => _OverviewWidgetState();
}

class _OverviewWidgetState extends State<OverviewWidget> {
  double? tftPrice;
  late Timer _timer;
  String lastUpdated = '--';
  Wallet? _selectedWallet;

  @override
  void initState() {
    super.initState();
    _fetchTFTPrice();
    _startPriceUpdater();
  }

  void _fetchTFTPrice() async {
    try {
      final price = await getLastTradedTFTPrice();
      setState(() {
        tftPrice = price;
        lastUpdated = _formattedDateTime();
      });
    } catch (e) {
      logger.i('Error fetching price: $e');
    }
  }

  void _startPriceUpdater() {
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _fetchTFTPrice();
    });
  }

  String _formattedDateTime() {
    final now = DateTime.now();
    return '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)} '
        '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        if (tftPrice == null)
          const CircularProgressIndicator()
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                tftPrice!.toStringAsFixed(7),
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                'TFT',
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
        const SizedBox(height: 8),
        Text(
          'Last updated: $lastUpdated',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _openWalletSelectionOverlay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedWallet?.name ?? 'Select Wallet',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer),
                          ),
                          Icon(Icons.arrow_drop_down,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _selectedWallet == null
                          ? null
                          : () async {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => OrderWidget(
                                        selectedWallet: _selectedWallet!,
                                      )));
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'My Order',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
        SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Market Stats',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer),
                      ),
                      FutureBuilder<TftMarketData?>(
                        future: fetchTftMarketData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError || !snapshot.hasData) {
                            return const Center(
                                child: Text('No trade data available.'));
                          }

                          final marketData = snapshot.data!;

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMarketColumn('Last Price',
                                        '${marketData.lastPrice} TFT'),
                                    _buildMarketColumn('Last USD Price',
                                        '\$${marketData.lastUsdPrice}'),
                                    _buildMarketColumn('24H Change',
                                        '${marketData.change24h}%'),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMarketColumn('24H High',
                                        '${marketData.high24h} TFT'),
                                    _buildMarketColumn(
                                        '24H Low', '${marketData.low24h} TFT'),
                                    _buildMarketColumn('24H Volume',
                                        '${marketData.volume24h}K TFT'),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedWallet != null)
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assets Balances',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMarketColumn('Total Balance (TFT)',
                                  _selectedWallet!.stellarBalance),
                              _buildMarketColumn('Total Balance (USDC)',
                                  _selectedWallet!.usdcBalance),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 40,
            child: ElevatedButton(
              onPressed: _selectedWallet == null
                  ? null
                  : () async {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => BuyTFTWidget(
                                wallet: _selectedWallet!,
                                edit: false,
                              )));
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Text(
                'Buy TFT',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketColumn(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondaryContainer),
          ),
          const SizedBox(height: 4),
          Text(value ?? 'Loading...',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer)),
        ],
      ),
    );
  }

  void _openWalletSelectionOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (context) {
        final filteredWallets = widget.wallets
            .where((wallet) => wallet.stellarBalance != '-1')
            .toList();
        return WalletSelectionSheet(
          wallets: filteredWallets,
          selectedWallet: _selectedWallet,
          onWalletSelected: (Wallet wallet) {
            setState(() {
              _selectedWallet = wallet;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
