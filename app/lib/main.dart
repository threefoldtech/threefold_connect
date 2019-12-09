import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:package_info/package_info.dart';
import 'package:threebotlogin/helpers/HexColor.dart';
import 'package:threebotlogin/screens/MobileRegistrationScreen.dart';
import 'package:threebotlogin/services/loggingService.dart';
import 'config.dart';
import 'package:threebotlogin/screens/HomeScreen.dart';
import 'package:threebotlogin/screens/RegistrationScreen.dart';
import 'package:threebotlogin/screens/SuccessfulScreen.dart';
import 'package:threebotlogin/screens/ErrorScreen.dart';
import 'package:threebotlogin/screens/RecoverScreen.dart';
import 'package:fast_qr_reader_view/fast_qr_reader_view.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/screens/ChangePinScreen.dart';

FirebaseMessaging messaging = FirebaseMessaging();
List<CameraDescription> cameras;
String pk;
String deviceId;
Config config;
LoggingService logger;
bool showButton;
List<FlutterWebviewPlugin> flutterWebViewPlugins = new List(6);
int lastAppUsed;
int keyboardUsedApp;
bool finger = false;
Color hexColor = Color(0xff0f296a);

String appName;
String packageName;
String version;
String buildNumber;
List<Map<String, dynamic>> apps = [];

Widget getErrorWidget(BuildContext context, FlutterErrorDetails error) {
  return SafeArea(
    child: Scaffold(
      backgroundColor: Color(0xff0f296a),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Oops something went wrong.",
                style: Theme.of(context)
                    .textTheme
                    .title
                    .copyWith(color: Colors.white),
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Text(
                'Please restart the application. If this error persists, please contact support.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .title
                    .copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void init() async {
  WidgetsFlutterBinding.ensureInitialized();
  PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  });

  logger = new LoggingService();
  showButton = false;

  pk = await getPrivateKey();

  try {
    cameras = await availableCameras();
  } on QRReaderException catch (e) {
    print(e);
  }

  messaging.requestNotificationPermissions();
  messaging.getToken().then((t) {
    deviceId = t;
    logger.log('Got device id $deviceId');
  });
}

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

String kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    config = Config.of(context);

    return MaterialApp(
      title: config.name,
      theme: ThemeData(
          primaryColor: HexColor("#2d4052"), accentColor: Color(0xff16a085)),
      routes: {
        '/': (context) => HomeScreen(),
        '/scan': (context) => RegistrationScreen(),
        '/register': (context) => RegistrationScreen(),
        '/success': (context) => SuccessfulScreen(registration: false),
        '/registered': (context) => SuccessfulScreen(registration: true),
        '/error': (context) => ErrorScreen(),
        '/recover': (context) => RecoverScreen(),
        '/changepin': (context) => ChangePinScreen(),
        '/registration': (context) => MobileRegistrationScreen()
      },
    );
  }
}
