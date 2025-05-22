import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/market_data.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/screens/market/buy_tft.dart';
import 'package:threebotlogin/screens/market/order.dart';
import 'package:threebotlogin/widgets/market/wallet_selection.dart';
import 'package:threebotlogin/services/stellar_service.dart' as Stellar;

class OverviewWidget extends ConsumerStatefulWidget {
  const OverviewWidget({super.key});

  @override
  ConsumerState<OverviewWidget> createState() => _OverviewWidgetState();
}

class _OverviewWidgetState extends ConsumerState<OverviewWidget> {
  late Timer _timer;
  String lastUpdated = '--';
  Wallet? _selectedWallet;
  bool loading = true;
  bool failed = false;
  bool isLoadingWallets = false;
  bool loadingWalletsFailed = false;
  TftMarketData? marketData;

  @override
  void initState() {
    super.initState();
    _startPriceUpdater();
    _fetchMarketData();
    _checkWalletsListed();
  }

  Future<void> _checkWalletsListed() async {
    final walletsNotifierRef = ref.read(walletsNotifier.notifier);
    if (!walletsNotifierRef.isListed) {
      setState(() {
        isLoadingWallets = true;
        loadingWalletsFailed = false;
        _selectedWallet = null;
      });
      try {
        await walletsNotifierRef.list();
      } catch (e) {
        if (mounted) {
          setState(() {
            loadingWalletsFailed = true;
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoadingWallets = false;
          });
        }
      }
    }
  }

  Future<void> _retryLoadingWallets() async {
    setState(() {
      isLoadingWallets = true;
      loadingWalletsFailed = false;
      _selectedWallet = null;
    });

    final walletsNotifierRef = ref.read(walletsNotifier.notifier);

    try {
      await walletsNotifierRef.list();
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Wallets loaded successfully',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primaryContainer),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loadingWalletsFailed = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load wallets. Please check your connection.',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.errorContainer),
            ),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Theme.of(context).colorScheme.errorContainer,
              onPressed: () {
                _retryLoadingWallets();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingWallets = false;
        });
      }
    }
  }

  Future<TftMarketData?> _fetchMarketData() async {
    setState(() {
      loading = true;
      failed = false;
    });
    try {
      final data = await Stellar.fetchTftMarketData();
      if (data == null) {
        setState(() {
          failed = true;
          marketData = TftMarketData.empty();
        });
        logger.e('Error fetching market data: received null data');
        return null;
      }
      setState(() {
        marketData = data;
        failed = false;
      });
      lastUpdated = _formattedDateTime();
      return data;
    } catch (e) {
      setState(() {
        failed = true;
        marketData = TftMarketData.empty();
      });
      logger.e('Error fetching market data: $e');
      return null;
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _startPriceUpdater() {
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _fetchMarketData();
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
    final wallets = ref.watch(walletsNotifier);
    Widget mainWidget;
    if (loading || isLoadingWallets) {
      mainWidget = Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 15),
          Text(
            'Loading Market...',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold),
          ),
        ],
      ));
    } else if (failed || loadingWalletsFailed || marketData == null) {
      mainWidget = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: () {
                setState(() {
                  failed = false;
                  loading = true;
                });
                _fetchMarketData();
                _retryLoadingWallets();
              },
            ),
          ],
        ),
      );
    } else {
      mainWidget = RefreshIndicator(
          onRefresh: handleRefresh,
          child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.04,
                            vertical: 8),
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/usdc-icon.png',
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 30,
                              height: 30,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'USDC',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 50,
                              child: Center(
                                child: GestureDetector(
                                  onTap: null,
                                  child: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    child: Icon(
                                      Icons.arrow_forward,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Image.asset(
                              'assets/tf_chain.png',
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 30,
                              height: 30,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'TFT',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                          ],
                        )),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          marketData!.lastPrice.toStringAsFixed(7),
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          'USDC',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge!
                              .copyWith(
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
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _openWalletSelectionOverlay(wallets),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _selectedWallet?.name ??
                                            'Select Wallet',
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
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderWidget(
                                                        selectedWallet:
                                                            _selectedWallet!,
                                                      )));
                                        },
                                  child: Text(
                                    'My Orders',
                                    style: _selectedWallet == null
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant)
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
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
                              side: BorderSide(
                                  color: Theme.of(context).colorScheme.primary),
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
                                        .titleLarge!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSecondaryContainer),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildMarketColumn('Last Price',
                                                '${marketData!.lastPrice.toStringAsFixed(7)} USDC'),
                                            _buildMarketColumn('Last USD Price',
                                                '\$${marketData!.lastUsdPrice.toStringAsFixed(7)}'),
                                            _buildMarketColumn('24H Change',
                                                '${marketData!.change24h.toStringAsFixed(7)}%'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildMarketColumn('24H High',
                                                '${marketData!.high24h.toStringAsFixed(7)} USDC'),
                                            _buildMarketColumn('24H Low',
                                                '${marketData!.low24h.toStringAsFixed(7)} USDC'),
                                            _buildMarketColumn('24H Volume',
                                                '${marketData!.volume24h.toStringAsFixed(7)}K USDC'),
                                          ],
                                        ),
                                      ),
                                    ],
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Balance',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSecondaryContainer),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildMarketColumn(
                                              'TFT Balance',
                                              _selectedWallet
                                                  ?.stellarBalances['TFT']!),
                                          _buildMarketColumn(
                                              'USDC Balance',
                                              _selectedWallet
                                                  ?.stellarBalances['USDC']!),
                                          _buildMarketColumn(
                                              'XLM Balance',
                                              _selectedWallet
                                                  ?.stellarBalances['XLM']!),
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
                          child: Text(
                            'Buy TFT',
                            style: _selectedWallet == null
                                ? Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant)
                                : Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
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
              ]));
    }
    return mainWidget;
  }

  Future<void> handleRefresh() async {
    try {
      setState(() {
        loading = true;
        failed = false;
      });

      final marketData = await _fetchMarketData();
      if (!mounted) return;

      setState(() {
        this.marketData = marketData;
        lastUpdated = _formattedDateTime();
        failed = false;
      });
    } catch (e) {
      setState(() {
        failed = true;
      });
      logger.i('Error fetching price: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
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

  _openWalletSelectionOverlay(List<Wallet> wallets) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (context) {
        final filteredWallets = wallets
            .where((wallet) =>
                double.parse(wallet.stellarBalances['TFT']!) >= 0 &&
                double.parse(wallet.stellarBalances['USDC']!) >= 0)
            .toList();

        if (filteredWallets.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'No Wallets Available',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
                const SizedBox(height: 12),
                Text(
                  'No wallets with TFT and USDC assets found.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        }
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
