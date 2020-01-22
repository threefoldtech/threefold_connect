import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:threebotlogin/AppConfig.dart';
import 'package:threebotlogin/Events/CloseSocketEvent.dart';
import 'package:threebotlogin/Events/Events.dart';
import 'package:threebotlogin/helpers/Environment.dart';
import 'package:threebotlogin/helpers/Globals.dart';
import 'package:threebotlogin/helpers/HexColor.dart';
import 'package:threebotlogin/screens/AuthenticationScreen.dart';
import 'package:threebotlogin/screens/ChangePinScreen.dart';
import 'package:threebotlogin/services/fingerprintService.dart';
import 'package:threebotlogin/services/openKYCService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';
import 'package:threebotlogin/widgets/EmailVerificationNeeded.dart';

import 'MainScreen.dart';

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
          builder: (context) => AuthenticationScreen(correctPin: pin),
        ));
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
              onTap: () {
                if (!emailVerified) {
                  sendVerificationEmail();
                  emailResendedDialog(context);
                }
              }),
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
                  onTap: () async {
                    _showPhrase();
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
              onChanged: (bool newValue) async {
                _toggleFingerprint(newValue);
              },
            ),
          ),
        ),
        Material(
          child: ListTile(
            leading: Icon(Icons.lock),
            title: Text("Change pincode"),
            onTap: () async {
              _changePincode();
            },
          ),
        ),
        Material(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("Version: " + version + " - " + buildNumber),
            onTap: () {
              _showVersionInfo();
            },
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
                Events().emit(CloseSocketEvent());
                bool result = await clearData();
                if (result) {
                  Navigator.pop(context);
                  await Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MainScreen(initDone: true, registered: false)));
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

  Future copySeedPhrase() async {
    Clipboard.setData(new ClipboardData(text: await getPhrase()));

    final seedCopied = SnackBar(
      content: Text('Seedphrase copied to clipboard'),
      duration: Duration(seconds: 1),
    );

    Scaffold.of(context).showSnackBar(seedCopied);
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

  void _showPhrase() async {
    var pin = await getPin();

    bool authenticated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuthenticationScreen(
            correctPin: pin,
            userMessage: "show your phrase.",
          ),
        ));

    if (authenticated != null && authenticated) {
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
  }

  void _toggleFingerprint(bool newFingerprintValue) async {
    var pin = await getPin();

    bool authenticated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuthenticationScreen(
          correctPin: pin,
          userMessage: "toggle fingerprint.",
        ),
      ),
    );

    if (authenticated != null && authenticated) {
      finger = newFingerprintValue;
      await saveFingerprint(newFingerprintValue);
      setState(() {});
    }
  }

  void _changePincode() async {
    var pin = await getPin();

    bool authenticated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuthenticationScreen(
          correctPin: pin,
          userMessage: "change your pincode.",
        ),
      ),
    );

    if (authenticated != null && authenticated) {
      bool pinChanged = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangePinScreen(
            currentPin: pin,
            hideBackButton: false,
          ),
        ),
      );

      if (pinChanged != null && pinChanged) {
        showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
            image: Icons.check,
            title: "Success",
            description: new Text(
              "Your pincode was successfully changed.",
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              FlatButton(
                child: new Text("Ok"),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    }
  }

  void _showVersionInfo() {
    try {
      var appConfig = AppConfig();

      if (appConfig.environment != Environment.Production) {
        showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
            image: Icons.perm_device_information,
            title: "Build information",
            description: Container(
              child: Text(
                  "Type: ${appConfig.environment}\nGit hash: ${appConfig.githash}\nTime: ${appConfig.time}"),
            ),
            actions: <Widget>[
              FlatButton(
                child: new Text("Ok"),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ],
          ),
        );
      }
    } catch (Exception) {
      // Doesn't matter, just needs to be caught.
    }
  }
}
