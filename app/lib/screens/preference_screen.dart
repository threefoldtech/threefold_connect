import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/apps/free_flow_pages/ffp_events.dart';
import 'package:threebotlogin/events/close_socket_event.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/helpers/environment.dart';
import 'package:threebotlogin/helpers/globals.dart';

import 'package:threebotlogin/screens/authentication_screen.dart';
import 'package:threebotlogin/screens/change_pin_screen.dart';
import 'package:threebotlogin/screens/main_screen.dart';
import 'package:threebotlogin/services/fingerprint_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

class PreferenceScreen extends StatefulWidget {
  PreferenceScreen({Key? key}) : super(key: key);

  @override
  _PreferenceScreenState createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  // FirebaseNotificationListener _listener;
  Map email = {};
  String doubleName = '';
  String phrase = '';
  bool showAdvancedOptions = false;
  Icon showAdvancedOptionsIcon = Icon(Icons.keyboard_arrow_down);

  String emailAdress = '';
  String phoneAdress = '';
  String identity = '';

  BuildContext? preferenceContext;
  bool biometricsCheck = false;
  bool finger = false;

  String version = '';
  String buildNumber = '';
  Object? biometricDeviceName;

  Globals globals = Globals();

  MaterialColor thiscolor = Colors.green;

  @override
  void initState() {
    super.initState();

    // checkBiometrics().then((result) => {biometricsCheck = result});

    PackageInfo.fromPlatform().then((packageInfo) => {
          setState(() {
            version = packageInfo.version;
            buildNumber = packageInfo.buildNumber;
          })
        });

    getUserValues();
  }

  showChangePin() async {
    String? pin = await getPin();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuthenticationScreen(
            correctPin: pin!,
            userMessage: 'Please enter your PIN code',
          ),
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
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          ListView(
            children: <Widget>[
              ListTile(
                title: Text("Global settings"),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text(doubleName),
              ),
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
                      title: Text("Show phrase"),
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
                                  title: Text(snapshot.data.toString()),
                                  activeColor:
                                      Theme.of(context).colorScheme.secondary,
                                  onChanged: (bool? newValue) async {
                                    _toggleFingerprint(newValue!);
                                  },
                                );
                              } else {
                                return Container();
                              }
                            });
                      } else {
                        return Container();
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
      builder: (BuildContext context) => CustomDialog(
        image: Icons.error,
        title: "Disable Fingerprint",
        description:
            "Are you sure you want to deactivate fingerprint as authentication method?",
        actions: <Widget>[
          TextButton(
            child: new Text("Cancel"),
            onPressed: () async {
              Navigator.pop(context);
              finger = true;
              await saveFingerprint(true);
              setState(() {});
            },
          ),
          TextButton(
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
        description:
            "If you confirm, your account will be removed from this device. You can always recover your account with your username and phrase.",
        actions: <Widget>[
          TextButton(
            child: new Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: new Text("Yes"),
            onPressed: () async {
              // try {
              //   String deviceID = await _listener.getToken();
              //   removeDeviceId(deviceID);
              // } catch (e) {}
              Events().emit(CloseSocketEvent());
              Events().emit(FfpClearCacheEvent());
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
                  context: preferenceContext!,
                  builder: (BuildContext context) => CustomDialog(
                    title: 'Error',
                    description:
                        'Something went wrong when trying to remove your account.',
                    actions: <Widget>[
                      TextButton(
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
    Clipboard.setData(ClipboardData(text: (await getPhrase()).toString()));

    const seedCopied = SnackBar(
      content: Text('Seed phrase copied to clipboard'),
      duration: Duration(seconds: 1),
    );

    ScaffoldMessenger.of(context).showSnackBar(seedCopied);
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Pin invalid'),
      ));
    }
    setState(() {});
  }

  void getUserValues() {
    getDoubleName().then((dn) {
      setState(() {
        doubleName = dn!.substring(0, dn.length - 5);
      });
    });
    getPhrase().then((seedPhrase) {
      setState(() {
        phrase = seedPhrase!;
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
    String? pin = await getPin();
    bool? authenticated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuthenticationScreen(
            correctPin: pin!,
            userMessage: "Please enter your PIN code",
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
          description: phrase.toString(),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
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
    String? pin = await getPin();

    bool? authenticated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuthenticationScreen(
          correctPin: pin!,
          userMessage: "Please enter your PIN code",
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
    String? pin = await getPin();
    bool? authenticated = false;

    if (pin == null || pin.isEmpty) {
      authenticated = true; // In case the pin wasn't set.
    } else {
      authenticated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuthenticationScreen(
            correctPin: pin,
            userMessage: "Please enter your PIN code",
          ),
        ),
      );
    }

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
            description: "Your pincode was successfully changed.",
            actions: <Widget>[
              TextButton(
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
    String url = Globals().tosUrl;

    if (url == '') {
      return;
    }

    await launchUrl(Uri.parse(url));
  }

  void _showVersionInfo() {
    try {
      AppConfig appConfig = AppConfig();

      if (appConfig.environment != Environment.Production) {
        showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
            image: Icons.perm_device_information,
            title: 'Build information',
            description:
                'Type: ${appConfig.environment}\nGit hash: ${appConfig.githash}\nTime: ${appConfig.time}',
            actions: <Widget>[
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ],
          ),
        );
      }
    } on Exception {
      // Doesn't matter, just needs to be caught.
    }
  }
}
