import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/core/events/listeners/event.listeners.dart';
import 'package:google_fonts/google_fonts.dart';

import 'views/connection/views/connection.view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await initializeEventListeners();

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        tabBarTheme: TabBarTheme(labelStyle: GoogleFonts.lato(), unselectedLabelStyle: GoogleFonts.lato()),
        appBarTheme: AppBarTheme(color: Colors.white),
      ),
      home: ConnectionScreen(),
    );
  }
}
