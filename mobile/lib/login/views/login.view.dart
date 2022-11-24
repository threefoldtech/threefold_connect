import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/api/3bot/services/login.service.dart';
import 'package:threebotlogin/core/crypto/utils/crypto.utils.dart';
import 'package:threebotlogin/core/events/classes/event.classes.dart';
import 'package:threebotlogin/core/events/services/events.service.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/core/styles/color.styles.dart';
import 'package:threebotlogin/core/utils/core.utils.dart';
import 'package:threebotlogin/login/classes/image.button.classes.dart';
import 'package:threebotlogin/login/classes/login.classes.dart';
import 'package:threebotlogin/login/views/preference.view.dart';
import 'package:threebotlogin/login/dialogs/login.dialogs.dart';
import 'package:threebotlogin/login/helpers/login.helpers.dart';
import 'package:threebotlogin/login/mixins/login.mixins.dart';

class LoginScreen extends StatefulWidget {
  final Login loginData;

  LoginScreen(this.loginData);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with BlockAndRunMixin {
  String scopeTextMobile = 'Please select the data you want to share and press Accept';
  String scopeText = 'Please select the data you want to share and press the corresponding emoji';
  String emitCode = randomString(10);

  List<int> imageList = [];

  int selectedImageId = -1;
  int correctImage = -1;

  bool isMobile = false;

  int created = 0;
  int currentTimestamp = 0;
  int timeLeft = Globals().loginTimeout;

  late Timer timer;

  late String appPublicKey;
  late String state;
  late String appId;
  late String room;

  @override
  void initState() {
    Events().onEvent(PopAllLoginEvent("").runtimeType, close);
    super.initState();

    setFields();

    setIsMobile();

    if (widget.loginData.randomImageId != null && !isMobile) {
      correctImage = parseImageId(widget.loginData.randomImageId!);
      imageList = generateEmojiImageList(widget.loginData.randomImageId!);
      startTimer();
      return;
    }

    correctImage = 1;

    if (!isMobile) {
      startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: new Scaffold(
          appBar: new AppBar(
            backgroundColor: kAppBarColor,
            title: new Text("Login"),
          ),
          body: Column(
            children: <Widget>[
              Visibility(
                visible: true,
                child: Expanded(flex: 6, child: scopeEmojiView()),
              ),
              Visibility(
                visible: !isMobile,
                child: Expanded(
                  flex: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      child: Text(
                        "It wasn\'t me - cancel",
                        style: TextStyle(fontSize: 16.0, color: Color(0xff0f296a)),
                      ),
                      onPressed: () {
                        cancelLogin();
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
        onWillPop: () async {
          await cancelLogin();
          return Future.value(true);
        });
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
                    isMobile ? scopeTextMobile : scopeText,
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
                ),
              ),
            ),
            isMobile
                ? Container()
                : Visibility(
                    visible: !isMobile,
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
              visible: isMobile,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: ElevatedButton(
                  child: Text(
                    'Accept',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  onPressed: () async {
                    await sendDataToBackend(true);
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context, true);
                    }
                  },
                ),
              ),
            ),
            Visibility(
              visible: !isMobile,
              child: Expanded(
                flex: 1,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24.0, left: 24.0),
                    child: Text(
                      "Attempt expires in " + ((timeLeft >= 0) ? timeLeft.toString() : "0") + " second(s).",
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

  cancelIt() async {
    cancelLogin();
  }

  close(PopAllLoginEvent e) {
    if (!mounted) return;

    if (Navigator.canPop(context)) {
      Navigator.pop(context, false);
    }
  }

  void setFields() async {
    if (widget.loginData.appPublicKey == null ||
        widget.loginData.state == null ||
        widget.loginData.appId == null ||
        widget.loginData.room == null) {
      Events().emit(PopAllLoginEvent(emitCode));
      return;
    }

    appId = widget.loginData.appId!;
    appPublicKey = widget.loginData.appPublicKey!.replaceAll(" ", "+");
    state = widget.loginData.state!;
    room = widget.loginData.room!;
  }

  closeLoginAttempt() {
    if (!mounted) return;

    if (Navigator.canPop(context)) {
      Navigator.pop(context, false);
    }
  }

  void setIsMobile() {
    if (widget.loginData.isMobile == null) {
      isMobile = false;
    } else {
      isMobile = widget.loginData.isMobile!;
    }
  }

  imageSelectedCallback(imageId) {
    blockAndRun(() async {
      selectedImageId = imageId;
      setState(() {});

      if (selectedImageId == -1) {
        print('No image selected');
        return;
      }

      if (selectedImageId == correctImage) {
        await sendDataToBackend(true);
        return;
      }

      await sendDataToBackend(false);

      await showWrongEmojiDialog();

      if (Navigator.canPop(context)) {
        Navigator.pop(context, false);
      }
    });
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    print('Starting timer ... ');

    created = widget.loginData.created!;
    currentTimestamp = new DateTime.now().millisecondsSinceEpoch;

    timeLeft = Globals().loginTimeout - ((currentTimestamp - created) / 1000).round();

    timer = new Timer.periodic(oneSec, (Timer t) async {
      timeoutTimer();
    });
  }

  bool isValidLoginAttempt() {
    int? created = widget.loginData.created;
    int currentTimestamp = new DateTime.now().millisecondsSinceEpoch;

    if (created != null && ((currentTimestamp - created) / 1000) > Globals().loginTimeout) {
      return false;
    }

    return true;
  }

  Future<void> timeoutTimer() async {
    if (!mounted) return timer.cancel();

    currentTimestamp = new DateTime.now().millisecondsSinceEpoch;
    timeLeft = Globals().loginTimeout - ((currentTimestamp - created) / 1000).round();
    setState(() {});

    if (((currentTimestamp - created) / 1000) < Globals().loginTimeout) {
      return;
    }

    timer.cancel();
    await showExpiredDialog();
    Navigator.pop(context, false);
  }

  Future<void> invalidateLoginAttempt() async {
    await sendData(this.state, null, selectedImageId, null, this.appId);
    if (Navigator.canPop(context)) Navigator.pop(context, false);

    await showExpiredDialog();
  }

  Future<void> sendDataToBackend(bool includeScopeData) async {
    if (!isMobile) {
      bool validLogin = isValidLoginAttempt();

      if (!validLogin) {
        invalidateLoginAttempt();
        return;
      }

      if (selectedImageId != correctImage) {
        return;
      }
    }

    bool validState = isValidState(widget.loginData.state);
    if (validState) {
      print('States can only be alphanumeric [^A-Za-z0-9]');
      return;
    }

    String? scopePermissions = await getPreviousScopePermissions(appId);

    Uint8List derivedSeed = await getDerivedSeed(appId);

    Map<String, dynamic>? scopeData = await readScopeAsObject(scopePermissions, derivedSeed);
    Map<String, String> encryptedScopeData = await encryptLoginData(appPublicKey, scopeData);

    await addDigitalTwinToBackend(derivedSeed, appId);

    if (!includeScopeData) {
      await sendData(state, null, selectedImageId, null, appId);
    } else {
      await sendData(state, encryptedScopeData, selectedImageId, room, appId);
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context, true);
    }

    Events().emit(PopAllLoginEvent(emitCode));
  }
}
