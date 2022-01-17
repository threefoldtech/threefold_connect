import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:threebotlogin/apps/wallet/wallet_config.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/pop_all_login_event.dart';
import 'package:threebotlogin/helpers/block_and_run_mixin.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/models/login.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/tools_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/widgets/image_button.dart';
import 'package:threebotlogin/widgets/preference_dialog.dart';
import 'package:flutter_sodium/flutter_sodium.dart';

class LoginScreen extends StatefulWidget {
  final Login loginData;

  LoginScreen(this.loginData);

  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with BlockAndRunMixin {
  String scopeTextMobile = 'Please select the data you want to share and press Accept';
  String scopeText = 'Please select the data you want to share and press the corresponding emoji';

  List<int> imageList = [];

  int selectedImageId = -1;
  int correctImage = -1;

  bool cancelBtnVisible = true;
  bool showScopeAndEmoji = true;
  bool isMobileCheck = false;

  String emitCode = randomString(10);

  late Timer timer;

  int timeLeft = Globals().loginTimeout;

  int? created = 0;
  int? currentTimestamp = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Events().onEvent(PopAllLoginEvent("").runtimeType, close);
    isMobileCheck = widget.loginData.isMobile == true;
    generateEmojiImageList();

    if (widget.loginData.isMobile == false) {
      const oneSec = const Duration(seconds: 1);
      print('Starting timer ... ');

      created = widget.loginData.created;
      currentTimestamp = new DateTime.now().millisecondsSinceEpoch;

      timeLeft = Globals().loginTimeout - ((currentTimestamp! - created!) / 1000).round();

      timer = new Timer.periodic(oneSec, (Timer t) async {
        timeoutTimer();
      });
    }
  }

  timeoutTimer() async {
    if (!mounted) {
      timer.cancel();
      return;
    }

    currentTimestamp = new DateTime.now().millisecondsSinceEpoch;

    setState(() {
      timeLeft = Globals().loginTimeout - ((currentTimestamp! - created!) / 1000).round();
    });

    if (created != null && ((currentTimestamp! - created!) / 1000) > Globals().loginTimeout) {
      timer.cancel();

      await showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          image: Icons.timer,
          title: 'Login attempt expired',
          description: 'Your login attempt has expired, please request a new one in your browser.',
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      );

      Navigator.pop(context, false);
    }
  }

  Widget scopeEmojiView() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 24.0, left: 24.0),
                  child: Text(
                    isMobileCheck ? scopeTextMobile : scopeText,
                    style: TextStyle(fontSize: 14.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: SizedBox(
                child: PreferenceDialog(
                  scope: widget.loginData.scope,
                  appId: widget.loginData.appId,
                  callback: cancelIt,
                  type: widget.loginData.isMobile == true ? 'mobilelogin' : 'login',
                ),
              ),
            ),
            Visibility(
              visible: !isMobileCheck,
              child: Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ImageButton(imageList[0], selectedImageId, imageSelectedCallback),
                      ImageButton(imageList[1], selectedImageId, imageSelectedCallback),
                      ImageButton(imageList[2], selectedImageId, imageSelectedCallback),
                      ImageButton(imageList[3], selectedImageId, imageSelectedCallback),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: isMobileCheck,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 11.0, vertical: 6.0),
                  color: Theme.of(context).accentColor,
                  child: Text(
                    'Accept',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  onPressed: () async {
                    await sendIt(true);
                  },
                ),
              ),
            ),
            Visibility(
              visible: widget.loginData.isMobile == false,
              child: Expanded(
                flex: 1,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24.0, left: 24.0),
                    child: Text(
                      "Attempt expires in " +
                          ((timeLeft >= 0) ? timeLeft.toString() : "0") +
                          " second(s).",
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          // automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).primaryColor,
          title: new Text("Login"),
        ),
        body: Column(
          children: <Widget>[
            Visibility(
              visible: showScopeAndEmoji,
              child: Expanded(flex: 6, child: scopeEmojiView()),
            ),
            Visibility(
              visible: cancelBtnVisible,
              child: Expanded(
                flex: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton(
                    child: Text(
                      "It wasn\'t me - cancel",
                      style: TextStyle(fontSize: 16.0, color: Color(0xff0f296a)),
                    ),
                    onPressed: () {
                      cancelIt();
                      Navigator.pop(context, false);
                      Events().emit(PopAllLoginEvent(emitCode));
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      onWillPop: () {
        cancelIt();
        return Future.value(true);
      },
    );
  }

  imageSelectedCallback(imageId) {
    blockAndRun(() async {
      setState(() {
        selectedImageId = imageId;
      });

      if (selectedImageId != -1) {
        if (selectedImageId == correctImage) {
          await sendIt(true);
        } else {
          await sendIt(false);

          await showDialog(
            context: context,
            builder: (BuildContext context) => CustomDialog(
              image: Icons.warning,
              title: 'Wrong emoji',
              description:
                  'You selected the wrong emoji, please check your browser for the new one.',
              actions: <Widget>[
                FlatButton(
                  child: Text('Retry'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          );

          if (Navigator.canPop(context)) {
            Navigator.pop(context, false);
          }
        }
      } else {
        _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text('Please select an emoji')));
      }
    });
  }

  close(PopAllLoginEvent e) {
    if (e.emitCode == emitCode) {
      return;
    }

    if (mounted) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context, false);
      }
    }
  }

  cancelIt() async {
    cancelLogin(await getDoubleName());
  }

  sendIt(bool includeData) async {
    String? state = widget.loginData.state;
    String? randomRoom = widget.loginData.randomRoom;

    print('HALLO22');
    if (widget.loginData.isMobile == false) {
      int? created = widget.loginData.created;
      int currentTimestamp = new DateTime.now().millisecondsSinceEpoch;

      if (created != null && ((currentTimestamp - created) / 1000) > Globals().loginTimeout) {
        await showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
            image: Icons.timer,
            title: 'Login attempt expired',
            description: 'We cannot sign this login attempt because it has expired.',
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
        );

        print('IK KOM HIER');
        print(state);
        print(widget.loginData.appId);
        await sendData(state!, null, selectedImageId, null, widget.loginData.appId!);

        if (Navigator.canPop(context)) {
          Navigator.pop(context, false);
        }
        return;
      }
    }

    String publicKey = widget.loginData.appPublicKey!.replaceAll(" ", "+");
    print('Public key');
    print(publicKey);

    bool stateCheck = RegExp(r"[^A-Za-z0-9]+").hasMatch(state!);

    if (stateCheck) {
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('States can only be alphanumeric [^A-Za-z0-9]'),
        ),
      );
      return;
    }

    Map<String, dynamic> scope = Map<String, dynamic>();
    var scopePermissions = await getPreviousScopePermissions(widget.loginData.appId!);

    Uint8List derivedSeed = (await getDerivedSeed(widget.loginData.appId!));

    //TODO: make separate function
    if (scopePermissions != null) {
      var scopePermissionsDecoded = jsonDecode(scopePermissions);




      if (scopePermissions != null && scopePermissions != "") {
        if (scopePermissionsDecoded['email'] != null && scopePermissionsDecoded['email']) {
          scope['email'] = (await getEmail());
        }

        if (scopePermissionsDecoded['phone'] != null && scopePermissionsDecoded['phone']) {
          scope['phone'] = (await getPhone());
        }

        if (scopePermissionsDecoded['derivedSeed'] != null &&
            scopePermissionsDecoded['derivedSeed']) {
          scope['derivedSeed'] = derivedSeed;
        }

        if (scopePermissionsDecoded['digitalTwin'] != null &&
            scopePermissionsDecoded['digitalTwin']) {
          scope['digitalTwin'] = 'ok';
        }

        if (scopePermissionsDecoded['identityName'] != null &&
            scopePermissionsDecoded['identityName']) {
          scope['identityName'] = {
            'identityName': ((await getIdentity())['identityName']),
            'signedIdentityNameIdentifier': ((await getIdentity())['signedIdentityNameIdentifier'])
          };
        }

        if (scopePermissionsDecoded['identityDOB'] != null &&
            scopePermissionsDecoded['identityDOB']) {
          scope['identityDOB'] = {
            'identityDOB': ((await getIdentity())['identityDOB']),
            'signedIdentityDOBIdentifier': ((await getIdentity())['signedIdentityDOBIdentifier'])
          };
        }

        if (scopePermissionsDecoded['identityCountry'] != null &&
            scopePermissionsDecoded['identityCountry']) {
          scope['identityCountry'] = {
            'identityCountry': ((await getIdentity())['identityCountry']),
            'signedIdentityCountryIdentifier':
                ((await getIdentity())['signedIdentityCountryIdentifier'])
          };
        }

        if (scopePermissionsDecoded['identityDocumentMeta'] != null &&
            scopePermissionsDecoded['identityDocumentMeta']) {
          scope['identityDocumentMeta'] = {
            'identityDocumentMeta': ((await getIdentity())['identityDocumentMeta']),
            'signedIdentityDocumentMetaIdentifier':
                ((await getIdentity())['signedIdentityDocumentMetaIdentifier'])
          };
        }

        if (scopePermissionsDecoded['identityGender'] != null &&
            scopePermissionsDecoded['identityGender']) {
          scope['identityGender'] = {
            'identityGender': ((await getIdentity())['identityGender']),
            'signedIdentityGenderIdentifier':
                ((await getIdentity())['signedIdentityGenderIdentifier'])
          };
        }

        if (scopePermissionsDecoded['walletAddress'] != null &&
            scopePermissionsDecoded['walletAddress']) {
          scope['walletAddressData'] = {
            'address': scopePermissionsDecoded['walletAddressData'],
          };
        }
      }
    }


    print('Encoded scope');
    print(jsonEncode(scope));

    Map<String, String> encryptedScopeData =
        await encrypt(jsonEncode(scope), base64.decode(publicKey), await getPrivateKey());

    print(widget.loginData.appId);
    print(encryptedScopeData);
    //push to backend with signed
    if (!includeData) {
      await sendData(state, null, selectedImageId, null,
          widget.loginData.appId!); // temp fix send empty data for regenerate emoji
    } else {
      print('IK KOM IN DEZE');
      await sendData(
          state, encryptedScopeData, selectedImageId, randomRoom, widget.loginData.appId!);
    }

    if (selectedImageId == correctImage || isMobileCheck) {
      // Only update data if the correct image was chosen:
      print("derivedSeed: " + base64.encode(derivedSeed));
      var name = await getDoubleName();
      KeyPair dtKeyPair = await generateKeyPairFromEntropy(derivedSeed);

      String dtEncodedPublicKey = base64.encode(dtKeyPair.pk);
      print("name: " + name!);
      print("publicKey: " + dtEncodedPublicKey);
      addDigitalTwinDerivedPublicKeyToBackend(name, dtEncodedPublicKey, widget.loginData.appId);

      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }

      Events().emit(PopAllLoginEvent(emitCode));
    }
  }

  int parseImageId(String? imageId) {
    if (imageId == null || imageId == '') {
      return 1;
    }
    return int.parse(imageId);
  }

  void generateEmojiImageList() {
    correctImage = parseImageId(widget.loginData.randomImageId!);

    imageList.add(correctImage);

    int generated = 1;
    Random rng = new Random();

    while (generated <= 3) {
      int x = rng.nextInt(266) + 1;
      if (!imageList.contains(x)) {
        imageList.add(x);
        generated++;
      }
    }

    setState(() {
      imageList.shuffle();
    });
  }
}
