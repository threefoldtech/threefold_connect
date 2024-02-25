import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/screens/main_screen.dart';
import 'package:threebotlogin/widgets/home_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen(
      {super.key, required this.initDone, required this.registered});

  final bool initDone;
  final bool registered;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(
      const Duration(seconds: 2),
      () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => MainScreen(
                initDone: widget.initDone, registered: widget.registered)));
      },
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Hero(
          tag: 'logo',
          child: HomeLogoWidget(),
        ),
      ),
    );
  }
}
