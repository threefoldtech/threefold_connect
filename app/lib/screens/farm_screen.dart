import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:registrar_client/models/farm.dart' as registrarFarm;
import 'package:registrar_client/models/node.dart' as registrarNode;
import 'package:registrar_client/registrar_client.dart' as registrar;
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/gridproxy_service.dart';
import 'package:threebotlogin/services/tfchain_service.dart';
import 'package:threebotlogin/widgets/add_farm.dart';
import 'package:threebotlogin/widgets/farm_item.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FarmScreen extends ConsumerStatefulWidget {
  const FarmScreen({super.key});

  @override
  ConsumerState<FarmScreen> createState() => _FarmScreenState();
}

class _FarmScreenState extends ConsumerState<FarmScreen>
    with SingleTickerProviderStateMixin {
  registrar.RegistrarClient? registrarClient;
  List<Farm> v3Farms = [];
  List<Farm> v4Farms = [];
  List<Wallet> wallets = [];
  bool failed = false;
  bool loading = true;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    listFarms();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  listWallets() async {
    await ref.read(walletsNotifier.notifier).waitUntilListed();
    wallets = ref.read(walletsNotifier);
  }

  Future<void> listFarms() async {
    _setLoadingState();

    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        _handleFailure(
          'No internet connection. Please check your network.',
        );
        return;
      }
      await _fetchAllFarmData().timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          throw TimeoutException('Loading farm data timed out');
        },
      );

      _handleSuccess();
    } on TimeoutException catch (e) {
      _handleFailure('Loading farms timed out. Poor connection?', error: e);
    } on Exception catch (e) {
      _handleFailure('Failed to load farms due to an unexpected error.',
          error: e);
    }
  }

  Future<void> _fetchAllFarmData() async {
    v3Farms.clear();
    v4Farms.clear();
    registrarClient = null;

    await listWallets();

    if (wallets.isEmpty) return;
    await listV3FarmsAndNodes();
    await listV4FarmsAndNodes();
  }

  void _setLoadingState() {
    setState(() {
      loading = true;
      failed = false;
      v3Farms.clear();
      v4Farms.clear();
      registrarClient = null;
    });
  }

  void _handleSuccess() {
    setState(() {
      loading = false;
      failed = false;
    });
    logger.i('Farm data loaded successfully.');
  }

  void _handleFailure(String userMessage, {Object? error}) {
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

  listV3FarmsAndNodes() async {
    final Map<int, Wallet> twinIdWallets = {};
    await Future.wait(wallets.map((w) async {
      final twinId = await getTwinId(w.tfchainSecret);
      if (twinId != 0) {
        twinIdWallets[twinId] = w;
      }
    }));
    final farmsList = await getFarmsByTwinIds(twinIdWallets.keys.toList());
    v3Farms = await Future.wait(farmsList.map((farm) async {
      final nodes = await getNodesByFarmId(farm.farmID);
      final wallet = twinIdWallets[farm.twinId]!;
      return Farm(
        name: farm.name,
        walletAddress: farm.stellarAddress,
        tfchainWalletSecret: wallet.tfchainSecret,
        walletName: wallet.name,
        twinId: farm.twinId,
        farmId: farm.farmID,
        nodes: nodes
            .map((node) => Node(
                  nodeId: node.nodeId,
                  status: NodeStatus.values.firstWhere(
                    (e) =>
                        e.toString().toLowerCase() ==
                        'nodestatus.${node.status}',
                  ),
                  country: node.location!.country,
                  uptime: node.uptime,
                ))
            .toList(),
      );
    }).toList());
  }

  Future<void> listV4FarmsAndNodes() async {
    registrarClient = registrar.RegistrarClient(
        baseUrl: Globals().registrarURL,
        mnemonicOrSeed: wallets.first.tfchainSecret);
    for (var w in wallets) {
      try {
        final publicKey = await derivePublicKey(w.tfchainSecret);
        final account =
            await registrarClient!.accounts.getByPublicKey(publicKey);
        final farms = await registrarClient!.farms
            .list(registrarFarm.FarmFilter(twinID: account.twinID));
        final nodes = await registrarClient!.nodes
            .list(registrarNode.NodeFilter(twinID: account.twinID));

        v4Farms.addAll(farms.map((f) => Farm(
              name: f.farmName,
              walletAddress: f.stellarAddress!,
              tfchainWalletSecret: w.tfchainSecret,
              walletName: w.name,
              twinId: f.twinID,
              farmId: f.farmID!,
              nodes: nodes
                  .where((n) => n.farmID == f.farmID)
                  .map((n) => Node(
                      nodeId: n.nodeID,
                      status: NodeStatus.Up,
                      country: n.location.country,
                      uptime:
                          (n.uptime.isNotEmpty) ? n.uptime.last.duration : 0))
                  .toList(),
            )));
      } catch (e) {
        continue;
      }
    }
  }

  Widget listFarmsWidget(List<Farm> farms, bool isV4) {
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
            isV4: isV4,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading Farms...',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold),
          ),
        ],
      ));
    } else if (failed) {
      mainWidget = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: () {
                listFarms();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    } else {
      mainWidget = Column(
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
                child: listFarmsWidget(v3Farms, false),
              ),
              RefreshIndicator(
                onRefresh: listFarms,
                child: listFarmsWidget(v4Farms, true),
              ),
            ]),
          )
        ],
      );
    }
    return LayoutDrawer(
      titleText: 'Farming',
      content: mainWidget,
      appBarActions: loading || failed
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

  _addFarm(Farm farm) {
    setState(() {
      _tabController.index == 0 ? v3Farms.add(farm) : v4Farms.add(farm);
    });
  }
}
