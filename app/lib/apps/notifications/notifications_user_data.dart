import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/helpers/logger.dart';

const String nodeStatusNotificationEnabledKey = 'nodeStatusNotificationEnabled';

Future<List<String>?> getNotificationSettings() async {
  final prefs = await SharedPreferences.getInstance();
  var notifications = prefs.getStringList('notifications');
  return notifications;
}

Future<bool> isNodeStatusNotificationEnabled() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(nodeStatusNotificationEnabledKey) ?? true;
  } catch (e) {
    return true;
  }
}

Future<void> setNodeStatusNotificationEnabled(bool value) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(nodeStatusNotificationEnabledKey, value);
  } catch (e) {
    logger.e('Error saving notification preference: $e');
  }
}
