import 'package:flutter/material.dart';
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
                  child: HomeLogoWidget(),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
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
                              color: Theme.of(context).colorScheme.onBackground,
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
                        pageNumber: 2,
                        fullWidth: true),
                  ],
                ),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeCardWidget(
                        name: 'Farming', icon: Icons.storage, pageNumber: 3),
                    HomeCardWidget(
                        name: 'Dao',
                        icon: Icons.how_to_vote_outlined,
                        pageNumber: 4),
                  ],
                ),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeCardWidget(
                        name: 'News', icon: Icons.article, pageNumber: 1),
                    HomeCardWidget(
                        name: 'Support', icon: Icons.build, pageNumber: 5),
                  ],
                ),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeCardWidget(
                        name: 'Identity', icon: Icons.person, pageNumber: 6),
                    HomeCardWidget(
                        name: 'Settings', icon: Icons.settings, pageNumber: 7),
                  ],
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
