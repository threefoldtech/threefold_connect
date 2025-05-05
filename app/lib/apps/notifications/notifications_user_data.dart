import 'package:shared_preferences/shared_preferences.dart';


Future<List<String>?> getNotificationSettings() async {
  final prefs = await SharedPreferences.getInstance();
  var notifications = prefs.getStringList('notifications');
  return notifications;
}