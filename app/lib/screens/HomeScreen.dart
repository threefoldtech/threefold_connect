import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:threebotlogin/helpers/HexColor.dart';
import 'package:threebotlogin/screens/LoginScreen.dart';
import 'package:threebotlogin/screens/MobileRegistrationScreen.dart';
import 'package:threebotlogin/screens/RegisteredScreen.dart';
import 'package:threebotlogin/screens/UnregisteredScreen.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/WebviewService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/services/firebaseService.dart';
import 'package:package_info/package_info.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';
import 'package:threebotlogin/widgets/BottomNavbar.dart';
import 'package:threebotlogin/widgets/CustomScaffold.dart';
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

  // We will treat this error as a singleton
  WebViewHttpError webViewError;

  // Hack to get the height of the bottom navbar
  final navbarKey = new GlobalKey<BottomNavBarState>();

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
        webViewResizer(visible, bodyContext, this.getPreferredSizeForWebview(),
            appBar.preferredSize);
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
    if (link.host == 'register') {
      openPage(RegistrationWithoutScanScreen(
        link.queryParameters,
        resetPin: false,
      ));
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
                doubleName: link.queryParameters['doubleName']),
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

  Future onActivate(bool initFirebase) async {
    var buildNr = (await PackageInfo.fromPlatform()).buildNumber;

    int response = await checkVersionNumber(context, buildNr);

    if (response == 1) {
      if (initFirebase) {
        initFirebaseMessagingListener(context);
      }

      String tmpDoubleName = await getDoubleName();

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

    return CustomScaffold(
      renderBackground: selectedIndex != 0,
      appBar: PreferredSize(
        child: appBar,
        preferredSize: Size.fromHeight(0),
      ),
      body: FutureBuilder(
        future: getDoubleName(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            this.bodyContext = context;
            return RegisteredScreen(
                isLoading: isLoading,
                openFfp: this.openFfp,
                selectedIndex: selectedIndex,
                routeToHome: this.routeToHome);
          } else {
            return UnregisteredScreen();
          }
        },
      ),
      footer: FutureBuilder(
        future: getDoubleName(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return BottomNavBar(
              key: navbarKey,
              selectedIndex: selectedIndex,
              onItemTapped: onItemTapped,
            );
          } else {
            return new Container(width: 0.0, height: 0.0);
          }
        },
      ),
    );
  }

  void onItemTapped(int index) {
    setState(() {
      isLoading = true;
      for (var flutterWebViewPlugin in flutterWebViewPlugins) {
        if (flutterWebViewPlugin != null) {
          flutterWebViewPlugin.hide();
        }
      }
      showPreference = false;
      if (!(apps[index]['openInBrowser'] && Platform.isIOS)) {
        selectedIndex = index;
      } else {
        selectedIndex = 0;
      }
    });
    this.launchWebviewApp(index);
  }

  void launchWebviewApp(int index) {
    updateApp(
      apps[index],
      flutterWebViewPlugins,
      this.getPreferredSizeForWebview(),
      appBar.preferredSize,
      this.routeToHome,
      selectedIndex,
      this.webviewReadyWithLoad,
      isLoading,
      bodyContext,
      failedApp,
    ).then((value) {}, onError: (error) {
      print(error);
      setState(() {
        isLoading = false;
      });
    });
  }

  void webviewReadyWithLoad(bool ready) async {
    if (ready) {
      setState(() {
        this.isLoading = false;
      });
      await flutterWebViewPlugins[selectedIndex].show();
    }
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

  void openFfp(int urlIndex) async {
    var ffpInstance = flutterWebViewPlugins[3];
    bool hadToStartInstance = false;
    bool callbackSuccess = false;

    setState(() {
      for (var flutterWebViewPlugin in flutterWebViewPlugins) {
        if (flutterWebViewPlugin != null &&
            ffpInstance != flutterWebViewPlugin) {
          flutterWebViewPlugin.dispose();
        }
      }
      selectedIndex = 3;
    });

    if (ffpInstance == null) {
      setState(() {
        isLoading = true;
      });
      this.launchWebviewApp(3);
      ffpInstance = flutterWebViewPlugins[3];
      hadToStartInstance = true;
    }

    if (ffpInstance != null) {
      if (hadToStartInstance) {
        ffpInstance.onStateChanged.listen((viewData) async {
          if (viewData.type == WebViewState.finishLoad && !callbackSuccess) {
            await ffpInstance.evalJavascript("window.location.href = \"" +
                apps[3]['ffpUrls'][urlIndex] +
                "\"");
            callbackSuccess = true;
          }
        });
      } else {
        var url = apps[3]['ffpUrls'][urlIndex];

        await ffpInstance.reloadUrl(url);
        return ffpInstance.show();
      }
    }
  }

  Size getBottomNavbarHeight() {
    final State state = navbarKey.currentState;
    final RenderBox box = state.context.findRenderObject();

    return box.size;
  }

  Size getPreferredSizeForWebview() {
    var contextSize = MediaQuery.of(bodyContext).size;

    var preferredHeight = contextSize.height -
        appBar.preferredSize.height -
        getBottomNavbarHeight().height;
    var preferredWidth = contextSize.width;

    return new Size(preferredWidth, preferredHeight);
  }
}
