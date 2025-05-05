import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _notificationsEnabled = true;

  static const String _notificationsEnabledKey = 'notificationsEnabled';

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  void _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    });
  }

  void _saveNotificationPreference(bool newValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: <Widget>[
          SwitchListTile(
            title: const Text('Enable Push Notifications'),
            value: _notificationsEnabled,
            onChanged: (bool newValue) {
              setState(() {
                _notificationsEnabled = newValue;
              });
              _saveNotificationPreference(newValue);

              if (newValue) {
                print('Notifications enabled. Implement subscription logic.');
              } else {
                 print('Notifications disabled. Implement unsubscription logic.');
              }
            },
            secondary: const Icon(Icons.notifications),
          ),
        ],
      ),
    );
  }
}
