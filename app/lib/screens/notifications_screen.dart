import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late bool loading;
  late bool _nodeStatusNotificationEnabled;
  static const String _nodeStatusNotificationEnabledKey =
      'nodeStatusNotificationEnabled';

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  void _loadNotificationPreference() async {
    setState(() {
      loading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nodeStatusNotificationEnabled =
          prefs.getBool(_nodeStatusNotificationEnabledKey) ?? true;
      loading = false;
    });
  }

  void _setNodeStatusNotification(bool newValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_nodeStatusNotificationEnabledKey, newValue);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutDrawer(
      titleText: 'Notifications',
      content: _buildNotificationSettings(),
    );
  }

  Widget _buildNotificationSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 15),
                  Text(
                    'Loading notifications settings...',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : Column(
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
                  secondary: const Icon(Icons.monitor_heart),
                ),
              ],
            ),
    );
  }
}
