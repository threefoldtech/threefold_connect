import 'package:flutter/material.dart';
import 'package:threebotlogin/router.dart';
import 'package:threebotlogin/screens/HomeScreen.dart';
import 'package:threebotlogin/screens/InitScreen.dart';
import 'package:threebotlogin/screens/UnregisteredScreen.dart';
import 'package:threebotlogin/services/socketService.dart';
import 'package:threebotlogin/widgets/ErrorWidget.dart';

class MainScreen extends StatefulWidget {
  final bool initDone;
  final bool registered;
  final String doubleName;
  final Router router = new Router();

  MainScreen({this.initDone, this.registered, router, this.doubleName});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<MainScreen> {
  _AppState();

  pushScreens() async {
    if (!widget.initDone) {
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => InitScreen()));
    }
    if (!widget.registered) {
      await Navigator.push(context,
          MaterialPageRoute(builder: (context) => UnregisteredScreen()));
    }

    await widget.router.init();
    //Here user is registered

    await createSocketConnection(context, widget.doubleName);
    
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(router: widget.router)));
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => pushScreens());
  }

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };

    return Container();
  }
}
