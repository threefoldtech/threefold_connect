import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/home_card.dart';

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
        body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 100,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 250.0,
                height: 28.33,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onBackground,
                          BlendMode.srcIn),
                      fit: BoxFit.fill,
                      image: const AssetImage('assets/logoTF.png')),
                ),
              ),
              const SizedBox(height: 150),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.75,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      children: const <TextSpan>[
                        TextSpan(text: 'Welcome to the\n'),
                        TextSpan(
                            text: 'ThreeFold Connect App! \n',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ]),
                ),
              ),
              const Spacer(),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HomeCardWidget(
                      name: 'News', icon: Icons.article, pageNumber: 1),
                  HomeCardWidget(
                      name: 'Wallet',
                      icon: Icons.account_balance_wallet,
                      pageNumber: 2),
                  HomeCardWidget(
                      name: 'Farming', icon: Icons.fire_truck, pageNumber: 3),
                ],
              ),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HomeCardWidget(
                      name: 'Support', icon: Icons.chat, pageNumber: 4),
                  HomeCardWidget(
                      name: 'Identity',
                      icon: Icons.person_outlined,
                      pageNumber: 5),
                  HomeCardWidget(
                      name: 'Settings', icon: Icons.settings, pageNumber: 6),
                ],
              )
            ],
          ),
        ),
      ],
    ));
  }

  void updatePreference(bool preference) {
    setState(() {
      showPreference = preference;
    });
  }
}
