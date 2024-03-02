import 'package:flutter/material.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/widgets/farm_item.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';

class FarmScreen extends StatefulWidget {
  const FarmScreen({super.key});

  @override
  State<FarmScreen> createState() => _FarmScreenState();
}

class _FarmScreenState extends State<FarmScreen> {
  final List<Farm> farms = [
    Farm(
      name: 'Hamada',
      walletAddress: 'GCNHLX2ZTX2HDXCIQATZRSIHK2ECKEMKZCMSMIWBOTS2DZYUJBMHNXJA',
      tfchainWalletSecret:
          'miss secret news run cliff lens exist clerk lucky cube fall soldier',
      walletName: 'Farming wallet',
      twinId: '26',
      farmId: '56',
      nodes: [
        Node(
          nodeId: '88',
          status: NodeStatus.Up,
        ),
      ],
    ),
    Farm(
      name: 'My Farm',
      walletAddress: 'GCNHLX2ZTX2HDXCIQATZRSIHK2ECKEMKZCMSMIWBOTS2DZYUJBMHNXJA',
      tfchainWalletSecret:
          'miss secret news run cliff lens exist clerk lucky cube fall soldier',
      walletName: 'Farming wallet',
      twinId: '26',
      farmId: '154',
      nodes: [
        Node(
          nodeId: '193',
          status: NodeStatus.Down,
        ),
        Node(
          nodeId: '493',
          status: NodeStatus.Standby,
        ),
        Node(
          nodeId: '584',
          status: NodeStatus.Up,
        ),
      ],
    ),
    Farm(
      name: 'My Animals',
      walletAddress: 'GCNHLX2ZTX2HDXCIQATZRSIHK2ECKEMKZCMSMIWBOTS2DZYUJBMHNXJA',
      tfchainWalletSecret:
          'miss secret news run cliff lens exist clerk lucky cube fall soldier',
      walletName: 'Farming wallet',
      twinId: '26',
      farmId: '389',
      nodes: [
        Node(
          nodeId: '1034',
          status: NodeStatus.Standby,
        ),
        Node(
          nodeId: '1203',
          status: NodeStatus.Up,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutDrawer(
      titleText: 'Farms',
      content: ListView(
          children: [for (final farm in farms) FarmItemWidget(farm: farm)]),
    );
  }
}
