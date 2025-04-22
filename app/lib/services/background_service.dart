import 'package:background_fetch/background_fetch.dart';
import 'package:threebotlogin/services/nodes_check_service.dart';
import 'notification_service.dart';

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  final String taskId = task.taskId;
  final bool timeout = task.timeout;

  if (timeout) {
    BackgroundFetch.finish(taskId);
    return;
  }
  await checkNodeStatus();

  BackgroundFetch.finish(taskId);
}

Future<void> checkNodeStatus() async {
  final offlineNodes = await NodeCheckService.pingNodesInBackground();

  if (offlineNodes.isNotEmpty) {
    final twoDaysAgoTimestamp =
        DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;

    final recentOfflineNodes = offlineNodes
        .where((node) => node.updatedAt! > twoDaysAgoTimestamp)
        .toList();

    if (offlineNodes.isEmpty) return;

    const groupKey = 'offline_nodes';
    for (var node in recentOfflineNodes) {
      await NotificationService().showNotification(
        id: node.hashCode,
        title: 'Node Alert 🚨',
        body: 'Node ${node.nodeId} is offline',
        groupKey: groupKey,
      );
    }

    if (recentOfflineNodes.length > 1) {
      await NotificationService().showNotification(
        id: 0,
        title: 'Multiple Nodes Offline',
        body: '${offlineNodes.length} nodes are currently offline',
        groupKey: groupKey,
        isGroupSummary: true,
      );
    }
  }
}
