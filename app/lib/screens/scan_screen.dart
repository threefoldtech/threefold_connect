import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String helperText = 'Aim at QR code to scan';
  bool popped = false;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

  void _onQRViewCreated(QRViewController controller) {
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
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0))),
            padding:
                const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FloatingActionButton(
                  tooltip: 'Go back',
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  mini: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_ios),
                ),
                const Text(
                  'Scan QR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 21.0),
                ),
                const SizedBox(
                  width: 60.0,
                )
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
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0))),
              padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: height / 100, bottom: 12),
                    child: Center(
                      child: Text(
                        helperText,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    padding: const EdgeInsets.only(bottom: 12),
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
}
