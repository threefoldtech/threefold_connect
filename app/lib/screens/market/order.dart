import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/offer.dart';
import 'package:threebotlogin/models/wallet.dart' as Wallet;
import 'package:threebotlogin/services/stellar_service.dart';
import 'package:threebotlogin/providers/orders_notifier.dart';
import 'package:threebotlogin/widgets/market/orders_widget.dart';

class OrderWidget extends StatefulWidget {
  final Wallet.Wallet selectedWallet;
  const OrderWidget({super.key, required this.selectedWallet});

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget>
    with SingleTickerProviderStateMixin {
  bool loading = true;
  bool failed = false;
  late final TabController _tabController;
  final List<Offer> activeOrders = [];
  final List<Offer> previousOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);

    loadOrders();
    OrderNotifier.orderUpdated.addListener(() {
      loadOrders();
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      logger.i('Tab changed to index: ${_tabController.index}');
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadOrders() async {
    _setLoadingState();

    try {
      final connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.none)) {
        _handleFailure(
          'No internet connection. Please check your network.',
        );
        return;
      }

      Asset sellingAsset =
          AssetTypeCreditAlphaNum4(usdcAssetCode, usdcAssetIssuer);
      Asset buyingAsset =
          AssetTypeCreditAlphaNum4(tftAssetCode, tftAssetIssuer);

      final currentOrders =
          await getActiveOrders(widget.selectedWallet.stellarSecret).timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          throw TimeoutException('Loading active orders timed out');
        },
      );
      final ordersHistory = await getOrdersHistory(
              widget.selectedWallet.stellarSecret, sellingAsset, buyingAsset)
          .timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          throw TimeoutException('Loading orders history timed out');
        },
      );

      if (activeOrders.isNotEmpty) activeOrders.clear();
      if (previousOrders.isNotEmpty) previousOrders.clear();
      final filteredActiveOrders = currentOrders.where((order) =>
          (order.sellingAsset == 'USDC' && order.buyingAsset == 'TFT'));

      activeOrders.addAll(filteredActiveOrders);
      previousOrders.addAll(ordersHistory);
    } on TimeoutException catch (e) {
      _handleFailure(
        'Loading orders timed out. Please check your network',
        error: e,
      );
    } catch (e) {
      _handleFailure(
        'Failed to load orders. Please try again.',
        error: e,
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _handleFailure(String userMessage, {Object? error}) {
    if (error != null) {
      logger.e('Load proposals failed', error: error);
    }

    if (mounted) {
      final errorSnackbar = SnackBar(
        content: Text(
          userMessage,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Theme.of(context).colorScheme.errorContainer),
        ),
        duration: const Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(errorSnackbar);
    }

    setState(() {
      loading = false;
      failed = true;
    });
  }

  void _setLoadingState() {
    setState(() {
      loading = true;
      failed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (loading) {
      content = Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 15),
          Text(
            'Loading Orders...',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold),
          ),
        ],
      ));
    } else if (failed) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: () {
                loadOrders();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    } else {
      content = DefaultTabController(
        length: 2,
        child: Column(
          children: [
            PreferredSize(
              preferredSize: const Size.fromHeight(10.0),
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).colorScheme.primary,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                  dividerColor: Theme.of(context).scaffoldBackgroundColor,
                  labelStyle: Theme.of(context).textTheme.titleLarge,
                  unselectedLabelStyle: Theme.of(context).textTheme.titleMedium,
                  tabs: const [
                    Tab(text: 'Active Order'),
                    Tab(text: 'Trade History'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  RefreshIndicator(
                      onRefresh: loadOrders,
                      child: OrdersWidget(
                        offers: activeOrders,
                        active: true,
                        selectedWallet: widget.selectedWallet,
                      )),
                  RefreshIndicator(
                      onRefresh: loadOrders,
                      child: OrdersWidget(
                        offers: previousOrders,
                        selectedWallet: widget.selectedWallet,
                      )),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(appBar: AppBar(title: const Text('Orders')), body: content);
  }
}
