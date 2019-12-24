import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/HexColor.dart';
import 'package:threebotlogin/router.dart';
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
void main() => runApp(MyApp());

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

class MyApp extends StatelessWidget {
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
      home: DefaultTabController(
        length: Router().routes.length,
        child: Scaffold(
          body: SafeArea(
            child: TabBarView(children: Router().getContent()),
          ),
          bottomNavigationBar: Container(
            color: primaryColor,
            child: TabBar(
              tabs: Router().getIconButtons(),
            ),
          ),
        ),
      ),
    );
    return tabs;
  }
}
