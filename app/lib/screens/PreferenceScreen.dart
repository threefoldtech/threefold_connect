import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:threebotlogin/helpers/HexColor.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/screens/ChangePinScreen.dart';
import 'package:threebotlogin/screens/UnregisteredScreen.dart';
import 'package:threebotlogin/services/fingerprintService.dart';
import 'package:threebotlogin/services/openKYCService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';
import 'package:threebotlogin/widgets/PinField.dart';

class PreferenceScreen extends StatefulWidget {
  PreferenceScreen({Key key}) : super(key: key);
  @override
  _PreferenceScreenState createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  Map email;
  String doubleName = '';
  String phrase = '';
  bool emailVerified = false;
  bool showAdvancedOptions = false;
  Icon showAdvancedOptionsIcon = Icon(Icons.keyboard_arrow_down);
  String emailAdress = '';
  BuildContext preferenceContext;
  bool biometricsCheck = false;
  bool finger = false;

  String version = '';
  String buildNumber = '';

  var thiscolor = Colors.green;

  setEmailVerified() {
    setState(() {
      this.emailVerified = Globals().emailVerified.value;
    });
  }

  setVersion() {
    PackageInfo.fromPlatform().then((packageInfo) => {
          setState(() {
            version = packageInfo.version;
            buildNumber = packageInfo.buildNumber;
          })
        });
  }

  @override
  void initState() {
    super.initState();
    getUserValues();
    checkBiometrics();
    Globals().emailVerified.addListener(setEmailVerified);
    setVersion();
  }

  showChangePin() async {
    var pin = await getPin();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChangePinScreen(currentPin: pin)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
            child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: HexColor("#2d4052"),
          title: Text(
            'Settings',
          ),
        )),
        ListTile(
          title: Text("Profile"),
        ),
        Material(
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text(doubleName),
          ),
        ),
        Material(
          child: ListTile(
            trailing: !emailVerified ? Icon(Icons.refresh) : null,
            leading: Icon(Icons.mail),
            title: Text(emailAdress.toLowerCase()),
            subtitle: !emailVerified
                ? Text(
                    "Unverified",
                    style: TextStyle(color: Colors.grey),
                  )
                : Text(
                    "Verified",
                    style: TextStyle(color: Colors.green),
                  ),
            onTap: !emailVerified ? sendVerificationEmail : null,
          ),
        ),
        FutureBuilder(
          future: getPhrase(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Material(
                child: ListTile(
                  trailing: Padding(
                    padding: new EdgeInsets.only(right: 7.5),
                    child: Icon(Icons.visibility),
                  ),
                  leading: Icon(Icons.vpn_key),
                  title: Text("Show Phrase"),
                  onTap: () {
                    _chooseFunctionalityPhrase();
                  },
                ),
              );
            } else {
              return Container();
            }
          },
        ),
        Visibility(
          visible: biometricsCheck,
          child: Material(
            child: CheckboxListTile(
              secondary: Icon(Icons.fingerprint),
              value: finger,
              title: Text("Fingerprint"),
              activeColor: Theme.of(context).accentColor,
              onChanged: (bool newValue) {
                setState(() {
                  //logger.log('newvalue:', newValue, finger);
                });

                _chooseDialogFingerprint(newValue);
              },
            ),
          ),
        ),
        Material(
          child: ListTile(
            leading: Icon(Icons.lock),
            title: Text("Change pincode"),
            onTap: () {
              showChangePin();
            },
          ),
        ),
        Material(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("Version: " + version + " - " + buildNumber),
          ),
        ),
        ExpansionTile(
          title: Text(
            "Advanced settings",
            style: TextStyle(color: Colors.black),
          ),
          children: <Widget>[
            Material(
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  "Remove Account From Device",
                  style: TextStyle(color: Colors.red),
                ),
                trailing: Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                ),
                onTap: _showDialog,
              ),
            ),
          ],
        ),
      ],
    );
  }

  checkBiometrics() async {
    biometricsCheck = await checkBiometricsAvailable();
    return biometricsCheck;
  }

  void _chooseDialogFingerprint(isValue) async {
    if (isValue) {
      _showEnabledFingerprint();
    } else {
      _showPinDialog('fingerprint');
    }
  }

  void _chooseFunctionalityPhrase() async {
    bool fingerActive = await getFingerprint();
    if (!fingerActive) {
      _showPinDialog('phrase');
    } else {
      var isValue = await authenticate();
      isValue ? _showPhrase() : _showPinDialog('phrase');
      setState(() {
        finger = true;
      });
    }
  }

  void _showEnabledFingerprint() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        image: Icons.error,
        title: "Enable Fingerprint",
        description: new Text(
          "If you enable fingerprint, anyone who has a registered fingerprint on this device will have access to your account.",
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          FlatButton(
            child: new Text("Cancel"),
            onPressed: () async {
              Navigator.pop(context);
              finger = false;
              await saveFingerprint(false);
              setState(() {});
            },
          ),
          FlatButton(
            child: new Text("Yes"),
            onPressed: () async {
              Navigator.pop(context);
              finger = true;
              await saveFingerprint(true);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  void _showDisableFingerprint() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        image: Icons.error,
        title: "Disable Fingerprint",
        description: new Text(
          "Are you sure you want to deactivate fingerprint as authentication method?",
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          FlatButton(
            child: new Text("Cancel"),
            onPressed: () async {
              Navigator.pop(context);
              finger = true;
              await saveFingerprint(true);
              setState(() {});
            },
          ),
          FlatButton(
            child: new Text("Yes"),
            onPressed: () async {
              Navigator.pop(context);
              finger = false;
              await saveFingerprint(false);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        image: Icons.error,
        title: "Are you sure?",
        description: new Text(
          "If you confirm, your account will be removed from this device. You can always recover your account with your doublename, email and phrase.",
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          FlatButton(
            child: new Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
              child: new Text("Yes"),
              onPressed: () async {
                bool result = await clearData();
                if (result) {
                  await Navigator.pushReplacement(
                      //@todo this feels like a bug, should not push on current screen
                      context,
                      MaterialPageRoute(
                          builder: (context) => UnregisteredScreen()));
                } else {
                  showDialog(
                      context: preferenceContext,
                      builder: (BuildContext context) => CustomDialog(
                            title: 'Error',
                            description: Text(
                                'Something went wrong when trying to remove your account.'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Ok'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          ));
                }
              }),
        ],
      ),
    );
  }



  void _showPinDialog(callbackParam) {
    if (callbackParam == 'fingerprint') {
      setState(() {
        finger = true;
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        image: Icons.dialpad,
        title: "Please enter your pincode",
        description: Container(
          child: PinField(
            callback: checkPin,
            callbackParam: callbackParam,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: new Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Future copySeedPhrase() async {
    Clipboard.setData(new ClipboardData(text: await getPhrase()));

    final seedCopied = SnackBar(
      content: Text('Seedphrase copied to clipboard'),
      duration: Duration(seconds: 1),
    );
    Scaffold.of(context).showSnackBar(seedCopied);

    // _prefScaffold.currentState.showSnackBar(SnackBar(
    //   content: Text('Seedphrase copied to clipboard'),
    // ));
  }

  void checkPin(pin, callbackParam) async {
    if (pin == await getPin()) {
      Navigator.pop(context);
      switch (callbackParam) {
        case 'phrase':
          _showPhrase();
          break;
        case 'fingerprint':
          _showDisableFingerprint();
          break;
      }
    } else {
      Navigator.pop(context);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Pin invalid'),
      ));
    }
    setState(() {});
  }

  void _showPhrase() async {
    final phrase = await getPhrase();

    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        hiddenaction: copySeedPhrase,
        image: Icons.create,
        title: "Please write this down on a piece of paper",
        description: Text(
          phrase.toString(),
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          FlatButton(
            child: new Text("Close"),
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  void getUserValues() {
    getDoubleName().then((dn) {
      setState(() {
        doubleName = dn;
      });
    });
    getEmail().then((emailMap) {
      setState(() {
        if (emailMap['email'] != null) {
          emailAdress = emailMap['email'];
          emailVerified = (emailMap['verified'] != null);
        }
      });
    });
    getPhrase().then((seedPhrase) {
      setState(() {
        phrase = seedPhrase;
      });
    });
    getFingerprint().then((fingerprint) {
      setState(() {
        if (fingerprint == null) {
          finger = false;
        } else {
          finger = fingerprint;
        }
      });
    });
  }
}
