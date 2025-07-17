import 'dart:io';
import 'package:flutter/services.dart';
import 'package:workmanager/workmanager.dart';
import 'package:threebotlogin/apps/notifications/notifications_user_data.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/services/nodes_check_service.dart';
import 'notification_service.dart';
import 'package:threebotlogin/helpers/logger.dart';

/// F-Droid compatible background service that works on both Android and iOS
class FDroidBackgroundService {
  static const String _channelName = 'com.threefold.background_tasks';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static const String _taskIdentifier = 'com.threefold.node_check_task';
  static const String _periodicTaskName = 'nodeStatusCheck';

  /// Initialize background task system
  static Future<void> initialize() async {
    logger.i('[Background Service] Initializing for platform: ${Platform.operatingSystem}');
    if (Platform.isAndroid) {
      await _initializeAndroid();
    } else if (Platform.isIOS) {
      await _initializeIOS();
    }
    logger.i('[Background Service] Initialization complete');
  }

  /// Start periodic background tasks
  static Future<void> startPeriodicTask() async {
    logger.i('[Background Service] Starting periodic task for platform: ${Platform.operatingSystem}');
    if (Platform.isAndroid) {
      await _startAndroidPeriodicTask();
    } else if (Platform.isIOS) {
      await _startIOSBackgroundTask();
    }
  }

  /// Stop background tasks
  static Future<void> stopPeriodicTask() async {
    if (Platform.isAndroid) {
      await Workmanager().cancelByUniqueName(_periodicTaskName);
    } else if (Platform.isIOS) {
      await _channel.invokeMethod('cancelBackgroundTask');
    }
  }

  /// Check if background tasks are enabled
  static Future<bool> isEnabled() async {
    if (Platform.isAndroid) {
      // Android workmanager doesn't provide a direct way to check if tasks are running
      // We'll assume it's enabled if we can register tasks
      return true;
    } else if (Platform.isIOS) {
      try {
        final result = await _channel.invokeMethod('isBackgroundTaskEnabled');
        return result ?? false;
      } catch (e) {
        logger.e('Error checking iOS background task status: $e');
        return false;
      }
    }
    return false;
  }

  // Android-specific methods
  static Future<void> _initializeAndroid() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // Set to false for production
    );
  }

  static Future<void> _startAndroidPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      _periodicTaskName,
      _periodicTaskName,
      frequency: const Duration(hours: 1), // Minimum allowed frequency
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 15),
    );
  }

  // iOS-specific methods
  static Future<void> _initializeIOS() async {
    logger.i('[iOS Background] Setting up method call handler');
    _channel.setMethodCallHandler(_handleIOSMethodCall);
    logger.i('[iOS Background] Invoking initialize method');
    try {
      final result = await _channel.invokeMethod('initialize', {
        'taskIdentifier': _taskIdentifier,
      });
      logger.i('[iOS Background] Initialize result: $result');
    } catch (e) {
      logger.e('[iOS Background] Failed to initialize: $e');
      rethrow;
    }
  }

  static Future<void> _startIOSBackgroundTask() async {
    logger.i('[iOS Background] Attempting to schedule background task: $_taskIdentifier');
    try {
      final result = await _channel.invokeMethod('scheduleBackgroundTask', {
        'taskIdentifier': _taskIdentifier,
        'earliestBeginDate': DateTime.now()
            .add(const Duration(minutes: 1)) // Changed to 1 minute for testing
            .millisecondsSinceEpoch,
      });
      logger.i('[iOS Background] Schedule result: $result');
    } catch (e) {
      logger.e('[iOS Background] Failed to schedule background task: $e');
      rethrow;
    }
  }

  static Future<void> _handleIOSMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'executeBackgroundTask':
        final Map<String, dynamic>? args = call.arguments as Map<String, dynamic>?;
        final String taskIdentifier = args?['taskIdentifier'] ?? _taskIdentifier;
        logger.i('[iOS Background] Executing background task: $taskIdentifier');

        try {
          await _executeBackgroundTask(taskIdentifier);
          logger.i('[iOS Background] Background task completed successfully');
          // Don't call completeBackgroundTask here - it's handled by the native side
        } catch (e) {
          logger.e('[iOS Background] Background task failed: $e');
          // Don't call completeBackgroundTask here - it's handled by the native side
        }
        break;
      default:
        logger.w('[iOS Background] Unknown method call: ${call.method}');
    }
  }

  /// Common background task execution logic for both platforms
  static Future<void> _executeBackgroundTask(String taskId) async {
    try {
      final bool notificationsEnabled = await isNodeStatusNotificationEnabled();

      logger.i(
          '[Background Task] Task: $taskId, Notifications Enabled: $notificationsEnabled');

      if (!notificationsEnabled) {
        logger.i(
            '[Background Task] Node status notifications are disabled. Finishing task: $taskId');
        return;
      }

      await _checkNodeStatus(taskId);
    } catch (e) {
      logger.e('[Background Task] Error executing task $taskId: $e');
      rethrow;
    }
  }

  static Future<void> _checkNodeStatus(String taskId) async {
    try {
      logger.i('[Background Task] Checking node status for task $taskId');
      final v3OfflineNodes = await NodeCheckService.pingV3NodesInBackground();
      logger.i(
          '[Background Task] Total v3 offline nodes found: ${v3OfflineNodes.length} for task $taskId');
      final v4OfflineNodes = await NodeCheckService.pingV4NodesInBackground();
      final offlineNodes = [...v3OfflineNodes, ...v4OfflineNodes];

      logger.i(
          '[Background Task] Total offline nodes found: ${offlineNodes.length} for task $taskId');

      if (offlineNodes.isEmpty) {
        logger.i(
            '[Background Task] No offline nodes found, finishing task $taskId');
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
              '[Background Task] Skipping node ${node.nodeId} - offline for more than 7 days');
          continue;
        }

        final downtime = Duration(milliseconds: nowInMs - nodeUpdatedAtMs);
        final checkInterval = _getCheckInterval(downtime);

        bool passesIntervalCheck = false;
        if (downtime.inMinutes > 0 && checkInterval.inMinutes > 0) {
          passesIntervalCheck =
              downtime.inMinutes % checkInterval.inMinutes < 15;
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
            '[Background Task] No nodes to notify after interval check, finishing task $taskId');
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
      logger.e('[Background Task] Error checking node status: $e');
      rethrow;
    }
  }

  static Duration _getCheckInterval(Duration downtime) {
    // Small intervals for testing purposes
    if (downtime.inMinutes < 5) {
      return const Duration(
          minutes: 1); // Check every 1 minute for recent downtime
    } else if (downtime.inMinutes < 15) {
      return const Duration(minutes: 2); // Check every 2 minutes
    } else if (downtime.inMinutes < 30) {
      return const Duration(minutes: 5); // Check every 5 minutes
    } else {
      return const Duration(
          minutes: 10); // Check every 10 minutes for longer downtime
    }
  }

  static String _formatDowntime(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}

/// Android workmanager callback dispatcher
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      logger.i('[Android Workmanager] Executing task: $task');

      switch (task) {
        case FDroidBackgroundService._periodicTaskName:
          await FDroidBackgroundService._executeBackgroundTask(task);
          break;
        default:
          logger.w('[Android Workmanager] Unknown task: $task');
      }

      return Future.value(true);
    } catch (e) {
      logger.e('[Android Workmanager] Task failed: $e');
      return Future.value(false);
    }
  });
}
