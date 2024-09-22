import 'package:flutter/material.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/services/gridproxy_service.dart';
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
  Map<int, Map<String, String>> twinIdWallets = {};

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
    twinIdWallets = await getWalletsTwinIds();
    final farmsList = await getFarmsByTwinIds(twinIdWallets.keys.toList());
    for (final f in farmsList) {
      final seed = twinIdWallets[f.twinId]!['tfchainSeed'];
      final walletName = twinIdWallets[f.twinId]!['name'];
      final nodes = await getNodesByFarmId(f.farmID);
      farms.add(Farm(
          name: f.name,
          walletAddress: f.stellarAddress,
          tfchainWalletSecret: seed!,
          walletName: walletName!,
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
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: handle empty farms
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
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.bold),
          ),
        ],
      ));
    } else {
      mainWidget = ListView(
          children: [for (final farm in farms) FarmItemWidget(farm: farm)]);
    }
    return LayoutDrawer(
      titleText: 'Farms',
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
        constraints: const BoxConstraints(maxWidth: double.infinity),
        context: context,
        builder: (ctx) => NewFarm(
              onAddFarm: _addFarm,
              wallets: twinIdWallets.values.toList(),
            ));
  }

  _addFarm(Farm farm) {
    farms.add(farm);
    setState(() {});
  }
}
