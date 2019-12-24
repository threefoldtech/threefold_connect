import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/helpers/HexColor.dart';
import 'package:threebotlogin/screens/LoginScreen.dart';
import 'package:threebotlogin/screens/MobileRegistrationScreen.dart';
import 'package:threebotlogin/screens/RegisteredScreen.dart';
import 'package:threebotlogin/screens/UnregisteredScreen.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:package_info/package_info.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';
import 'package:uni_links/uni_links.dart';
import 'ErrorScreen.dart';
import 'RegistrationWithoutScanScreen.dart';
import 'package:threebotlogin/services/openKYCService.dart';
import 'dart:convert';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class HomeScreen extends StatefulWidget {
  final Widget homeScreen;

  HomeScreen({Key key, this.homeScreen}) : super(key: key);

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool openPendingLoginAttempt = true;
  String doubleName = '';
  var email;
  String initialLink;
  int selectedIndex = 0;
  AppBar appBar;
  BuildContext bodyContext;
  bool isLoading = false;
  bool showPreference = false;
  int failedApp;

  @override
  void initState() {
    getEmail().then((e) {
      setState(() {
        email = e;
      });
    });

    if (initialLink == null) {
      getLinksStream().listen((String incomingLink) {
        checkWhatPageToOpen(Uri.parse(incomingLink));
      });
    }

    super.initState();
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        //resize webview
      },
    );
    WidgetsBinding.instance.addObserver(this);
    onActivate(true);
  }

  Future<Null> initUniLinks() async {
    initialLink = await getInitialLink();

    if (initialLink != null) {
      checkWhatPageToOpen(Uri.parse(initialLink));
    }
  }

  checkWhatPageToOpen(Uri link) async {
    if (link.host == 'login') {
      var state = link.queryParameters['state'];
      var doubleName = await getDoubleName();
      if (doubleName != null) {
        Map<String, dynamic> data = {
          'doubleName': doubleName,
          'mobile': true,
          'firstTime': false,
          'sid': 'random',
          'state': state
        };

        bool autoLogin = false;
        var scope = jsonDecode(link.queryParameters['scope']);
        if (scope['trustedDevice'] != null) {
          var trustedDevice = scope['trustedDevice'];
          if (await isTrustedDevice(
              link.queryParameters['appId'], trustedDevice)) {
            print('you are logged in');
            autoLogin = true;
          }
        }

        return openPage(
            LoginScreen(link.queryParameters, autoLogin: autoLogin));
      } else {
        if (doubleName == null) {
          Navigator.popUntil(context, ModalRoute.withName('/'));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MobileRegistrationScreen(doubleName: '', link: link),
            ),
          );
        }
      }
    }
    if (link.host == 'register') {
      openPage(RegistrationWithoutScanScreen(link.queryParameters,
          resetPin: false, link: null));
    } else if (link.host == "registeraccount") {
      // Check if we already have an account registered before showing this screen.
      String doubleName = await getDoubleName();
      String privateKey = await getPrivateKey();

      if (doubleName == null || privateKey == null) {
        Navigator.popUntil(context, ModalRoute.withName('/'));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MobileRegistrationScreen(
                doubleName: link.queryParameters['doubleName'], link: null),
          ),
        );
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => CustomDialog(
            image: Icons.check,
            title: "You're already logged in",
            description: new Text(
                "We cannot create a new account, you already have an account registered on your device. Please restart the application if this message persists."),
            actions: <Widget>[
              FlatButton(
                child: new Text("Ok"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    }
  }

  openPage(page) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void checkIfThereAreLoginAttempts(dn) async {
    if (await getPrivateKey() != null && deviceId != null) {
      checkLoginAttempts(dn).then((attempt) {
        try {
          if (attempt.body != '' && openPendingLoginAttempt) {
            Navigator.popUntil(context, (route) {
              if (route.settings.name == "/" ||
                  route.settings.name == "/registered" ||
                  route.settings.name == "/preference") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(jsonDecode(attempt.body),
                        closeWhenLoggedIn: true),
                  ),
                );
              }
              return true;
            });
          }
        } catch (exception) {
          // We might need to handle this properly.
          logger.log(exception);
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onActivate(false);
    }
  }

  Future onActivate(bool initSocket) async {
    var buildNr = (await PackageInfo.fromPlatform()).buildNumber;

    int response = await checkVersionNumber(context, buildNr);

    if (response == 1) {
      String tmpDoubleName = await getDoubleName();
      if (initSocket) {
        // await createSocketConnection(context, tmpDoubleName);
      }

      checkIfThereAreLoginAttempts(tmpDoubleName);
      await initUniLinks();

      if (tmpDoubleName != null) {
        var sei = await getSignedEmailIdentifier();
        var email = await getEmail();

        if (sei != null &&
            sei.isNotEmpty &&
            email["email"] != null &&
            email["verified"]) {
        } else {
          getSignedEmailIdentifierFromOpenKYC(tmpDoubleName)
              .then((response) async {
            if (response.statusCode == 404) {
              return;
            }

            var body = jsonDecode(response.body);
            var signedEmailIdentifier = body["signed_email_identifier"];

            if (signedEmailIdentifier != null &&
                signedEmailIdentifier.isNotEmpty) {
              var vsei = json.decode(
                  (await verifySignedEmailIdentifier(signedEmailIdentifier))
                      .body);

              if (vsei != null &&
                  vsei["email"] == email["email"] &&
                  vsei["identifier"].toLowerCase() ==
                      tmpDoubleName.toLowerCase()) {
                await saveEmail(vsei["email"], true);
                await saveSignedEmailIdentifier(signedEmailIdentifier);
              } else {
                await saveEmail(email["email"], false);
                await removeSignedEmailIdentifier();
              }
            }
          });
        }

        if (mounted) {
          setState(() {
            doubleName = tmpDoubleName;
          });
        }
      }
    } else if (response == 0) {
      Navigator.pushReplacementNamed(context, '/error');
    } else if (response == -1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ErrorScreen(errorMessage: "Can't connect to server."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    appBar = AppBar(
      backgroundColor: HexColor("#2d4052"),
      elevation: 0.0,
    );

    return FutureBuilder(
      future: getDoubleName(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          this.bodyContext = context;
          return RegisteredScreen(
              isLoading: isLoading,
              selectedIndex: selectedIndex,
              routeToHome: this.routeToHome);
        } else {
          return UnregisteredScreen();
        }
      },
    );
  }

  void updatePreference(bool preference) {
    setState(() {
      this.showPreference = preference;
    });
  }

  void routeToHome() {
    setState(() {
      selectedIndex = 0;
      showPreference = false;
    });
  }
}
