import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/chat_widget.dart';
import 'package:threebotlogin/widgets/home_card.dart';
import 'package:threebotlogin/widgets/home_logo.dart';
import 'package:threebotlogin/services/notification_service.dart'; // Import NotificationService

class RegisteredScreen extends StatefulWidget {
  static final RegisteredScreen _singleton = RegisteredScreen._internal();

  factory RegisteredScreen() {
    return _singleton;
  }

  RegisteredScreen._internal() {
    //init
  }

  @override
  State<RegisteredScreen> createState() => _RegisteredScreenState();
}

class _RegisteredScreenState extends State<RegisteredScreen>
    with WidgetsBindingObserver {
  // We will treat this error as a singleton

  bool showSettings = false;
  bool showPreference = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/map.png',
                  fit: BoxFit.cover,
                ),
                const Hero(
                  tag: 'logo',
                  child: HomeLogoWidget(
                    animate: false,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 50),
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.2,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        children: const <TextSpan>[
                          TextSpan(
                              text:
                                  'Your portal to ThreeFold: access your wallets, your digital identity, your farms, and ThreeFold updates with ease.'),
                        ]),
                  ),
                ),
                const Spacer(),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeCardWidget(
                        name: 'Wallet',
                        icon: Icons.account_balance_wallet,
                        pageNumber: 2),
                    HomeCardWidget(
                        name: 'Farming', icon: Icons.storage, pageNumber: 3),
                  ],
                ),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeCardWidget(
                        name: 'Dao',
                        icon: Icons.how_to_vote_outlined,
                        pageNumber: 4),
                    HomeCardWidget(
                        name: 'Sign', icon: Icons.draw_sharp, pageNumber: 8),
                  ],
                ),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeCardWidget(
                        name: 'News', icon: Icons.article, pageNumber: 1),
                    HomeCardWidget(
                        name: 'Identity', icon: Icons.person, pageNumber: 5),
                  ],
                ),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeCardWidget(
                        name: 'Settings', icon: Icons.settings, pageNumber: 6),
                    HomeCardWidget(
                        name: 'Notifications',
                        icon: Icons.notifications,
                        pageNumber: 9),
                  ],
                ),
                const SizedBox(height: 20), // Added some spacing
                // --- START: Notification Test Button ---
                ElevatedButton(
                  onPressed: () {
                    // Manually trigger a contract alert notification
                    NotificationService().showNotification(
                      id: 'test_contract_1',
                      title: 'Test Contract Alert! 🧪',
                      body: 'This is a test contract notification.',
                      groupKey: 'contract_alerts',
                    );
                    // Manually trigger an offline node notification
                    NotificationService().showNotification(
                      id: 'test_node_1',
                      title: 'Test Node Offline! 🚨',
                      body: 'This is a test node offline notification.',
                      groupKey: 'offline_nodes',
                    );
                  },
                  child: const Text('Show Test Notifications'),
                ),
                const SizedBox(height: 20), // Added some spacing
                // --- END: Notification Test Button ---
                const Row(
                  children: [Spacer(), CrispChatbot(), SizedBox(width: 20)],
                )
              ],
            ),
          )
        ],
      ),
    ));
  }

  void updatePreference(bool preference) {
    setState(() {
      showPreference = preference;
    });
  }
}
