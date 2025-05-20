import 'package:shared_preferences/shared_preferences.dart';

const String nodeStatusNotificationEnabledKey = 'nodeStatusNotificationEnabled';
const String _contractNotificationsEnabledKey =
    'contract_notifications_enabled';

Future<List<String>?> getNotificationSettings() async {
  final prefs = await SharedPreferences.getInstance();
  var notifications = prefs.getStringList('notifications');
  return notifications;
}

Future<bool> isNodeStatusNotificationEnabled() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(nodeStatusNotificationEnabledKey) ?? true;
}

Future<void> setNodeStatusNotificationEnabled(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(nodeStatusNotificationEnabledKey, value);
}

Future<bool> isContractNotificationEnabled() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_contractNotificationsEnabledKey) ?? true;
}

Future<void> setContractNotificationEnabled(bool enabled) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_contractNotificationsEnabledKey, enabled);
}
