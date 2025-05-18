import 'package:flutter/material.dart';
import 'package:threebotlogin/apps/notifications/notifications_user_data.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool loading = true;
  late bool _nodeStatusNotificationEnabled;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  void _loadNotificationPreference() async {
    final bool enabled = await isNodeStatusNotificationEnabled();
    setState(() {
      _nodeStatusNotificationEnabled = enabled;
      loading = false;
    });
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
                    setNodeStatusNotificationEnabled(newValue);
                  },
                  secondary: const Icon(Icons.monitor_heart),
                ),
              ],
            ),
    );
  }
}
