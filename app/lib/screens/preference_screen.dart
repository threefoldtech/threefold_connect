import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:shuftipro_flutter_sdk/ShuftiPro.dart';
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/apps/free_flow_pages/ffp_events.dart';
import 'package:threebotlogin/events/close_socket_event.dart';
import 'package:threebotlogin/events/close_vpn_event.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/helpers/environment.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/hex_color.dart';
import 'package:threebotlogin/screens/authentication_screen.dart';
import 'package:threebotlogin/screens/change_pin_screen.dart';
import 'package:threebotlogin/screens/main_screen.dart';
import 'package:threebotlogin/services/fingerprint_service.dart';
import 'package:threebotlogin/services/open_kyc_service.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/widgets/email_verification_needed.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ask_identity_screen.dart';

class PreferenceScreen extends StatefulWidget {
  PreferenceScreen({Key key}) : super(key: key);

  @override
  _PreferenceScreenState createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  // FirebaseNotificationListener _listener;
  Map email;
  String doubleName = '';
  String phrase = '';
  bool emailVerified = false;
  bool phoneVerified = false;
  bool identityVerified = false;
  bool showAdvancedOptions = false;
  Icon showAdvancedOptionsIcon = Icon(Icons.keyboard_arrow_down);

  String emailAdress = '';
  String phoneAdress = '';
  String identity = '';

  BuildContext preferenceContext;
  bool biometricsCheck = false;
  bool finger = false;

  String version = '';
  String buildNumber = '';
  String biometricDeviceName = "";

  Globals globals = Globals();

  MaterialColor thiscolor = Colors.green;

  var authObject = {
    "auth_type": "basic_auth",
    "client_id": dotenv.env['SHUFTI_CLIENT_ID'],
    "secret_key": dotenv.env['SHUFTI_CLIENT_SECRET'],
  };

  // Default values for accessing the Shufti API
  Map<String, Object> createdPayload = {
    "country": "",
    "language": "EN",
    "email": "",
    "callback_url": "http://www.example.com",
    "redirect_url": "https://www.dummyurl.com/",
    "show_consent": 1,
    "show_results": 1,
    "show_privacy_policy": 1,
    "open_webView": false,
  };

  // Template for Shufti API verification object
  Map<String, Object> verificationObj = {
    "face": {},
    "background_checks": {},
    "phone": {},
    "document": {
      "supported_types": [
        "passport",
        "id_card",
        "driving_license",
        "credit_or_debit_card",
      ],
      "name": {
        "first_name": "",
        "last_name": "",
        "middle_name": "",
      },
      "dob": "",
      "document_number": "",
      "expiry_date": "",
      "issue_date": "",
      "fetch_enhanced_data": "",
      "gender": "",
      "backside_proof_required": "1",
    },
    "document_two": {
      "supported_types": [
        "passport",
        "id_card",
        "driving_license",
        "credit_or_debit_card"
      ],
      "name": {"first_name": "", "last_name": "", "middle_name": ""},
      "dob": "",
      "document_number": "",
      "expiry_date": "",
      "issue_date": "",
      "fetch_enhanced_data": "",
      "gender": "",
      "backside_proof_required": "0",
    },
    "address": {
      "full_address": "",
      "name": {
        "first_name": "",
        "last_name": "",
        "middle_name": "",
        "fuzzy_match": "",
      },
      "supported_types": ["id_card", "utility_bill", "bank_statement"],
    },
    "consent": {
      "supported_types": ["printed", "handwritten"],
      "text": "My name is John Doe and I authorize this transaction of \$100/-",
    },
  };


  setEmailVerified() {
    if (mounted) {
      setState(() {
        this.emailVerified = Globals().emailVerified.value;
      });
    }
  }

  setIdentityVerified() {
    if (mounted) {
      setState(() {
        this.identityVerified = Globals().identityVerified.value;
      });
    }
  }

  setPhoneVerified() {
    if (mounted) {
      setState(() {
        this.phoneVerified = Globals().phoneVerified.value;
      });
    }
  }

  @override
  void initState() {
    super.initState();


    setState(() {
      // Here we can choose the different types of verification:
      // Possibilities:

      // createdPayload["face"] = verificationObj['face'];
      // createdPayload["document"] = verificationObj['document'];
      // createdPayload["document_two"] = verificationObj['document_two'];
      // createdPayload["address"] = verificationObj['address'];
      // createdPayload["consent"] = verificationObj['consent'];
      // createdPayload["background_checks"] = verificationObj['background_checks'];
      // createdPayload["phone"] = verificationObj['phone'];

      createdPayload["document"] = verificationObj['document'];
      createdPayload["verification_mode"] = "image_only";
    });


    // checkBiometrics().then((result) => {biometricsCheck = result});

    PackageInfo.fromPlatform().then((packageInfo) =>
    {
      setState(() {
        version = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
      })
    });

    Globals().emailVerified.addListener(setEmailVerified);
    Globals().phoneVerified.addListener(setPhoneVerified);
    Globals().identityVerified.addListener(setIdentityVerified);

    getUserValues();
  }

  showChangePin() async {
    String pin = await getPin();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuthenticationScreen(correctPin: pin),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutDrawer(
      titleText: 'Settings',
      content: Stack(
        children: <Widget>[
          SvgPicture.asset(
            'assets/bg.svg',
            alignment: Alignment.center,
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: MediaQuery
                .of(context)
                .size
                .height,
          ),
          ListView(
            children: <Widget>[
              ListTile(
                title: Text("Profile"),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text(doubleName),
              ),
              ListTile(
                  leading: Icon(Icons.ten_k),
                  title: Text('Testing'),
                  onTap: () async {
                    await _warningVerifyIdentity();
                  }
              ),
              ListTile(
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
              ListTile(
                  trailing: !phoneVerified && phoneAdress.isNotEmpty
                      ? Icon(Icons.refresh)
                      : null,
                  leading: Icon(Icons.phone),
                  title: phoneAdress.isEmpty
                      ? Text("Add phone number",
                      style: TextStyle(
                          color: Theme
                              .of(context)
                              .primaryColorDark,
                          fontWeight: FontWeight.bold))
                      : Text(
                    phoneAdress,
                  ),
                  subtitle: phoneAdress.isEmpty
                      ? null
                      : !phoneVerified
                      ? Text(
                    "Unverified",
                    style: TextStyle(color: Colors.deepOrangeAccent),
                  )
                      : Text(
                    "Verified",
                    style: TextStyle(color: Colors.green),
                  ),
                  onTap: () async {
                    if (phoneVerified) {
                      return;
                    }

                    if (phoneAdress.isEmpty) {
                      await addPhoneNumberDialog(context);
                      var phoneMap = (await getPhone());
                      if (phoneMap.isEmpty || !phoneMap.containsKey('phone')) {
                        return;
                      }
                      var pn = phoneMap['phone'];
                      if (pn == null) {
                        return;
                      }

                      setState(() {
                        phoneAdress = pn;
                      });

                      if (phoneAdress.isEmpty) {
                        return;
                      }
                    }

                    int currentTime = new DateTime.now().millisecondsSinceEpoch;

                    if (globals.tooManySmsAttempts &&
                        globals.lockedSmsUntill > currentTime) {
                      globals.sendSmsAttempts = 0;
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: new Text('Too many attemts please wait ' +
                                ((globals.lockedSmsUntill - currentTime) / 1000)
                                    .round()
                                    .toString() +
                                ' seconds.'),
                            actions: <Widget>[
                              FlatButton(
                                child: new Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    globals.tooManySmsAttempts = false;

                    if (globals.sendSmsAttempts >= 3) {
                      globals.tooManySmsAttempts = true;
                      globals.lockedSmsUntill = currentTime + 60000;

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: new Text(
                                'Too many attemts please wait one minute.'),
                            actions: <Widget>[
                              FlatButton(
                                child: new Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    globals.sendSmsAttempts++;

                    sendVerificationSms();
                    phoneSendDialog(context);
                  }),
              FutureBuilder(
                future: getPhrase(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListTile(
                      trailing: Padding(
                        padding: new EdgeInsets.only(right: 7.5),
                        child: Icon(Icons.visibility),
                      ),
                      leading: Icon(Icons.vpn_key),
                      title: Text("Show Phrase"),
                      onTap: () async {
                        _showPhrase();
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              FutureBuilder(
                  future: checkBiometrics(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data == true) {
                        return FutureBuilder(
                            future: getBiometricDeviceName(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data == "Not found") {
                                  return Container();
                                }

                                biometricDeviceName = snapshot.data;

                                return CheckboxListTile(
                                  secondary: Icon(Icons.fingerprint),
                                  value: finger,
                                  title: Text(snapshot.data),
                                  activeColor: Theme
                                      .of(context)
                                      .accentColor,
                                  onChanged: (bool newValue) async {
                                    _toggleFingerprint(newValue);
                                  },
                                );
                              } else {
                                return Container();
                              }
                            });
                      }
                    } else {
                      return Container();
                    }
                  }),
              ListTile(
                leading: Icon(Icons.lock),
                title: Text("Change pincode"),
                onTap: () async {
                  _changePincode();
                },
              ),
              ListTile(
                leading: Icon(Icons.perm_device_information),
                title: Text("Version: " + version + " - " + buildNumber),
                onTap: () {
                  _showVersionInfo();
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text("Terms and conditions"),
                onTap: () async => {await _showTermsAndConds()},
              ),
              ExpansionTile(
                title: Text(
                  "Advanced settings",
                  style: TextStyle(color: Colors.black),
                ),
                children: <Widget>[
                  ListTile(
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
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  checkBiometrics() async {
    return await checkBiometricsAvailable();
  }

  void _showDisableFingerprint() {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          CustomDialog(
            image: Icons.error,
            title: "Disable Fingerprint",
            description:
            "Are you sure you want to deactivate fingerprint as authentication method?",
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
      builder: (BuildContext context) =>
          CustomDialog(
            image: Icons.error,
            title: "Are you sure?",
            description:
            "If you confirm, your account will be removed from this device. You can always recover your account with your doublename, email and phrase.",
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
                  // try {
                  //   String deviceID = await _listener.getToken();
                  //   removeDeviceId(deviceID);
                  // } catch (e) {}
                  Events().emit(CloseSocketEvent());
                  Events().emit(FfpClearCacheEvent());
                  Events().emit(CloseVpnEvent());
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
                      builder: (BuildContext context) =>
                          CustomDialog(
                            title: 'Error',
                            description:
                            'Something went wrong when trying to remove your account.',
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
                  }
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
          emailVerified = (emailMap['sei'] != null);
        }
      });
    });
    getPhone().then((phoneMap) {
      setState(() {
        if (phoneMap['phone'] != null) {
          phoneAdress = phoneMap['phone'];
          phoneVerified = (phoneMap['spi'] != null);
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
    String pin = await getPin();

    bool authenticated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AuthenticationScreen(
                correctPin: pin,
                userMessage: "show your phrase.",
              ),
        ));

    if (authenticated != null && authenticated) {
      final phrase = await getPhrase();

      showDialog(
        context: context,
        builder: (BuildContext context) =>
            CustomDialog(
              hiddenaction: copySeedPhrase,
              image: Icons.create,
              title: "Please write this down on a piece of paper",
              description: phrase.toString(),
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
    String pin = await getPin();

    bool authenticated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AuthenticationScreen(
              correctPin: pin,
              userMessage: "toggle " + biometricDeviceName + ".",
            ),
      ),
    );

    if (authenticated != null && authenticated) {
      finger = newFingerprintValue;
      await saveFingerprint(newFingerprintValue);
      setState(() {});
    }
  }


  Future<void> _warningVerifyIdentity() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) =>
          CustomDialog(
            image: Icons.info,
            title: 'Are you sure?',
            description:
            'Are you sure you want to verify your identity?',
            actions: <Widget>[
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context);

                },
              ),
              FlatButton(
                child: Text('Yes'),
                onPressed: () async {
                  Response identityResponse = await sendVerificationIdentity();
                  Map<String, Object> identityDetails =
                  jsonDecode(identityResponse.body);

                  String verificationCode = identityDetails['verification_code'];

                  var reference = verificationCode;
                  createdPayload["reference"] = reference;
                  createdPayload["document"] = verificationObj['document'];
                  createdPayload["verification_mode"] = "image_only";

                  Navigator.pop(context);

                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) =>
                          new ShuftiPro(
                              authObject: authObject,
                              createdPayload: createdPayload,
                              async: false,
                              callback: (res) async {
                                Map<String, dynamic> data = jsonDecode(res);
                                print(data);
                                if(data['event'] == 'verfication.accepted') {

                                }
                              },
                              homeClass: PreferenceScreen())));
                },
              )
            ],
          ),
    );
  }


  void _changePincode() async {
    String pin = await getPin();
    bool authenticated = false;

    if (pin == null || pin.isEmpty) {
      authenticated = true; // In case the pin wasn't set.
    } else {
      authenticated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AuthenticationScreen(
                correctPin: pin,
                userMessage: "change your pincode.",
              ),
        ),
      );
    }

    if (authenticated != null && authenticated) {
      bool pinChanged = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ChangePinScreen(
                currentPin: pin,
                hideBackButton: false,
              ),
        ),
      );

      if (pinChanged != null && pinChanged) {
        showDialog(
          context: context,
          builder: (BuildContext context) =>
              CustomDialog(
                image: Icons.check,
                title: "Success",
                description: "Your pincode was successfully changed.",
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

  Future<void> _showTermsAndConds() async {
    const url = 'https://wiki.threefold.io/#/legal__legal';
    await launch(url);
  }

  void _showVersionInfo() {
    try {
      AppConfig appConfig = AppConfig();

      if (appConfig.environment != Environment.Production) {
        showDialog(
          context: context,
          builder: (BuildContext context) =>
              CustomDialog(
                image: Icons.perm_device_information,
                title: "Build information",
                description:
                "Type: ${appConfig.environment}\nGit hash: ${appConfig
                    .githash}\nTime: ${appConfig.time}",
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
