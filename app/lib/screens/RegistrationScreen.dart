import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';
import 'package:threebotlogin/widgets/PinField.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/widgets/Scanner.dart';

class RegistrationScreen extends StatefulWidget {
  final Widget registrationScreen;
  
  RegistrationScreen({Key key, this.registrationScreen}) : super(key: key);
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  String helperText = "In order to finish registration, scan QR code";
  AnimationController sliderAnimationController;
  Animation<double> offset;
  dynamic qrData = '';
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
                SizedBox(
                  width: 60.0,
                ),
                Text(
                  'REGISTRATION',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 21.0),
                ),
                FloatingActionButton(
                  tooltip: "What should I do?",
                  mini: true,
                  onPressed: () {
                    _showInformation();
                  },
                  child: Icon(Icons.help_outline),
                ),
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
                    child: qrData != ''
                        ? PinField(callback: (p) => pinFilledIn(p))
                        : null,
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
          Scanner(
            callback: (qr) => gotQrData(qr),
            context: context,
          ),
          Align(alignment: Alignment.bottomCenter, child: content()),
        ],
      ),
    );
  }

  gotQrData(value) async {
    setState(() {
      qrData = jsonDecode(value);
    });

    var hash = qrData['hash'];
    var doubleName = qrData['doubleName'];
    var email = qrData['email'];
    var phrase = qrData['phrase'];

    Map<String, String> keys = await generateKeysFromSeedPhrase(phrase);

    if (doubleName == null ||
        email == null ||
        phrase == null ||
        keys['privateKey'] == null) {
      showError();
    } else {
      var signedDeviceId = signData(deviceId, keys['privateKey']);
      sendScannedFlag(hash, await signedDeviceId, doubleName).then((response) {
        sliderAnimationController.forward();
        setState(() {
          helperText = "Choose new pin";
        });
      }).catchError((e) {
        print(e);
        showError();
      });
      updateDeviceId(
          await messaging.getToken(), doubleName, keys['privateKey']);
    }
  }

  showError() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Something went wrong, please try again later.'),
    ));
  }

  pinFilledIn(String value) async {
    if (pin == null) {
      setState(() {
        pin = value;
        helperText = 'Confirm pin';
      });
    } else if (pin != value) {
      setState(() {
        pin = null;
        helperText = 'Pins do not match, choose pin';
      });
    } else if (pin == value) {
      var scopeFromQR;
      scope['doubleName'] = qrData['doubleName'];

      if (qrData['scope'] != null) {
        print('scope of qrdata ${jsonDecode(qrData['scope'])}');
        scopeFromQR = jsonDecode(qrData['scope']);

        if (scopeFromQR.containsKey('email'))
          scope['email'] = {'email': qrData['email'], 'verified': false};
        if (scopeFromQR.containsKey('derivedSeed'))
          scope['derivedSeed'] = {'derivedSeed': qrData['derivedSeed']};
      }
      saveValues();
    }
  }

  saveValues() async {
    logger.log('save values');
    var hash = qrData['hash'];
    var doubleName = qrData['doubleName'];
    var email = qrData['email'];
    var phrase = qrData['phrase'];

    savePin(pin);

    Map<String, String> keys = await generateKeysFromSeedPhrase(phrase);

    savePrivateKey(keys['privateKey']);
    savePublicKey(keys['publicKey']);

    saveEmail(email, false);
    saveDoubleName(doubleName);
    savePhrase(phrase);
    saveFingerprint(false);
    if (keys['publicKey'] != null && hash != null) {
      try {
        var signedHash = signData(hash, keys['privateKey']);
        var data =
            encrypt(jsonEncode(scope), keys['publicKey'], keys['privateKey']);

        sendData(hash, await signedHash, await data, null).then((x) {
          Navigator.popUntil(context, ModalRoute.withName('/'));
          Navigator.of(context).pushNamed('/registered');
        });
      } catch (exception) {
        Navigator.popUntil(context, ModalRoute.withName('/'));
        showError();
      }
    } else {
      print('signing $doubleName');
      sendRegisterSign(doubleName);

      Navigator.popUntil(context, ModalRoute.withName('/'));
      Navigator.of(context).pushNamed('/registered');
    }
  }

  _showInformation() {
    var _stepsList =
        'Step 1: Go to the website: https://www.freeflowpages.com/  \n' +
            'Step 2: Create an account\n' +
            'Step 3: Scan the QR code\n';

    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        image: Icons.error,
        title: "Steps",
        description: new Text(
          _stepsList,
          textAlign: TextAlign.center,
          textScaleFactor: 1.2,
        ),
        actions: <Widget>[
          FlatButton(
            child: new Text("Continue"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
