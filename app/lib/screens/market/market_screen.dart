import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:threebotlogin/screens/market/order_book.dart';
import 'package:threebotlogin/screens/market/overview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/models/wallet.dart';

class MarketPage extends ConsumerStatefulWidget {
  const MarketPage({super.key});

  @override
  ConsumerState<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends ConsumerState<MarketPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Wallet? _selectedWallet;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  void _onWalletSelected(Wallet wallet) {
    setState(() {
      _selectedWallet = wallet;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutDrawer(
      titleText: 'Market',
      content: DefaultTabController(
        length: 2,
        child: Column(children: [
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
                labelStyle: Theme.of(context).textTheme.titleMedium,
                unselectedLabelStyle: Theme.of(context).textTheme.titleMedium,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'OrderBook'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                OverviewWidget(
                  selectedWallet: _selectedWallet,
                  onWalletSelected: _onWalletSelected,
                ),
                const OrderbookWidget(),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
