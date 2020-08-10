import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:threebotlogin/main.dart';

class FirebaseNotificationListener {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String token;
  FirebaseNotificationListener() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        logger.log('On message $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        logger.log('On launch $message');
      },
      onResume: (Map<String, dynamic> message) async {
        logger.log('On resume $message');
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      logger.log("Settings registered: $settings");
    });
  }
  getToken() {
    return _firebaseMessaging.getToken();
  }
}
