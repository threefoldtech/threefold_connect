import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/Init.dart';
import 'package:threebotlogin/helpers/HexColor.dart';
import 'package:threebotlogin/router.dart';
import 'package:threebotlogin/screens/ChangePinScreen.dart';
import 'package:threebotlogin/screens/ErrorScreen.dart';
import 'package:threebotlogin/screens/MobileRegistrationScreen.dart';
import 'package:threebotlogin/screens/RecoverScreen.dart';
import 'package:threebotlogin/screens/RegistrationScreen.dart';
import 'package:threebotlogin/screens/SuccessfulScreen.dart';
import 'package:threebotlogin/services/loggingService.dart';
import 'package:fast_qr_reader_view/fast_qr_reader_view.dart';

List<CameraDescription> cameras;
String pk;
String deviceId;
LoggingService logger;
bool finger = false;
Color hexColor = Color(0xff0f296a);
int selectedIndex = 0;
String appName;
String packageName;
String version;
String buildNumber;
List<String> apps = ['/', '/wallet', '/ffp', '/settings'];

// Hack to get the height of the bottom navbar
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on QRReaderException catch (e) {
    print(e);
  }

  final prefs = await SharedPreferences.getInstance();
  bool initDone =
      prefs.getBool('initDone') != null && prefs.getBool('initDone');
  AppWidget app = new AppWidget(initDone: initDone);
  await app.init();

  runApp(app);
}

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

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

String kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';

class AppWidget extends StatefulWidget {
  final bool initDone;
  final Router router = new Router();
  _AppState state;

  AppWidget({this.initDone, router});

  init() async {
    await router.init();
  }

  finish() {
    state.finish();
  }

  @override
  _AppState createState() {
    state = _AppState(initDone: this.initDone, router: this.router);
    return state;
  }
}

class _AppState extends State<AppWidget> {
  bool initDone;
  Router router;

  _AppState({this.initDone, this.router});

  finish() {
    setState(() {
      this.initDone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };

    Color primaryColor = HexColor("#2d4052");

    var tabs = MaterialApp(
      theme: ThemeData(
        primaryColor: primaryColor,
      ),
      routes: {
        '/scan': (context) => RegistrationScreen(),
        '/success': (context) => SuccessfulScreen(registration: false),
        '/registered': (context) => SuccessfulScreen(registration: true),
        '/error': (context) => ErrorScreen(),
        '/recover': (context) => RecoverScreen(),
        '/changepin': (context) => ChangePinScreen(),
        '/registration': (context) => MobileRegistrationScreen()
      },
      home: DefaultTabController(
        length: router.routes.length,
        child: Scaffold(
          body: SafeArea(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: router.getContent(),
            ),
          ),
          bottomNavigationBar: Container(
            color: primaryColor,
            padding: EdgeInsets.all(0.0),
            height: 65,
            margin: EdgeInsets.all(0.0),

            child: TabBar(
              isScrollable: false,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: router.getIconButtons(),
              labelPadding: EdgeInsets.all(0.0),
              indicatorPadding: EdgeInsets.all(0.0),
            ),
          ),
        ),
      ),
    );

    if (!initDone) {
      print("init widget");
      return InitWidget(this.widget);
    }
    return tabs;
  }
}
