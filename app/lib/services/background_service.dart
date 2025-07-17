import 'package:workmanager/workmanager.dart';
import 'package:threebotlogin/apps/notifications/notifications_user_data.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/services/nodes_check_service.dart';
import 'notification_service.dart';
import 'package:threebotlogin/helpers/logger.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    logger.i('[Workmanager] Executing task: $taskName');
    
    final bool notificationsEnabled = await isNodeStatusNotificationEnabled();
    
    logger.i('[Workmanager] Notifications Enabled: $notificationsEnabled');
    
    if (!notificationsEnabled) {
      logger.i('[Workmanager] Node status notifications are disabled.');
      return true;
    }
    
    await checkNodeStatus(taskName);
    return true;
  });
}

Future<void> checkNodeStatus(String taskId) async {
  try {
    final v3OfflineNodes = await NodeCheckService.pingV3NodesInBackground();
    final v4OfflineNodes = await NodeCheckService.pingV4NodesInBackground();
    final offlineNodes = [...v3OfflineNodes, ...v4OfflineNodes];

    logger.i(
        '[Workmanager] Total offline nodes found: ${offlineNodes.length} for task $taskId');

    if (offlineNodes.isEmpty) {
      logger.i('[Workmanager] No offline nodes found');
      return;
    }

    final StringBuffer bodyBuffer = StringBuffer();
    final List<Node> nodesToNotify = [];
    final now = DateTime.now();
    final nowInMs = now.millisecondsSinceEpoch;
    final sevenDaysAgoTimestampMs =
        now.subtract(const Duration(days: 7)).millisecondsSinceEpoch;

    for (final node in offlineNodes) {
      final nodeUpdatedAtMs = node.updatedAt! * 1000;

      if (nodeUpdatedAtMs <= sevenDaysAgoTimestampMs) {
        logger.i(
            '[Workmanager] Skipping node ${node.nodeId} - offline for more than 7 days');
        continue;
      }

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

    if (nodesToNotify.isEmpty) {
      logger.i('[Workmanager] No nodes to notify after interval check');
      return;
    }

    await NotificationService().showNotification(
      id: nodesToNotify.hashCode,
      title: nodesToNotify.length == 1
          ? 'Node Alert 🚨'
          : '${nodesToNotify.length} Nodes Offline 🚨',
      body: bodyBuffer.toString().trim(),
      groupKey: 'offline_nodes',
    );
  } catch (e) {
    logger.e('[Workmanager] Error in checkNodeStatus for task $taskId: $e');
  }
}

Duration _getCheckInterval(Duration downtime) {
  if (downtime < const Duration(hours: 2)) {
    return const Duration(minutes: 15); // 0-2 hour: check every 15 min
  } else if (downtime < const Duration(hours: 4)) {
    return const Duration(hours: 1); // 2-4 hours: check every hour
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
    return '${duration.inDays} ${duration.inDays == 1 ? 'day' : 'days'}';
  } else if (duration.inHours > 0) {
    return '${duration.inHours} ${duration.inHours == 1 ? 'hour' : 'hours'}';
  } else {
    return '${duration.inMinutes} ${duration.inMinutes == 1 ? 'minute' : 'minutes'}';
  }
}
