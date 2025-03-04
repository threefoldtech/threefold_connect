import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/market_data.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/stellar_service.dart';
import 'package:threebotlogin/widgets/market/buy_tft.dart';

class OverviewWidget extends StatefulWidget {
  const OverviewWidget({super.key, required this.wallets});
  final List<PkidWallet> wallets;

  @override
  State<OverviewWidget> createState() => _OverviewWidgetState();
}

class _OverviewWidgetState extends State<OverviewWidget> {
  double? tftPrice;
  late Timer _timer;
  String lastUpdated = '--';
  PkidWallet? _selectedWallet;

  @override
  void initState() {
    super.initState();
    _fetchTFTPrice();
    _startPriceUpdater();
  }

  void _fetchTFTPrice() async {
    try {
      final price = await loadTFTPrice();
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

  List<DropdownMenuEntry<PkidWallet>> _buildDropdownMenuEntries() {
    return widget.wallets.map((wallet) {
      return DropdownMenuEntry<PkidWallet>(
        value: wallet,
        label: wallet.name,
        labelWidget: Text(wallet.name,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                )),
      );
    }).toList();
  }

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
          Text(
            tftPrice.toString(),
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
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
                  child: DropdownMenu(
                    menuHeight: MediaQuery.sizeOf(context).height * 0.3,
                    enableFilter: true,
                    width: 180,
                    textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    trailingIcon: const Icon(
                      CupertinoIcons.chevron_down,
                      size: 16,
                    ),
                    selectedTrailingIcon: const Icon(
                      CupertinoIcons.chevron_up,
                      size: 16,
                    ),
                    inputDecorationTheme: InputDecorationTheme(
                      border: InputBorder.none,
                      isDense: true,
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      enabledBorder: UnderlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4)),
                        borderSide: BorderSide(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          width: 6.0,
                        ),
                      ),
                    ),
                    menuStyle: MenuStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                    ),
                    label: Text(
                      'Select Wallet',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                    ),
                    dropdownMenuEntries: _buildDropdownMenuEntries(),
                    onSelected: (PkidWallet? value) {
                      if (value != null) {
                        setState(() {
                          _selectedWallet = value;
                        });
                      }
                    },
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
                                builder: (context) => const BuyTFTWidget()));
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: Text(
                      'My Orders',
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
          ),
        ),
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
                                child:
                                    CircularProgressIndicator()); 
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
                                    _buildMarketColumn(
                                        'Last Price', marketData.lastPrice),
                                    _buildMarketColumn(
                                        '24H Volume', marketData.volume24h),
                                    _buildMarketColumn(
                                        '24H Low', marketData.low24h),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    
                                    _buildMarketColumn(
                                        '24H High', marketData.high24h),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      )
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
                              _buildMarketColumn('Total Balance (TFT)', 0.0126),
                              _buildMarketColumn(
                                  'Total Balance (USDC)', 0.5678),
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
                          builder: (context) => const BuyTFTWidget()));
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

  Widget _buildMarketColumn(String title, double? value) {
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
          Text(value != null ? value.toStringAsFixed(6) : 'Loading...',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer)),
        ],
      ),
    );
  }
}
