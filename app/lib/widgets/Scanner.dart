import 'dart:ui';

import 'package:fast_qr_reader_view/fast_qr_reader_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/main.dart';

class Scanner extends StatefulWidget {
  final Widget scanner;
  final callback;
  final context;

  Scanner({Key key, this.scanner, this.callback, this.context})
      : super(key: key);

  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> with TickerProviderStateMixin {
  QRReaderController controller;
  AnimationController animationController;
  Animation<double> verticalPosition;

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
      duration: new Duration(seconds: 1),
      vsync: this,
    );
    verticalPosition = Tween<double>(begin: 20.0, end: 180.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.linear))
      ..addStatusListener((state) {
        if (state == AnimationStatus.completed) {
          animationController.reverse();
        } else if (state == AnimationStatus.dismissed) {
          animationController.forward();
        }
      });

    animationController.forward();
    animationController.addListener(() {
      this.setState(() {});
    });
    onNewCameraSelected(cameras[0]);
  }

  Widget finder() {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    return Container(
      child: controller.value.isInitialized
          ? Transform.scale(
              scale: controller.value.aspectRatio / deviceRatio,
              child: Center(
                child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: Container(
                      width: size.width,
                      height: size.height,
                      child: QRReaderPreview(controller),
                    )),
              ),
            )
          : Container(
              color: Colors.black,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
              ),
            ),
    );
  }

  Widget finderx() {
    return Stack(
      alignment: FractionalOffset.topCenter,
      children: <Widget>[
        finder(),
        animationController.isAnimating
            ? Center(
                child: Container(
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.all(100),
                    child: Image.asset('assets/qr.png')))
            : BackdropFilter(
                child: new AnimatedContainer(
                  duration: Duration(milliseconds: 100),
                  decoration:
                      new BoxDecoration(color: Colors.white.withOpacity(0.0)),
                ),
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              ),
      ],
    );
  }

  Future onCodeRead(dynamic value) async {
    HapticFeedback.mediumImpact();
    animationController.stop();
    controller.stopScanning();

    widget.callback(value);
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    bool initiated = false;
    if (controller != null) {
      await controller.dispose();
    }
    controller = new QRReaderController(cameraDescription,
        ResolutionPreset.high, [CodeFormat.qr, CodeFormat.pdf417], onCodeRead);
    controller.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await controller.initialize();
      initiated = true;
    } on Exception catch (e) {
      logger.log(e);
    }

    if (mounted && initiated) {
      controller.startScanning();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[finder(), finderx()],
    );
  }
}
