import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:threebotlogin/widgets/market/order_book.dart';
import 'package:threebotlogin/widgets/market/overview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketPage extends ConsumerStatefulWidget {
  const MarketPage({super.key});

  @override
  ConsumerState<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends ConsumerState<MarketPage>
    with SingleTickerProviderStateMixin {
  // TODO: handle loading
  bool loading = false;
  late final TabController _tabController;
  List<Wallet> wallets = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getWallets();
  }

    void getWallets() async {
    try {
      setState(() {
        loading = true;
      });
      await ref.read(walletsNotifier.notifier).list();
      wallets = ref.read(walletsNotifier);
    } catch (e) {
      throw Exception('Failed to get wallets due to $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
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
              'Loading Market...',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold),
            ),
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
                    Tab(text: 'Overview'),
                    Tab(text: 'OrderBook'),
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
                            OverviewWidget(wallets: wallets),
                            const OrderbookWidget(
                              secret:
                                  'SDVA4BNOZBEPUOUTEW72EAFAZGUCWXLHRKNQWHMPD3CUJGUAWZGJYJW3',
                            ),
                          ],
                        ),
                      
                    
                  
                )
              ),
            ),
          ],
        ),
      );
    }
    return LayoutDrawer(titleText: 'Market', content: content);
  }
}
