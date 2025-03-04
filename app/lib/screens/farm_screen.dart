import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:registrar_client/models/farm.dart' as registrarFarm;
import 'package:registrar_client/registrar_client.dart' as registrar;
import 'package:threebotlogin/helpers/farm.dart';
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
  registrar.RegistrarClient? registrarClient;
  List v3Farms = [];
  List<dynamic> v4Farms = [];
  List<Wallet> wallets = [];
  bool loading = true;
  late bool areWalletsListed;
  late final TabController _tabController;

  @override
  initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    areWalletsListed =
        ref.read(walletsNotifier.notifier.select((n) => n.isListed));
    checkWalletsListed();
  }

  Future<void> checkWalletsListed() async {
    if (areWalletsListed) {
      wallets = ref.read(walletsNotifier);
      await listFarms();
      return;
    }
    while (!areWalletsListed) {
      await Future.delayed(const Duration(seconds: 2));
      areWalletsListed =
          ref.read(walletsNotifier.notifier.select((n) => n.isListed));
      if (areWalletsListed) {
        wallets = ref.read(walletsNotifier);
        await listFarms();
        break;
      }
    }
  }

  Future<void> listFarms() async {
    try {
      setState(() {
        loading = true;
        registrarClient = null;
        v3Farms.clear();
        v4Farms.clear();
      });
      await listV3FarmsAndNodes();
      await listV4FarmsAndNodes();
      setState(() {});
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

  listV3FarmsAndNodes() async {
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
  }

  listV4FarmsAndNodes() async {
    late registrar.Account account;
    final keypair = await generateKeypair(wallets.first.tfchainSecret);
    registrarClient = registrar.RegistrarClient(
        baseUrl: 'http://192.168.1.16:8080/v1', privateKey: keypair['privateKey']!);
    for (var w in wallets) {
      final keypair = await generateKeypair(w.tfchainSecret);
      print('keypair, $keypair');
      try {
        account = await registrarClient!.accounts
            .getByPublicKey(keypair['publicKey']!);
        print('account in list: $account');
        final farms = await registrarClient!.farms
            .list(registrarFarm.FarmFilter(twinID: account.twinID));
      print('farmssss: $farms');
        v4Farms.addAll(farms);
      } catch (e) {
        continue;
      }
    }
  }

  Widget listFarmsWidget(List<dynamic> farms) {
    if (farms.isEmpty) {
      return SingleChildScrollView(
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
    }
    return ListView.builder(
        itemCount: farms.length,
        itemBuilder: (context, i) {
          final farm = farms[i];
          return FarmItemWidget(
            farm: farm,
            wallets: wallets,
            isV4: farms == v4Farms 
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
                    onRefresh: listFarms,
                    child: listFarmsWidget(v3Farms),
                  ),
                  RefreshIndicator(
                    onRefresh: listFarms,
                    child: listFarmsWidget(v4Farms),
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
              isV4: _tabController.index == 1,
            ));
  }

  _addFarm(dynamic farm) async {
    if (_tabController.index == 0) {
      v3Farms.add(farm);
    } else {
      v4Farms.add(farm);
    }
    setState(() {});
  }
}
