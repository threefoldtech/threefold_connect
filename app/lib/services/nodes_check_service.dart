import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gridproxy_client/models/contracts.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/services/gridproxy_service.dart';

class NodeCheckService {
  static Future<List<Node>> pingMyNodes() async {
    final container = ProviderContainer();
    try {
      await container.read(walletsNotifier.notifier).waitUntilListed();
      final List<Wallet> wallets = container.read(walletsNotifier);

      if (wallets.isEmpty) return [];

      final twinIds = wallets.map((w) => w.twinId!).toList();
      final farmsList = await getFarmsByTwinIds(twinIds);
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
          allNodes.where((n) => n.status == NodeStatus.Down).toList();

      return offlineNodes;
    } catch (e) {
      logger.e('[NodeCheckService] Error: $e');
      return [];
    } finally {
      container.dispose();
    }
  }

  static Future<List<int>> pingWorkloadNodes() async {
    final container = ProviderContainer();
    try {
      await container.read(walletsNotifier.notifier).waitUntilListed();
      final wallets = container.read(walletsNotifier);

      // Get unique node IDs from all wallet contracts
      final nodeIds = (await Future.wait(wallets.map((w) => getContracts(
              w.twinId!, [ContractState.Created, ContractState.GracePeriod]))))
          .expand((contracts) => contracts)
          .map((c) => c.nodeId!)
          .toSet()
          .toList();

      if (nodeIds.isEmpty) return [];

      return nodeIds.isEmpty ? [] : await _getOfflineNodes(nodeIds);
    } catch (e) {
      logger.e('[NodeCheckService] Error: $e');
      return [];
    } finally {
      container.dispose();
    }
  }

  static Future<List<int>> _getOfflineNodes(List<int> nodeIds) async {
    final nodes = await Future.wait(nodeIds.map(_fetchNodeStatus));
    return nodes
        .where((n) => n.status == NodeStatus.Down)
        .map((n) => n.nodeId)
        .toList();
  }

  static Future<Node> _fetchNodeStatus(int nodeId) async {
    final nodeData = await getNodeById(nodeId);
    return Node(
      nodeId: nodeId,
      status: NodeStatus.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            nodeData.status.toLowerCase(),
      ),
    );
  }
}
