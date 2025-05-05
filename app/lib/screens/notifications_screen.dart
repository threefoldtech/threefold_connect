import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _nodeStatusNotificationEnabled = true;

  static const String _nodeStatusNotificationEnabledKey =
      'nodeStatusNotificationEnabled';

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  void _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nodeStatusNotificationEnabled =
          prefs.getBool(_nodeStatusNotificationEnabledKey) ?? true;
    });
  }

  void _setNodeStatusNotification(bool newValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_nodeStatusNotificationEnabledKey, newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SwitchListTile(
            title: const Text('Enable node status notifications'),
            value: _nodeStatusNotificationEnabled,
            onChanged: (bool newValue) {
              setState(() {
                _nodeStatusNotificationEnabled = newValue;
              });
              _setNodeStatusNotification(newValue);
            },
            secondary: const Icon(Icons.notifications),
          ),
        ],
      ),
    );
  }
}
