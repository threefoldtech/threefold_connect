import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/offer.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/stellar_service.dart';
import 'package:threebotlogin/widgets/market/orders_notifier.dart';
import 'package:threebotlogin/widgets/market/orders_widget.dart';

class OrderWidget extends StatefulWidget {
  final Wallet selectedWallet;
  const OrderWidget({super.key, required this.selectedWallet});

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget>
    with SingleTickerProviderStateMixin {
  final List<Offer> activeOrders = [];
  final List<Offer> previousOrders = [];
  bool loading = true;
  late final TabController _tabController;

  Future<void> loadOrders() async {
    setState(() {
      loading = true;
    });

    try {
      final currentOrders =
          await getActiveOrders(widget.selectedWallet.stellarSecret);
      final ordersHistory =
          await getOrdersHistory(widget.selectedWallet.stellarSecret);
      if (activeOrders.isNotEmpty) activeOrders.clear();
      if (previousOrders.isNotEmpty) previousOrders.clear();
      final filteredActiveOrders = currentOrders.where(
        (order) => order.sellingAsset == 'USDC' && order.buyingAsset == 'TFT',
      );

      final filteredOrderHistory = ordersHistory.where(
        (order) => order.sellingAsset == 'USDC' && order.buyingAsset == 'TFT',
      );

      activeOrders.addAll(filteredActiveOrders);
      previousOrders.addAll(filteredOrderHistory);
    } catch (e) {
      logger.e('Failed to load orders due to $e');
      if (context.mounted) {
        final loadingOrdersFailure = SnackBar(
          content: Text(
            'Failed to load orders',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.errorContainer),
          ),
          duration: const Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(loadingOrdersFailure);
      }
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadOrders();
    _tabController = TabController(length: 2, vsync: this);
    OrderNotifier.orderUpdated.addListener(() {
      loadOrders();
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
              child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
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
                  )),
            ),
          ],
        ),
      );
    }
    return Scaffold(appBar: AppBar(title: const Text('Order')), body: content);
  }
}
