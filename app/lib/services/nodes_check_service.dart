import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/gridproxy_service.dart';
import 'package:threebotlogin/services/tfchain_service.dart';
import 'package:registrar_client/models/farm.dart' as registrarFarm;
import 'package:registrar_client/models/node.dart' as registrarNode;
import 'package:registrar_client/registrar_client.dart' as registrar;

class NodeCheckService {
  static Future<List<Node>> pingV3NodesInBackground() async {
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

  static Future<List<Node>> pingV4NodesInBackground() async {
    final container = ProviderContainer();
    final List<Node> allOfflineNodes = [];

    try {
      final walletsNotifierInstance = container.read(walletsNotifier.notifier);

      await walletsNotifierInstance.waitUntilListed();

      final List<Wallet> wallets = container.read(walletsNotifier);

      if (wallets.isEmpty) {
        logger.i('[NodeCheckService] No wallets found');
        return [];
      }

      registrar.RegistrarClient? registrarClient = registrar.RegistrarClient(
          baseUrl: Globals().registrarURL,
          mnemonicOrSeed: wallets.first.tfchainSecret);
      for (var w in wallets) {
        try {
          final publicKey = await derivePublicKey(w.tfchainSecret);
          final account =
              await registrarClient.accounts.getByPublicKey(publicKey);
          final farms = await registrarClient.farms
              .list(registrarFarm.FarmFilter(twinID: account.twinID));

          for (var f in farms) {
            final farmNodes = await registrarClient.nodes
                .list(registrarNode.NodeFilter(farmID: f.farmID));

            final nodes = farmNodes.map((n) {
              // Convert ISO timestamp to Unix timestamp
              final lastSeenDate = DateTime.parse(n.lastSeen);
              final unixTimestamp = lastSeenDate.millisecondsSinceEpoch ~/ 1000;

              return Node(
                nodeId: n.nodeID,
                status: n.online ? NodeStatus.Up : NodeStatus.Down,
                country: n.location.country,
                uptime: (n.uptime.isNotEmpty) ? n.uptime.last.duration : 0,
                updatedAt: unixTimestamp,
              );
            }).toList();

            final offlineNodes =
                nodes.where((n) => n.status != NodeStatus.Up).toList();
            allOfflineNodes.addAll(offlineNodes);
          }
        } catch (e) {
          logger.e('[NodeCheckService] Error: $e');
          continue;
        }
      }

      logger.i(
          '[NodeCheckService] Found ${allOfflineNodes.length} offline nodes');
      return allOfflineNodes;
    } catch (e) {
      logger.e('[NodeCheckService] Error in pingV4NodesInBackground: $e');
      return [];
    } finally {
      container.dispose();
    }
  }
}
