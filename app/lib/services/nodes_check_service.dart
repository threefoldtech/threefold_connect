import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/services/gridproxy_service.dart';
import 'package:threebotlogin/services/tfchain_service.dart';

class NodeCheckService {
  static Future<List<Node>> pingNodesInBackground() async {
    final container = ProviderContainer();
    try {
      final walletsNotifierInstance = container.read(walletsNotifier.notifier);

      await walletsNotifierInstance.waitUntilListed();

      final List<Wallet> wallets = container.read(walletsNotifier);

      final Map<int, Wallet> twinIdWallets = {};
      for (final wallet in wallets) {
        final twinId = await getTwinId(wallet.tfchainSecret);
        if (twinId != 0) {
          twinIdWallets[twinId] = wallet;
        }
      }
      final farmsList = await getFarmsByTwinIds(twinIdWallets.keys.toList());
      final allNodes = <Node>[];
      for (final farm in farmsList) {
        final nodesData = await getNodesByFarmId(farm.farmID);

        final nodes = nodesData
            .map((node) => Node(
                  nodeId: node.nodeId,
                  updatedAt: node.updatedAt,
                  status: NodeStatus.values.firstWhere(
                    (e) =>
                        e.toString().toLowerCase() ==
                        'nodestatus.${node.status.toLowerCase()}',
                  ),
                ))
            .toList();
        allNodes.addAll(nodes);
      }
            final offlineNodes =
          allNodes.where((n) => n.status != NodeStatus.Up).toList();

      return offlineNodes;

    } catch (e) {
      logger.e('[NodeCheckService] Error: $e');
      return [];
    } finally {
      container.dispose();
    }
  }
}
