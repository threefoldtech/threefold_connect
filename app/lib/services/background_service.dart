import 'package:background_fetch/background_fetch.dart';
import 'package:threebotlogin/services/nodes_check_service.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/helpers/logger.dart';

const String _nodeStatusNotificationEnabledKey =
    'nodeStatusNotificationEnabled';

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  final String taskId = task.taskId;
  final bool timeout = task.timeout;

  if (timeout) {
    BackgroundFetch.finish(taskId);
    return;
  }
  final prefs = await SharedPreferences.getInstance();
  final bool notificationsEnabled =
      prefs.getBool(_nodeStatusNotificationEnabledKey) ?? true;

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
  final offlineNodes = await NodeCheckService.pingNodesInBackground();
  if (offlineNodes.isEmpty) {
    BackgroundFetch.finish(taskId);
    return;
  }

  final now = DateTime.now().millisecondsSinceEpoch;
  final sevenDaysAgoTimestamp =
      DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;

  final nodesToNotify = offlineNodes.where((node) {
    final nodeUpdatedAtMs = node.updatedAt! * 1000;
    if (nodeUpdatedAtMs <= sevenDaysAgoTimestamp) return false;

    final downtime = Duration(milliseconds: now - nodeUpdatedAtMs);
    final checkInterval = _getCheckInterval(downtime);

    return downtime.inMinutes % checkInterval.inMinutes < 15;
  }).toList();

  if (nodesToNotify.isEmpty) {
    BackgroundFetch.finish(taskId);
    return;
  }

  const groupKey = 'offline_nodes';
  final StringBuffer bodyBuffer = StringBuffer();

  for (final node in nodesToNotify) {
    final nodeUpdatedAtMs = node.updatedAt! * 1000;
    final downtime =
        _formatDowntime(Duration(milliseconds: now - nodeUpdatedAtMs));

    bodyBuffer.writeln('Node ${node.nodeId}: offline for $downtime');
  }

  await NotificationService().showNotification(
    id: nodesToNotify.hashCode,
    title: nodesToNotify.length == 1
        ? 'Node Alert 🚨'
        : '${nodesToNotify.length} Nodes Offline 🚨',
    body: bodyBuffer.toString().trim(),
    groupKey: groupKey,
  );
  BackgroundFetch.finish(taskId);
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
