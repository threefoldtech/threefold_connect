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

class _FarmScreenState extends ConsumerState<FarmScreen> {
  List<Farm> farms = [];
  List<Wallet> wallets = [];
  bool loading = true;
  bool hasFetched = false;

  @override
  void initState() {
    super.initState();
    _checkHasFetched();
  }

  Future<void> _checkHasFetched() async {
    while (!hasFetched) {
      await Future.delayed(const Duration(seconds: 3));
      hasFetched =
          ref.read(walletsNotifier.notifier.select((n) => n.hasFetched));
      if (hasFetched) {
        listFarms();
        break;
      }
    }
  }

  Future<void> listFarms() async {
    setState(() {
      loading = true;
    });
    try {
      farms.clear();
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
        farms.add(Farm(
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
    } else if (farms.isEmpty) {
      mainWidget = Center(
        child: Text(
          'No farms yet.',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
      );
    } else {
      mainWidget = RefreshIndicator(
          onRefresh: listFarms,
          child: ListView.builder(
              itemCount: farms.length,
              itemBuilder: (context, i) {
                final farm = farms[i];
                return FarmItemWidget(
                  farm: farm,
                  wallets: wallets,
                );
              }));
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
    farms.add(farm);
    setState(() {});
  }
}
