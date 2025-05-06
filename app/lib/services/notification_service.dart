import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initNotification() async {
    if (_isInitialized) return;

    final NotificationAppLaunchDetails? launchDetails =
        await notificationsPlugin.getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _handleNotificationTap(launchDetails?.notificationResponse);
    }

    const initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) =>
          _handleNotificationTap(details),
    );
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

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

      final androidDetails = AndroidNotificationDetails(
        'node_status_channel',
        'Node Status',
        channelDescription: 'Notify user when node goes offline',
        importance: Importance.max,
        priority: Priority.high,
        groupKey: groupKey,
      );

      final iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          threadIdentifier: groupKey,
          interruptionLevel: InterruptionLevel.timeSensitive);

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final payload = json.encode({
        'title': title,
        'body': body,
      });

      await notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      logger.e('[NotificationService] Failed to show notification: $e');
    }
  }

  void _handleNotificationTap(NotificationResponse? response) {
    if (response?.payload != null) {
      final Map<String, dynamic> payload = json.decode(response!.payload!);
      showNodeStatusDialog(
        navigatorKey.currentContext!,
        payload['title'],
        payload['body'],
      );
    }
  }

  void showNodeStatusDialog(BuildContext context, String title, String body) {
    try {
      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          type: DialogType.Warning,
          image: Icons.warning,
          title: title,
          description: body,
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
    } catch (e) {
      logger.e('[NotificationService] Failed to show dialog: $e');
    }
  }
}
