import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanScreen extends StatefulWidget {
  final Widget registrationScreen;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  ScanScreen({Key key, this.registrationScreen}) : super(key: key);
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  String helperText = "Aim at QR code to scan";
  AnimationController sliderAnimationController;
  Animation<double> offset;
  bool popped = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;

  String pin;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var scope = Map();
  var keys;

  @override
  void initState() {
    super.initState();
    sliderAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1));
    sliderAnimationController.addListener(() {
      this.setState(() {});
    });

    offset = Tween<double>(begin: 0.0, end: 500.0).animate(CurvedAnimation(
        parent: sliderAnimationController, curve: Curves.bounceOut));
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!popped) {
        popped = true;
        Navigator.pop(context, scanData);
      }
    });
  }

  Widget content() {
    double height = MediaQuery.of(context).size.height;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0))),
            padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FloatingActionButton(
                  tooltip: "Go back",
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  mini: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back_ios),
                ),
                Text(
                  'Scan QR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 21.0),
                ),
                SizedBox(width: 60.0,)
              ],
            ),
          ),
        ),
        Container(
          color: Theme.of(context).primaryColor,
          child: Container(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0))),
              padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: height / 100, bottom: 12),
                    child: Center(
                      child: Text(
                        helperText,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 100),
                    padding: EdgeInsets.only(bottom: 12),
                    curve: Curves.bounceInOut,
                    width: double.infinity,
                    child: null,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          Align(alignment: Alignment.bottomCenter, child: content()),
        ],
      ),
    );
  }

  showError() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Something went wrong, please try again later.'),
    ));
  }
}
