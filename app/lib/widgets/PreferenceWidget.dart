import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/services/fingerprintService.dart';
import 'package:threebotlogin/services/openKYCService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';
import 'package:threebotlogin/widgets/PinField.dart';

class PreferenceWidget extends StatefulWidget {
  final Function(bool) showPreference;
  final Function routeToHome;
  PreferenceWidget(this.showPreference, this.routeToHome, {Key key})
      : super(key: key);
  @override
  _PreferenceWidgetState createState() => _PreferenceWidgetState();
}

class _PreferenceWidgetState extends State<PreferenceWidget> {
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

  var thiscolor = Colors.green;

  @override
  void initState() {
    super.initState();
    getUserValues();
    checkBiometrics();
  }

  @override
  Widget build(BuildContext context) {
    preferenceContext = context;
    return ListView(
      children: <Widget>[
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: Text(
            'Settings',
            style: TextStyle(color: Colors.black),
          ),
          leading: FlatButton(
              child: Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  widget.showPreference(false);
                });
              }),
        ),
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
                  logger.log('newvalue:', newValue, finger);
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
              Navigator.pushNamed(context, '/changepin');
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
              Navigator.pop(context);

              for (var flutterWebViewPlugin in flutterWebViewPlugins) {
                if (flutterWebViewPlugin != null) {
                  await flutterWebViewPlugin.cleanCookies();
                  await flutterWebViewPlugin.close();
                }
              }

              hexColor = Color(0xff0f296a);
              bool result = await clearData();

              if (result) {
                Navigator.popUntil(
                    preferenceContext,
                    ModalRoute.withName('/'),
                );

                await Navigator.pushNamed(preferenceContext, '/');
                widget.routeToHome();
              } else {
                showDialog(
                    context: preferenceContext,
                    builder: (BuildContext context) => CustomDialog(
                          title: 'Error',
                          description: Text('Something went wrong when trying to remove your account.'),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Ok'),
                              onPressed: () {
                                Navigator.popUntil(context, ModalRoute.withName('/preference'));
                              },
                            )
                          ],
                        ));
              }

              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  void sendVerificationEmail() async {
    final snackBar = SnackBar(content: Text('Resending verification email...'));
    Scaffold.of(context).showSnackBar(snackBar);
    await resendVerificationEmail();
    _showResendEmailDialog();
  }

  void _showResendEmailDialog() {
    logger.log('Dialogging');
    if (context != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          image: Icons.check,
          title: "Email has been resent.",
          description: new Text("A new verification email has been sent."),
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
          emailVerified = emailMap['verified'];
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
