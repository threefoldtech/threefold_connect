import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/services/gridproxy_service.dart';
import 'package:threebotlogin/services/tfchain_service.dart';
import 'package:threebotlogin/widgets/add_farm.dart';
import 'package:threebotlogin/widgets/farm_item.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';

class FarmScreen extends ConsumerStatefulWidget {
  const FarmScreen({super.key});

  @override
  ConsumerState<FarmScreen> createState() => _FarmScreenState();
}

class _FarmScreenState extends ConsumerState<FarmScreen>
    with SingleTickerProviderStateMixin {
  List<Farm> v3Farms = [];
  List<Farm> v4Farms = [];
  List<Wallet> wallets = [];
  bool loading = true;
  late bool areWalletsListed;
  late final TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    areWalletsListed =
        ref.read(walletsNotifier.notifier.select((n) => n.isListed));
    _listv3Farms();
    _listv3Farms();
  }

  Future<void> _listv3Farms() async {
    if (areWalletsListed) {
      await listv3Farms();
      return;
    }
    while (!areWalletsListed) {
      await Future.delayed(const Duration(seconds: 5));
      areWalletsListed =
          ref.read(walletsNotifier.notifier.select((n) => n.isListed));
      if (areWalletsListed) {
        await listv3Farms();
        break;
      }
    }
  }

  Future<void> listv3Farms() async {
    setState(() {
      loading = true;
    });
    try {
      v3Farms.clear();

      wallets = ref.read(walletsNotifier);
      final Map<int, Wallet> twinIdWallets = {};

      final twinIdFutures = wallets.map((w) async {
        final twinId = await getTwinId(w.tfchainSecret);
        if (twinId != 0) {
          twinIdWallets[twinId] = w;
        }
      }).toList();

      await Future.wait(twinIdFutures);

      final farmsList = await getFarmsByTwinIds(twinIdWallets.keys.toList());
      final farmFutures = farmsList.map((f) async {
        final seed = twinIdWallets[f.twinId]!.tfchainSecret;
        final walletName = twinIdWallets[f.twinId]!.name;
        final nodes = await getNodesByFarmId(f.farmID);
        v3Farms.add(Farm(
            name: f.name,
            walletAddress: f.stellarAddress,
            tfchainWalletSecret: seed,
            walletName: walletName,
            twinId: f.twinId,
            farmId: f.farmID,
            nodes: nodes.map((n) {
              return Node(
                nodeId: n.nodeId,
                status: NodeStatus.values.firstWhere((e) =>
                    e.toString().toLowerCase() == 'nodestatus.${n.status}'),
              );
            }).toList()));
      }).toList();
      await Future.wait(farmFutures);
    } catch (e) {
      logger.e('Failed to get farms due to $e');
      if (context.mounted) {
        final loadingFarmsFailure = SnackBar(
          content: Text(
            'Failed to load farms',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.errorContainer),
          ),
          duration: const Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(loadingFarmsFailure);
      }
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Widget listv3FarmsWidget(List<Farm> farms) {
    return ListView.builder(
        itemCount: farms.length,
        itemBuilder: (context, i) {
          final farm = farms[i];
          print('farms: ${farms.length}');
          return farms.isEmpty
              ? const Text('const SizedBox()')
              : FarmItemWidget(
                  farm: farm,
                  wallets: wallets,
                );
        });
  }

  @override
  Widget build(BuildContext context) {
    Widget mainWidget;
    if (loading) {
      mainWidget = Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 15),
          Text(
            'Loading Farms...',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold),
          ),
        ],
      ));
    } else if (v3Farms.isEmpty && v4Farms.isEmpty) {
      mainWidget = Center(
          child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          Image.asset(
            'assets/farms.png',
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width - 40,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Text(
              'No farm created yet? Get started by setting up your farms! Click the button below to create a new farm.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 40,
            child: ElevatedButton(
              onPressed: _openAddFarmOverlay,
              child: Text(
                'Create New Farm',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
        ],
      ));
    } else {
      mainWidget = DefaultTabController(
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
                    unselectedLabelColor:
                        Theme.of(context).colorScheme.onSurface,
                    dividerColor: Theme.of(context).scaffoldBackgroundColor,
                    labelStyle: Theme.of(context).textTheme.titleLarge,
                    unselectedLabelStyle:
                        Theme.of(context).textTheme.titleMedium,
                    tabs: const [
                      Tab(text: 'V3'),
                      Tab(text: 'V4'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(controller: _tabController, children: [
                  RefreshIndicator(
                    onRefresh: listv3Farms,
                    child: listv3FarmsWidget(v3Farms),
                  ),
                  RefreshIndicator(
                    onRefresh: () => listv3Farms(),
                    child: listv3FarmsWidget(v4Farms),
                  ),
                ]),
              )
            ],
          ));
    }
    return LayoutDrawer(
      titleText: 'Farming',
      content: mainWidget,
      appBarActions: loading
          ? []
          : [
              IconButton(
                  onPressed: _openAddFarmOverlay,
                  icon: const Icon(
                    Icons.add,
                  ))
            ],
    );
  }

  _openAddFarmOverlay() {
    showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: false,
        constraints: const BoxConstraints(maxWidth: double.infinity),
        context: context,
        builder: (ctx) => NewFarm(
              onAddFarm: _addFarm,
              wallets: wallets,
            ));
  }

  _addFarm(Farm farm) {
    v4Farms.add(farm);
    setState(() {});
  }
}
