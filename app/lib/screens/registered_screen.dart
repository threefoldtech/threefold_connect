import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Image.asset(
                'assets/map.png',
                fit: BoxFit.cover,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/TF_logo.svg',
                      alignment: Alignment.center,
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onBackground,
                          BlendMode.srcIn),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Divider(
                        thickness: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      'ThreeFold Connect App',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.2,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
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
                      name: 'News', icon: Icons.article, pageNumber: 1),
                  HomeCardWidget(
                      name: 'Wallet',
                      icon: Icons.account_balance_wallet,
                      pageNumber: 2),
                  HomeCardWidget(
                      name: 'Farming',
                      icon: Icons.fire_truck_outlined,
                      pageNumber: 3),
                ],
              ),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HomeCardWidget(
                      name: 'Support', icon: Icons.chat, pageNumber: 4),
                  HomeCardWidget(
                      name: 'Identity', icon: Icons.person, pageNumber: 5),
                  HomeCardWidget(
                      name: 'Settings', icon: Icons.settings, pageNumber: 6),
                ],
              ),
            ],
          ),
        )
      ],
    ));
  }

  void updatePreference(bool preference) {
    setState(() {
      showPreference = preference;
    });
  }
}
