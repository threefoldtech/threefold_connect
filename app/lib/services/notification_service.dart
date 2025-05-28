import 'dart:convert';
import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  logger.i('[NotificationService] Action received: ${receivedAction.title}');

  if (receivedAction.id != null) {
    await AwesomeNotifications().dismiss(receivedAction.id!);
  }

  final payload = receivedAction.payload?['data'];
  if (payload != null) {
    final Map<String, dynamic> data = json.decode(payload);
    logger.i('[NotificationService] Processing notification payload: $data');
    NotificationService()._handleNotificationTap(data);
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;
  Map<String, dynamic>? _pendingPayload;
  bool _isAppResumed = false;
  int _notificationCount = 0;

  Future<void> initNotification() async {
    if (_isInitialized) return;

    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'node_status_channel',
          channelName: 'Node Status',
          channelDescription: 'Notify user when node goes offline',
          importance: NotificationImportance.High,
          channelShowBadge: true,
          enableVibration: true,
          enableLights: true,
          criticalAlerts: true,
        ),
      ],
      debug: true,
    );

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreated,
      onNotificationDisplayedMethod: _onNotificationDisplayed,
      onDismissActionReceivedMethod: _onDismissActionReceived,
    );

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    _isInitialized = true;
  }

  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
    String? groupKey,
    bool isGroupSummary = false,
  }) async {
    try {
      if (!_isInitialized) {
        await initNotification();
      }

      final payload = json.encode({
        'title': title,
        'body': body,
      });

      _notificationCount++;
      await _updateBadgeCount();

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'node_status_channel',
          title: title,
          body: body,
          payload: {'data': payload},
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Message,
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          autoDismissible: true,
          displayOnForeground: true,
          displayOnBackground: true,
          actionType: ActionType.Default,
          badge: _notificationCount,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'SHOW_DIALOG',
            label: 'Show Details',
            actionType: ActionType.Default,
            autoDismissible: true,
          ),
        ],
      );
    } catch (e) {
      logger.e('[NotificationService] Failed to show notification: $e');
    }
  }

  Future<void> _updateBadgeCount() async {
    try {
      await AwesomeNotifications().setGlobalBadgeCounter(_notificationCount);
      logger.i(
          '[NotificationService] Updated badge count to: $_notificationCount');
    } catch (e) {
      logger.e('[NotificationService] Failed to update badge count: $e');
    }
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    logger
        .i('[NotificationService] Handling notification tap with data: $data');
    _pendingPayload = data;
    _isAppResumed = false;

    if (_isAppResumed && navigatorKey.currentContext != null) {
      _showDialog();
    }
  }

  void onAppResumed() {
    logger.i('[NotificationService] App resumed');
    _isAppResumed = true;

    if (_pendingPayload != null) {
      _showDialog();
    }
  }

  void _showDialog() {
    if (_pendingPayload == null || navigatorKey.currentContext == null) {
      logger.w(
          '[NotificationService] Cannot show dialog: missing payload or context');
      return;
    }

    logger.i(
        '[NotificationService] Showing dialog with title: ${_pendingPayload!['title']}');

    WidgetsBinding.instance.ensureVisualUpdate();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!navigatorKey.currentContext!.mounted) {
        logger.w('[NotificationService] Context not mounted after delay');
        return;
      }

      try {
        logger.i('[NotificationService] Attempting to show dialog...');
        showDialog(
          context: navigatorKey.currentContext!,
          barrierDismissible: false,
          routeSettings: const RouteSettings(name: 'node_status_dialog'),
          builder: (BuildContext context) {
            logger.i('[NotificationService] Building dialog widget');
            return WillPopScope(
              onWillPop: () async => false,
              child: CustomDialog(
                type: DialogType.Warning,
                image: Icons.warning,
                title: _pendingPayload!['title'],
                description: _pendingPayload!['body'],
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      logger.i(
                          '[NotificationService] Dialog close button pressed');
                      Navigator.of(context).pop();
                      _decrementNotificationCount();
                    },
                  ),
                ],
              ),
            );
          },
        ).then((_) {
          logger.i('[NotificationService] Dialog shown successfully');
          _pendingPayload = null;
        }).catchError((error) {
          logger.e('[NotificationService] Error showing dialog: $error');
          _pendingPayload = null;
        });
      } catch (e) {
        logger.e('[NotificationService] Failed to show dialog: $e');
        _pendingPayload = null;
      }
    });
  }

  Future<void> _decrementNotificationCount() async {
    if (_notificationCount > 0) {
      _notificationCount--;
      await _updateBadgeCount();
    }
  }

  @pragma('vm:entry-point')
  Future<void> _onNotificationCreated(
      ReceivedNotification receivedNotification) async {
    logger.i('Notification created: ${receivedNotification.title}');
  }

  @pragma('vm:entry-point')
  Future<void> _onNotificationDisplayed(
      ReceivedNotification receivedNotification) async {
    logger.i('Notification displayed: ${receivedNotification.title}');
  }

  @pragma('vm:entry-point')
  Future<void> _onDismissActionReceived(ReceivedAction receivedAction) async {
    logger.i('Notification dismissed: ${receivedAction.title}');
    _decrementNotificationCount();
  }
}
