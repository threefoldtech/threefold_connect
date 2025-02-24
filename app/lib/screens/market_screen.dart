import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:threebotlogin/widgets/market/order_book.dart';
import 'package:threebotlogin/widgets/market/overview.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage>
    with SingleTickerProviderStateMixin {
  bool loading = false;
  late final TabController _tabController;

  @override
  void initState() {
    loadPrice();
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> loadPrice() async {
    const String srcCode = "USDC";
    const String srcIssuer =
        "GA5ZSEJYB37JRC5AVCIA5MOP4RHTM335X2KGX3IHOJAPP5RE34K4KZVN";
    const String dstCode = "TFT";
    const String dstIssuer =
        "GBOVQKJYHXRR3DX6NOX2RRYFRCUMSADGDESTDNBDS6CDVLGVESRTAC47";
    const String dstAmount = "1"; // Get price for 1 TFT

    final String requestUrl = "https://horizon.stellar.org/paths/strict-receive"
        "?source_assets=$srcCode%3A$srcIssuer"
        "&destination_asset_type=credit_alphanum4"
        "&destination_asset_issuer=$dstIssuer"
        "&destination_asset_code=$dstCode"
        "&destination_amount=$dstAmount";

    try {
      final response = await http.get(Uri.parse(requestUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("HELOOOO Data");
        print(data);

        if (data['records'] != null && data['records'].isNotEmpty) {
          final String price = data['records'][0]['destination_amount'];
          print("TFT Price in USDC: $price");
        } else {
          print("No price data available.");
        }
      } else {
        print("Error fetching price: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
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
      ));
    } else {
      content = DefaultTabController(
        length: 2,
        child: Column(
          children: [
            PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
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
              child: TabBarView(
                controller: _tabController,
                children: const [
                  OverviewWidget(),
                  OrderbookWidget(),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return LayoutDrawer(titleText: 'Market', content: content);
  }
}
