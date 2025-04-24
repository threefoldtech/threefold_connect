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
  if (offlineNodes.isEmpty) return;

  final now = DateTime.now().millisecondsSinceEpoch;
  final sevenDaysAgoTimestamp =
      DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;

  final nodesToNotify = offlineNodes.where((node) {
    if (node.updatedAt! <= sevenDaysAgoTimestamp) return false;

    final downtime = Duration(milliseconds: now - node.updatedAt!);
    final checkInterval = _getCheckInterval(downtime);

    return downtime.inMinutes % checkInterval.inMinutes < 15;
  }).toList();

  if (nodesToNotify.isEmpty) return;

  const groupKey = 'offline_nodes';
  if (nodesToNotify.length == 1) {
    final node = nodesToNotify.first;
    final downtime =
        _formatDowntime(Duration(milliseconds: now - node.updatedAt!));

    await NotificationService().showNotification(
      id: node.hashCode,
      title: 'Node Alert 🚨',
      body: 'Node ${node.nodeId} has been offline for $downtime',
      groupKey: groupKey,
    );
  } else {
    await NotificationService().showNotification(
      id: nodesToNotify.hashCode,
      title: 'Multiple Nodes Offline',
      body: '${nodesToNotify.length} nodes are currently offline',
      groupKey: groupKey,
    );
  }
}

Duration _getCheckInterval(Duration downtime) {
  if (downtime < const Duration(hours: 1)) {
    return const Duration(minutes: 15); // 0-1 hour: check every 15 min
  } else if (downtime < const Duration(hours: 4)) {
    return const Duration(hours: 1); // 1-4 hours: check every hour
  } else if (downtime < const Duration(hours: 24)) {
    return const Duration(hours: 4); // 4-24 hours: check every 4 hours
  } else if (downtime < const Duration(days: 3)) {
    return const Duration(hours: 12); // 1-3 days: check every 12 hours
  } else {
    return const Duration(days: 1); // 3-7 days: check once per day
  }
}

String _formatDowntime(Duration duration) {
  if (duration.inDays > 0) {
    return '${duration.inDays} days';
  } else if (duration.inHours > 0) {
    return '${duration.inHours} hours';
  } else {
    return '${duration.inMinutes} minutes';
  }
}
