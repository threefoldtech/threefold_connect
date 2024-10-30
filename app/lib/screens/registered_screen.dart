import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/chat_widget.dart';
import 'package:threebotlogin/widgets/home_card.dart';
import 'package:threebotlogin/widgets/home_logo.dart';

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
                                  'ThreeFold Connect App is 2FA authenticator. '),
                          TextSpan(
                              text:
                                  'By using ThreeFold Connect you can ensure that a user is who the say they are.'),
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
                        name: 'News', icon: Icons.article, pageNumber: 1),
                  ],
                ),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeCardWidget(
                        name: 'Identity', icon: Icons.person, pageNumber: 5),
                    HomeCardWidget(
                        name: 'Settings', icon: Icons.settings, pageNumber: 6),
                  ],
                ),
                const SizedBox(height: 40),
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
