import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/HexColor.dart';
import 'package:threebotlogin/router.dart';
import 'package:threebotlogin/screens/MainScreen.dart';

import 'package:threebotlogin/services/loggingService.dart';
import 'package:fast_qr_reader_view/fast_qr_reader_view.dart';
import 'package:threebotlogin/services/userService.dart';

List<CameraDescription> cameras;
LoggingService logger;

class Globals {
  static final isInDebugMode = true;
  static final color = HexColor("#2d4052");
}

// Hack to get the height of the bottom navbar
/*Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on QRReaderException catch (e) {
    print(e);
  }

  final prefs = await SharedPreferences.getInstance();
  bool initDone =
      prefs.getBool('initDone') != null && prefs.getBool('initDone');

  var email = await getEmail();

  AppWidget app = new AppWidget(initDone: initDone, registered: email == null);

  await app.init();

  runApp(app);
}*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool initDone = await getInitDone();
  String doubleName = await getDoubleName();
  bool registered = doubleName != null;
  Router router = new Router();
  await router.init();
  runApp(MyApp(initDone: initDone, registered: registered, router: router));
}

class MyApp extends StatelessWidget {
  MyApp({this.initDone, this.doubleName, this.registered, this.router});

  final bool initDone;
  final String doubleName;
  final bool registered;
  final Router router;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        theme: ThemeData(
          primaryColor: HexColor("#2d4052"), //@todo theme obj,
        ),
        home: new MainScreen(
            initDone: initDone, registered: registered, router: router));
  }
}
