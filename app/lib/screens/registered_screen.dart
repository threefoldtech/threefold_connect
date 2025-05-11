import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/chat_widget.dart';
import 'package:threebotlogin/widgets/home_card.dart';
import 'package:threebotlogin/widgets/home_logo.dart';

class RegisteredScreen extends StatefulWidget {
  static final RegisteredScreen _singleton = const RegisteredScreen._internal();

  factory RegisteredScreen() {
    return _singleton;
  }

  const RegisteredScreen._internal();

  @override
  State<RegisteredScreen> createState() => _RegisteredScreenState();
}

class _RegisteredScreenState extends State<RegisteredScreen>
    with WidgetsBindingObserver {
  bool showSettings = false;
  bool showPreference = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 45),
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
                  ],
                ),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeCardWidget(
                      name: 'Notification Settings',
                      icon: Icons.notifications,
                      pageNumber: 8,
                      fullWidth: true,
                    ),
                  ],
                ),
                const SizedBox(height: 70),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: CrispChatbot(),
                  ),
                ),
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
