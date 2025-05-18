import 'package:background_fetch/background_fetch.dart';
import 'package:threebotlogin/apps/notifications/notifications_user_data.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/services/nodes_check_service.dart';
import 'notification_service.dart';
import 'package:threebotlogin/helpers/logger.dart';

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  final String taskId = task.taskId;
  final bool timeout = task.timeout;

  if (timeout) {
    BackgroundFetch.finish(taskId);
    return;
  }
  final bool notificationsEnabled = await isNodeStatusNotificationEnabled();

  logger.i(
      'Background Fetch Headless Task: $taskId, Notifications Enabled: $notificationsEnabled');

  if (!notificationsEnabled) {
    logger.i(
        '[BackgroundFetch] Node status notifications are disabled. Finishing task: $taskId');
    BackgroundFetch.finish(taskId);
    return;
  }
  await checkNodeStatus(taskId);
}

Future<void> checkNodeStatus(String taskId) async {
  try {
    final offlineNodes = await NodeCheckService.pingNodesInBackground();

    if (offlineNodes.isEmpty) return;

    final StringBuffer bodyBuffer = StringBuffer();
    final List<Node> nodesToNotify = [];
    final now = DateTime.now();
    final nowInMs = now.millisecondsSinceEpoch;
    final sevenDaysAgoTimestampMs =
        now.subtract(const Duration(days: 7)).millisecondsSinceEpoch;

    for (final node in offlineNodes) {
      final nodeUpdatedAtMs = node.updatedAt! * 1000;

      if (nodeUpdatedAtMs <= sevenDaysAgoTimestampMs) continue;

      final downtime = Duration(milliseconds: nowInMs - nodeUpdatedAtMs);

      final checkInterval = _getCheckInterval(downtime);

      bool passesIntervalCheck = false;
      if (downtime.inMinutes > 0 && checkInterval.inMinutes > 0) {
        passesIntervalCheck = downtime.inMinutes % checkInterval.inMinutes < 15;
      }

      if (passesIntervalCheck) {
        nodesToNotify.add(node);
        final formattedDowntime = _formatDowntime(downtime);
        bodyBuffer
            .writeln('Node ${node.nodeId}: offline for $formattedDowntime');
      }
    }

    if (nodesToNotify.isEmpty) return;

    await NotificationService().showNotification(
      id: nodesToNotify.hashCode,
      title: nodesToNotify.length == 1
          ? 'Node Alert 🚨'
          : '${nodesToNotify.length} Nodes Offline 🚨',
      body: bodyBuffer.toString().trim(),
      groupKey: 'offline_nodes',
    );
  } catch (e) {
    logger.e('Error in checkNodeStatus for task $taskId: $e');
  } finally {
    BackgroundFetch.finish(taskId);
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
