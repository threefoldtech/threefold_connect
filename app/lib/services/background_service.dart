import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gridproxy_client/models/contracts.dart';
import 'package:threebotlogin/apps/notifications/notifications_user_data.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/services/contract_check_service.dart';
import 'package:threebotlogin/services/nodes_check_service.dart';
import 'notification_service.dart';
import 'package:threebotlogin/helpers/logger.dart';

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  final String taskId = task.taskId;
  final bool timeout = task.timeout;

  final container = ProviderContainer();

  try {
    if (timeout) {
      logger.w('[BackgroundFetch] Task timed out: $taskId');
      BackgroundFetch.finish(taskId);
      return;
    }

    logger.i(
        '[BackgroundFetch] Headless Task: $taskId started. Time: ${DateTime.now()}');

    // Run contract and node checks concurrently
    await Future.wait([
      _checkContractsAndNotify(container, taskId),
      _checkNodesAndNotify(taskId),
    ]);
  } catch (e, stack) {
    logger.e('[BackgroundFetch] Error during task $taskId: $e',
        error: e, stackTrace: stack);
  } finally {
    container.dispose();
    BackgroundFetch.finish(taskId);
    logger.i('[BackgroundFetch] Task finished: $taskId');
  }
}

Future<void> _checkContractsAndNotify(
    ProviderContainer container, String taskId) async {
  try {
    final List<ContractInfo> allContractsInGracePeriod = await container
        .read(contractCheckServiceProvider)
        .checkContractsState();

    if (allContractsInGracePeriod.isNotEmpty) {
      final bool contractNotificationsEnabled =
          await isContractNotificationEnabled();
      logger.i(
          '[ContractsCheck] Contracts in grace period: ${allContractsInGracePeriod.length}. Contract Notifications enabled: $contractNotificationsEnabled');

      if (contractNotificationsEnabled) {
        String notificationBody =
            'You have ${allContractsInGracePeriod.length} contract(s) in grace period.';
        final String contractIds =
            allContractsInGracePeriod.map((c) => c.contract_id).join(', ');
        notificationBody += '\nContract IDs: $contractIds';

        await NotificationService().showNotification(
          id: 'contract_grace_period',
          title: 'Contract Grace Period Alert! ⏳',
          body: notificationBody,
          groupKey: 'contract_alerts',
        );
      }
    }
  } catch (e, stack) {
    logger.e(
        '[ContractsCheck] Error during contracts check for task $taskId: $e',
        error: e,
        stackTrace: stack);
    rethrow;
  }
}

Future<void> _checkNodesAndNotify(String taskId) async {
  try {
    final bool nodeNotificationsEnabled =
        await isNodeStatusNotificationEnabled();
    logger.i(
        '[NodesCheck] Node Notifications Enabled: $nodeNotificationsEnabled for task $taskId');

    if (!nodeNotificationsEnabled) {
      logger.i(
          '[NodesCheck] Node notifications are disabled by user setting. Exiting _checkNodesAndNotify for task $taskId.');
      return;
    }

    final offlineNodes = await NodeCheckService.pingNodesInBackground();
    if (offlineNodes.isEmpty) {
      logger.i(
          '[NodesCheck] No raw offline nodes found from pingNodesInBackground(). Exiting _checkNodesAndNotify for task $taskId.');
      return;
    }
    logger.i(
        '[NodesCheck] Found ${offlineNodes.length} raw offline nodes for task $taskId.');

    final StringBuffer bodyBuffer = StringBuffer();
    final List<Node> nodesToNotify = [];
    final now = DateTime.now();
    final nowInMs = now.millisecondsSinceEpoch;
    final sevenDaysAgoTimestampMs =
        now.subtract(const Duration(days: 7)).millisecondsSinceEpoch;

    for (final node in offlineNodes) {
      final nodeUpdatedAtMs = node.updatedAt! * 1000;

      // Filter out nodes updated more than 7 days ago
      // if (nodeUpdatedAtMs <= sevenDaysAgoTimestampMs) continue;

      final downtime = Duration(milliseconds: nowInMs - nodeUpdatedAtMs);
      final checkInterval = _getCheckInterval(downtime);

      bool passesIntervalCheck = false;
      if (downtime.inMinutes > 0 && checkInterval.inMinutes > 0) {
        passesIntervalCheck = downtime.inMinutes % checkInterval.inMinutes < 15;
      }
      // if (passesIntervalCheck) {
      nodesToNotify.add(node);
      final formattedDowntime = _formatDowntime(downtime);
      bodyBuffer.writeln('Node ${node.nodeId}: offline for $formattedDowntime');
      // }
    }

    if (nodesToNotify.isEmpty) return;

    await NotificationService().showNotification(
      id: 'offline_nodes_alert',
      title: nodesToNotify.length == 1
          ? 'Node Alert 🚨'
          : '${nodesToNotify.length} Nodes Offline 🚨',
      body: bodyBuffer.toString().trim(),
      groupKey: 'offline_nodes',
    );
  } catch (e, stack) {
    logger.e('[NodesCheck] Error in node check for task $taskId: $e',
        error: e, stackTrace: stack);
    rethrow;
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
  } else if (duration.inMinutes > 0) {
    return '${duration.inMinutes} minutes';
  } else {
    return '${duration.inSeconds} seconds';
  }
}
