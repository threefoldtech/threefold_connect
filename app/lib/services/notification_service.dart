import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:threebotlogin/widgets/custom_dialog.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.payload != null) {
    NotificationService._handleNotificationTapStatic(
        notificationResponse.payload!);
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        if (notificationResponse.payload != null &&
            notificationResponse.id != null) {
          await _flutterLocalNotificationsPlugin
              .cancel(notificationResponse.id!);
          NotificationService._handleNotificationTapStatic(
              notificationResponse.payload!);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  static AndroidNotificationDetails _androidNotificationDetails(
      String groupKey) {
    return AndroidNotificationDetails(
      'channel ID',
      'channel name',
      channelDescription: 'channel description',
      importance: Importance.max,
      priority: Priority.high,
      groupKey: groupKey,
      setAsGroupSummary: false,
    );
  }

  static DarwinNotificationDetails _iOSNotificationDetails() {
    return const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
  }

  Future<void> showNotification({
    required String id,
    required String title,
    required String body,
    required String groupKey,
  }) async {
    final int notificationId = id.hashCode;
    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      NotificationDetails(
        android: _androidNotificationDetails(groupKey),
        iOS: _iOSNotificationDetails(),
      ),
      payload: jsonEncode({
        'title': title,
        'body': body,
        'groupKey': groupKey,
      }),
    );
    logger.i(
        '[NotificationService] Notification shown: ID $notificationId, Title: "$title"');
  }

  static void _handleNotificationTapStatic(String payload) async {
    logger.i(
        '[NotificationService Static] Notification tapped, payload: $payload');

    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      final String groupKey = data['groupKey'] as String;
      final String title = data['title'] as String;
      final String body = data['body'] as String;

      logger.i(
          '[NotificationService Static] Processing tapped notification with groupKey: $groupKey');

      // Wait for app to be in foreground if needed
      await Future.delayed(const Duration(milliseconds: 500));

      if (navigatorKey.currentContext != null) {
        if (groupKey == 'contract_alerts' ||
            groupKey == 'offline_nodes' ||
            groupKey == 'offline_workload_nodes') {
          await NotificationService.showContractAlertDialog(
            title: title,
            body: body,
          );
        }
      }
      return;
    } catch (e, stack) {
      logger.e(
          '[NotificationService Static] Error handling notification tap: $e',
          error: e,
          stackTrace: stack);
    }
  }

  static Future<void> showContractAlertDialog({
    required String title,
    required String body,
  }) async {
    if (navigatorKey.currentContext == null) {
      logger.w(
          '[NotificationService Static] Cannot show contract alert dialog, navigatorKey.currentContext is null.');
      return;
    }

    await NotificationService._showAppDialog(
      navigatorKey.currentContext!,
      title: title,
      content: Text(body),
      icon: Icons.assignment_outlined,
    );
    logger.i('[NotificationService Static] Dialog shown: $title');
  }

  static Future<void> showNodeAlertDialog({
    required String title,
    required String body,
  }) async {
    if (navigatorKey.currentContext == null) {
      logger.w(
          '[NotificationService Static] Cannot show node alert dialog, navigatorKey.currentContext is null.');
      return;
    }

    await NotificationService._showAppDialog(
      navigatorKey.currentContext!,
      title: title,
      content: Text(body),
      icon: Icons.power_off_outlined,
    );
    logger.i('[NotificationService Static] Dialog shown: $title');
  }

  static Future<void> _showAppDialog(
    BuildContext context, {
    required String title,
    required Text content,
    required IconData icon,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: CustomDialog(
            image: icon,
            title: title,
            description: content.data,
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
