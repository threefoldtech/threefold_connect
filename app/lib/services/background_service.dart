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

  if (timeout) {
    BackgroundFetch.finish(taskId);
    return;
  }

  final bool notificationsEnabled = await isNodeStatusNotificationEnabled();

  logger.i(
      '[BackgroundFetch] Headless Task: $taskId, Notifications Enabled: $notificationsEnabled');

  if (!notificationsEnabled) {
    logger.i(
        '[BackgroundFetch] Node status notifications are disabled. Finishing task: $taskId');
    BackgroundFetch.finish(taskId);
    return;
  }

  final container = ProviderContainer();

  try {
    await checkNodeStatus(taskId);
    await checkContractsAndNotify(container, taskId);

    logger.i('[BackgroundFetch] Background tasks completed successfully for task: $taskId');
  } catch (e) {
    logger.e('[BackgroundFetch] Error in background tasks for task $taskId: $e');
  } finally {
    container.dispose();
    BackgroundFetch.finish(taskId);
  }
}

Future<void> checkNodeStatus(String taskId) async {
  try {
    final v3OfflineNodes = await NodeCheckService.pingV3NodesInBackground();
    final v4OfflineNodes = await NodeCheckService.pingV4NodesInBackground();
    final offlineNodes = [...v3OfflineNodes, ...v4OfflineNodes];

    logger.i(
        '[BackgroundFetch] Total offline nodes found: ${offlineNodes.length} for task $taskId');

    if (offlineNodes.isEmpty) {
      logger.i(
          '[BackgroundFetch] No offline nodes found, finishing task $taskId');
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
            '[BackgroundFetch] Skipping node ${node.nodeId} - offline for more than 7 days');
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
      logger.i(
          '[BackgroundFetch] No nodes to notify after interval check, finishing task $taskId');
      return;
    }

    await NotificationService().showNotification(
      id: nodesToNotify.hashCode,
      title: nodesToNotify.length == 1
          ? 'Node Alert 🚨'
          : '${nodesToNotify.length} Nodes Offline 🚨',
      body: bodyBuffer.toString().trim(),
      groupKey: 'offline_nodes',
      type: NotificationType.nodeStatus,
      additionalData: {
        'nodeCount': nodesToNotify.length,
        'nodeIds': nodesToNotify.map((n) => n.nodeId).toList(),
      },
    );
  } catch (e) {
    logger.e('[BackgroundFetch] Error in checkNodeStatus for task $taskId: $e');
  } 
}

Future<void> checkContractsAndNotify(
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
          id: 'contract_grace_period'.hashCode,
          title: 'Contract Grace Period Alert! ⏳',
          body: notificationBody,
          groupKey: 'contract_alerts',
          type: NotificationType.contractAlert,
          additionalData: {
            'contractCount': allContractsInGracePeriod.length,
            'contractIds': allContractsInGracePeriod.map((c) => c.contract_id).toList(),
          },
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