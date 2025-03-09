import 'package:flutter/material.dart';

class OrderWidget extends StatefulWidget {
  const OrderWidget({super.key});

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> with SingleTickerProviderStateMixin {
    late final TabController _tabController;

    @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }


   @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Order')),
        body: DefaultTabController(
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
                            // OverviewWidget(wallets: wallets),
                            // const OrderbookWidget(
                            //   secret:
                            //       'SDVA4BNOZBEPUOUTEW72EAFAZGUCWXLHRKNQWHMPD3CUJGUAWZGJYJW3',
                            // ),
                          ],
                        ),
                      
                    
                  
                )
              ),
            ),
          ],
        ),
      )
    );
  }
}