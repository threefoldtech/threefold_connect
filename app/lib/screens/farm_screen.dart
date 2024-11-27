import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/gridproxy_service.dart';
import 'package:threebotlogin/services/tfchain_service.dart';
import 'package:threebotlogin/services/wallet_service.dart';
import 'package:threebotlogin/widgets/add_farm.dart';
import 'package:threebotlogin/widgets/farm_item.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';

class FarmScreen extends StatefulWidget {
  const FarmScreen({super.key});

  @override
  State<FarmScreen> createState() => _FarmScreenState();
}

class _FarmScreenState extends State<FarmScreen> {
  List<Farm> farms = [];
  List<Wallet> wallets = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    listFarms();
  }

  listFarms() async {
    setState(() {
      loading = true;
    });
    try {
      wallets = await listWallets();
      final Map<int, Wallet> twinIdWallets = {};
      for (final w in wallets) {
        final twinId = await getTwinId(w.tfchainSecret);
        if (twinId != 0) {
          twinIdWallets[twinId] = w;
        }
      }
      final farmsList = await getFarmsByTwinIds(twinIdWallets.keys.toList());
      for (final f in farmsList) {
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
      }
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
      mainWidget = ListView(
          children: [for (final farm in farms) FarmItemWidget(farm: farm, wallets: wallets,)]);
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
