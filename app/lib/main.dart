import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  ValueNotifier<bool> emailVerified = ValueNotifier(false);
  final Router router = new Router();

  /* Singleton */
  static final Globals _singleton = new Globals._internal();
  factory Globals() {
    return _singleton;
  }
  Globals._internal() {
    //initialize
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    cameras = await availableCameras();
  } on QRReaderException catch (e) {
    print(e);
  }
  bool initDone = await getInitDone();
  String doubleName = await getDoubleName();
  Globals().emailVerified.value = (await getSignedEmailIdentifier() != null);
  bool registered = doubleName != null;

  runApp(MyApp(initDone: initDone, registered: registered));
}

class MyApp extends StatelessWidget {
  MyApp({this.initDone, this.doubleName, this.registered});

  final bool initDone;
  final String doubleName;
  final bool registered;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primaryColor: HexColor("#2d4052"),
          accentColor: HexColor("#16a085"),
        ),
        home: MainScreen(initDone: initDone, registered: registered));
  }
}
