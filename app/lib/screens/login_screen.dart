import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/pop_all_login_event.dart';
import 'package:threebotlogin/helpers/block_and_run_mixin.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/login_helpers.dart';
import 'package:threebotlogin/models/login.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/tools_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/image_button.dart';
import 'package:threebotlogin/widgets/login_dialogs.dart';
import 'package:threebotlogin/widgets/preference_dialog.dart';

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

    if (widget.loginData.isMobile == true) {
      return;
    }

    const oneSec = const Duration(seconds: 1);
    print('Starting timer ... ');

    created = widget.loginData.created;
    currentTimestamp = new DateTime.now().millisecondsSinceEpoch;

    timeLeft = Globals().loginTimeout - ((currentTimestamp! - created!) / 1000).round();

    timer = new Timer.periodic(oneSec, (Timer t) async {
      timeoutTimer();
    });
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

    if (created == null || ((currentTimestamp! - created!) / 1000) < Globals().loginTimeout) {
      return;
    }

    timer.cancel();
    await showExpiredDialog(context);
    Navigator.pop(context, false);
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
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context, true);
                    }

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

      if (selectedImageId == -1) {
        print('No image selected');
        return;
      }

      if (selectedImageId == correctImage) {
        await sendIt(true);
        return;
      }

      await sendIt(false);
      print(context);
      await showWrongEmojiDialog(context);

      if (Navigator.canPop(context)) {
        Navigator.pop(context, false);
      }
    });
  }

  close(PopAllLoginEvent e) {
    if (e.emitCode == emitCode) {
      return;
    }

    if (!mounted) {
      return;
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context, false);
    }
  }

  cancelIt() async {
    String? doubleName = await getDoubleName();
    cancelLogin(doubleName!);
  }

  sendIt(bool includeData) async {
    String? state = widget.loginData.state;
    String? randomRoom = widget.loginData.randomRoom;

    if (widget.loginData.isMobile == false) {
      int? created = widget.loginData.created;
      int currentTimestamp = new DateTime.now().millisecondsSinceEpoch;

      if (created != null && ((currentTimestamp - created) / 1000) > Globals().loginTimeout) {
        await showExpiredDialog(context);
        await sendData(state!, null, selectedImageId, null, widget.loginData.appId!);

        if (Navigator.canPop(context)) {
          Navigator.pop(context, false);
        }

        return;
      }
    }

    // If the state is not passed through the regEx
    bool stateCheck = RegExp(r"[^A-Za-z0-9]+").hasMatch(state!);
    if (stateCheck) {
      print('States can only be alphanumeric [^A-Za-z0-9]');
      return;
    }

    String appId = widget.loginData.appId!;
    String publicKey = widget.loginData.appPublicKey!.replaceAll(" ", "+");
    Uint8List derivedSeed = await getDerivedSeed(appId);

    // Get the selected scope permissions and get the required data
    var scopePermissions = await getPreviousScopePermissions(widget.loginData.appId!);
    Map<String, dynamic>? scopeData = await readScopeAsObject(scopePermissions, derivedSeed);

    // Encrypt the scope data
    Map<String, String> encryptedScopeData = await encryptLoginData(publicKey, scopeData);

    if (!includeData) {
      await sendData(state, null, selectedImageId, null, widget.loginData.appId!);
    } else {
      await sendData(
          state, encryptedScopeData, selectedImageId, randomRoom, widget.loginData.appId!);
    }

    // If the image is wrong, quit here and don't add the digital twin to the table
    if (selectedImageId != correctImage) {
      return;
    }

    addDigitalTwinToBackend(derivedSeed, widget.loginData.appId!);

    if (Navigator.canPop(context)) {
      Navigator.pop(context, true);
    }

    Events().emit(PopAllLoginEvent(emitCode));
  }

  void generateEmojiImageList() {
    if(widget.loginData.randomImageId == null) {
      correctImage = 1;
    }
    else {
      correctImage = parseImageId(widget.loginData.randomImageId!);
    }

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
