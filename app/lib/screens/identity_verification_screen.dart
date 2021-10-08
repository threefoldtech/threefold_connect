import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:shuftipro_flutter_sdk/ShuftiPro.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/identity_callback_event.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/hex_color.dart';
import 'package:threebotlogin/screens/home_screen.dart';
import 'package:threebotlogin/services/identity_service.dart';
import 'package:threebotlogin/services/open_kyc_service.dart';
import 'package:threebotlogin/services/socket_service.dart';
import 'package:threebotlogin/services/tools_service.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/widgets/email_verification_needed.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';

class IdentityVerificationScreen extends StatefulWidget {
  _IdentityVerificationScreenState createState() => _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen> {
  int kycLevel;
  String doubleName = '';
  String email = '';
  String phone = '';

  String reference = '';

  bool emailVerified = false;
  bool phoneVerified = false;
  bool identityVerified = false;

  bool isInIdentityProcess = false;
  bool isLoading = false;

  Globals globals = Globals();

  var authObject = {
    "access_token": '',
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
      "supported_types": ["passport", "id_card", "driving_license", "credit_or_debit_card"],
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

  setPhoneVerified() {
    if (mounted) {
      setState(() {
        this.phoneVerified = Globals().phoneVerified.value;
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

  void initState() {
    super.initState();

    Globals().emailVerified.addListener(setEmailVerified);
    Globals().phoneVerified.addListener(setPhoneVerified);
    Globals().identityVerified.addListener(setIdentityVerified);

    getUserValues();
  }

  void getUserValues() {
    getKYCLevel().then((level) {
      setState(() {
        kycLevel = level;
      });
    });
    getDoubleName().then((dn) {
      setState(() {
        doubleName = dn;
      });
    });
    getEmail().then((emailMap) {
      setState(() {
        if (emailMap['email'] != null) {
          email = emailMap['email'];
          emailVerified = (emailMap['sei'] != null);
        }
      });
    });
    getPhone().then((phoneMap) {
      setState(() {
        if (phoneMap['phone'] != null) {
          phone = phoneMap['phone'];
          phoneVerified = (phoneMap['spi'] != null);
        }
      });
    });
    getIdentity().then((identityMap) {
      setState(() {
        if (identityMap['identityName'] != null) {
          identityVerified = (identityMap['identityName'] != null);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutDrawer(
      titleText: 'Identification verification',
      content: Stack(
        children: [
          SvgPicture.asset(
            'assets/bg.svg',
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Container(
              child: FutureBuilder(
            future: getKYCLevel(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (isInIdentityProcess) {
                  return Container(child: SizedBox(child: _inShuftiVerificationProcess()));
                }

                if (isLoading) {
                  return _pleaseWait();
                }

                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: [
                            AnimatedBuilder(
                                animation: Listenable.merge(
                                    [Globals().emailVerified, Globals().phoneVerified, Globals().identityVerified]),
                                builder: (BuildContext context, _) {
                                  return Container(
                                    child: Column(
                                      children: [
                                        // Step one: verify email
                                        _fillCard(getCorrectState(1, emailVerified, phoneVerified, identityVerified), 1,
                                            email, Icons.email),

                                        // Step two: verify phone
                                        _fillCard(getCorrectState(2, emailVerified, phoneVerified, identityVerified), 2,
                                            phone.isEmpty ? 'Unknown' : phone, Icons.phone),

                                        // Step three: verify identity
                                        _fillCard(getCorrectState(3, emailVerified, phoneVerified, identityVerified), 3,
                                            extract3Bot(doubleName), Icons.perm_identity)
                                      ],
                                    ),
                                  );
                                })
                          ],
                        ),
                      ),
                    )
                  ],
                );
              }
              return _pleaseWait();
            },
          )),
        ],
      ),
    );
  }

  Widget _pleaseWait() {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 10,
          ),
          new CircularProgressIndicator(),
          SizedBox(
            height: 10,
          ),
          new Text("One moment please"),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget _inShuftiVerificationProcess() {
    return Container(
        child: new ShuftiPro(
            authObject: authObject,
            createdPayload: createdPayload,
            async: false,
            callback: (res) async {
              // For some reason, Shufti returns bad JSON in case when request is canceled
              // "verification_process_closed", "1","message", "User cancel the verification process"

              try {
                if (!isJson(res)) {
                  String resData = res.toString();

                  if (resData.contains('verification_process_closed')) {
                    return showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) => CustomDialog(
                        image: Icons.close,
                        title: "Request canceled",
                        description: "Verification process has been canceled.",
                        actions: [
                          FlatButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                              },
                              child: Text('OK'))
                        ],
                      ),
                    );
                  }

                  if (resData.contains('internet.connection.problem')) {
                    return showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) => CustomDialog(
                        image: Icons.close,
                        title: "Request canceled",
                        description: "Please make sure your internet connection is stable.",
                        actions: [
                          FlatButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                              },
                              child: Text('OK'))
                        ],
                      ),
                    );
                  }
                }

                Map<String, dynamic> data = jsonDecode(res);
                switch (data['event']) {
                  // AUTHORIZATION IS WRONG
                  case 'request.unauthorized':
                  // NO BALANCE
                  case 'request.invalid':
                  // DECLINED
                  case 'verification.declined':
                  // TIME OUT
                  case 'request.timeout':
                    {
                      Events().emit(IdentityCallbackEvent(type: 'failed'));
                      break;
                    }

                  // ACCEPTED
                  case 'verification.accepted':
                    {
                      await verifyIdentity(reference);
                      await identityVerification(reference).then((value) {
                        if (value == null) {
                          return Events().emit(IdentityCallbackEvent(type: 'failed'));
                        }
                        Events().emit(IdentityCallbackEvent(type: 'success'));
                      });
                      break;
                    }
                  default:
                    {
                      return;
                    }
                    break;
                }
              } catch (e) {
                print(e);
              } finally {
                dispose();
              }
            },
            homeClass: HomeScreen()));
  }

  Widget _fillCard(String phase, int step, String text, IconData icon) {
    if (phase == 'Unverified') {
      return Container(
        decoration: BoxDecoration(border: Border.all(width: 0.5, color: Colors.grey)),
        height: 75,
        width: MediaQuery.of(context).size.width * 100,
        child: Row(
          children: [
            Padding(padding: EdgeInsets.only(left: 10)),
            Container(
              width: 30.0,
              height: 30.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('0' + step.toString(),
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))
                ],
              ),
              decoration: new BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2), shape: BoxShape.circle, color: Colors.white),
            ),
            Padding(padding: EdgeInsets.only(left: 20)),
            Icon(
              icon,
              size: 20,
              color: Colors.black,
            ),
            Padding(padding: EdgeInsets.only(left: 15)),
            Flexible(
                child: Container(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 18.0,
                  ),
                  Padding(padding: EdgeInsets.only(left: 5)),
                  Text(
                    'Not verified',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                  )
                ],
              ),
            ]))),
            Padding(padding: EdgeInsets.only(right: 10))
          ],
        ),
      );
    }

    if (phase == 'Verified') {
      return GestureDetector(
        onTap: () async {
          if (step != 3) {
            return null;
          }

          return showIdentityDetails();
        },
        child: Container(
          decoration: BoxDecoration(border: Border.all(width: 0.5, color: Colors.grey)),
          height: 75,
          width: MediaQuery.of(context).size.width * 100,
          child: Row(
            children: [
              Padding(padding: EdgeInsets.only(left: 10)),
              Container(
                width: 30.0,
                height: 30.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 15.0,
                    ),
                  ],
                ),
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green),
              ),
              Padding(padding: EdgeInsets.only(left: 20)),
              Icon(
                icon,
                size: 20,
                color: Colors.black,
              ),
              Padding(padding: EdgeInsets.only(left: 15)),
              Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                              constraints: BoxConstraints(
                                  minWidth: MediaQuery.of(context).size.width * 0.55,
                                  maxWidth: MediaQuery.of(context).size.width * 0.55),
                              child: Text(text,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            'Verified',
                            style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                          )
                        ],
                      )
                    ],
                  ),
                  step == 3
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.chevron_right, size: 20, color: Colors.black)],
                        )
                      : Column()
                ],
              )),
              Padding(padding: EdgeInsets.only(right: 10))
            ],
          ),
        ),
      );
    }

    if (phase == 'CurrentPhase') {
      return Container(
        decoration: BoxDecoration(
            border: Border(
                left: BorderSide(color: Colors.blue, width: 5),
                right: BorderSide(color: Colors.grey, width: 0.5),
                bottom: BorderSide(color: Colors.grey, width: 0.5),
                top: BorderSide(color: Colors.grey, width: 0.5))),
        height: 75,
        width: MediaQuery.of(context).size.width * 100,
        child: Row(
          children: [
            Padding(padding: EdgeInsets.only(left: 10)),
            Container(
              width: 30.0,
              height: 30.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('0' + step.toString(),
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))
                ],
              ),
              decoration: new BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2), shape: BoxShape.circle, color: Colors.white),
            ),
            Padding(padding: EdgeInsets.only(left: 15)),
            Icon(
              icon,
              size: 20,
              color: Colors.black,
            ),
            Padding(padding: EdgeInsets.only(left: 10)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width * 0.4,
                        maxWidth: MediaQuery.of(context).size.width * 0.4),
                    padding: EdgeInsets.all(10),
                    child: Text(text,
                        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis)),
                ElevatedButton(
                    onPressed: () async {
                      switch (step) {
                        // Verify email
                        case 1:
                          {
                            verifyEmail();
                          }
                          break;

                        // Verify phone
                        case 2:
                          {
                            await verifyPhone();
                          }
                          break;

                        // Verify identity
                        case 3:
                          {
                            await verifyIdentityProcess();
                            break;
                          }
                        default:
                          {}
                          break;
                      }
                    },
                    child: Text('Verify'))
              ],
            ),
            Padding(padding: EdgeInsets.only(right: 10))
          ],
        ),
      );
    }

    return Container();
  }



  Future verifyIdentityProcess() async {
    if (identityVerified) {
      return;
    }

    setState(() {
      this.isLoading = true;
    });

    try {
      Response accessTokenResponse = await getShuftiAccessToken();
      if (accessTokenResponse.statusCode != 200) {
        setState(() {
          this.isLoading = false;
        });

        return showDialog(
            context: context,
            builder: (BuildContext context) => CustomDialog(
                  image: Icons.warning,
                  title: "Maximum requests Reached",
                  description: "You already had 5 requests in last 24 hours. \nPlease try again in 24 hours.",
                  actions: <Widget>[
                    FlatButton(
                      child: new Text("Ok"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ));
      }

      Map<String, Object> details = jsonDecode(accessTokenResponse.body);
      authObject['access_token'] = details['access_token'];

      Response identityResponse = await sendVerificationIdentity();
      Map<String, Object> identityDetails = jsonDecode(identityResponse.body);
      String verificationCode = identityDetails['verification_code'];

      reference = verificationCode;

      createdPayload["reference"] = reference;
      createdPayload["document"] = verificationObj['document'];
      createdPayload["verification_mode"] = "image_only";

      setState(() {
        this.isLoading = false;
        this.isInIdentityProcess = true;
      });
    } catch (e) {
      setState(() {
        this.isLoading = false;
      });

      print(e);
      return showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          image: Icons.warning,
          title: "Failed to setup process",
          description: "Something went wrong. \n If this issue persist, please contact support",
          actions: <Widget>[
            FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
  }

  showIdentityDetails() {
    return showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
              child: FutureBuilder(
                future: getIdentity(),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (!snapshot.hasData) {
                    return _pleaseWait();
                  }

                  String name = getFullNameOfObject(jsonDecode(snapshot.data['identityName']));
                  return Container(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'OpenKYC ID CARD',
                                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(children: [
                                Text(
                                  'Your own personal KYC ID CARD',
                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ]),
                            ],
                          )),
                      Container(
                        padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                        color: HexColor('#f2f5f3'),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Full name',
                                  style: TextStyle(fontSize: 13, color: HexColor('#787878')),
                                )
                              ],
                            ),
                            Row(
                              children: [Text(name)],
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Birthday',
                                  style: TextStyle(fontSize: 13, color: HexColor('#787878')),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text(snapshot.data['identityDOB'] != 'None' ? snapshot.data['identityDOB'] : 'Unknown')
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                        color: HexColor('#f2f5f3'),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Country',
                                  style: TextStyle(fontSize: 13, color: HexColor('#787878')),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text(snapshot.data['identityCountry'] != 'None'
                                    ? snapshot.data['identityCountry']
                                    : 'Unknown')
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Gender',
                                  style: TextStyle(fontSize: 13, color: HexColor('#787878')),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text(snapshot.data['identityGender'] != 'None'
                                    ? snapshot.data['identityGender']
                                    : 'Unknown')
                              ],
                            )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FlatButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: Text('OK')),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      )
                    ],
                  ));
                },
              ),
            ));
  }

  emailResendDialog(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CustomDialog(
        image: Icons.check,
        title: "Email has been resent.",
        description: "A new verification email has been sent.",
        actions: <Widget>[
          FlatButton(
            child: new Text("Ok"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void verifyEmail() {
    if (emailVerified) {
      return;
    }

    sendVerificationEmail();
    emailResendDialog(context);
  }

  Future verifyPhone() async {
    if (phoneVerified) {
      return;
    }

    if (phone.isEmpty) {
      await addPhoneNumberDialog(context);

      var phoneMap = (await getPhone());
      if (phoneMap.isEmpty || !phoneMap.containsKey('phone')) {
        return;
      }
      String phoneNumber = phoneMap['phone'];
      if (phoneNumber == null || phoneNumber.isEmpty) {
        return;
      }

      setState(() {
        phone = phoneNumber;
      });

      if (phone.isEmpty) {
        return;
      }
    }

    int currentTime = new DateTime.now().millisecondsSinceEpoch;

    if (globals.tooManySmsAttempts && globals.lockedSmsUntill > currentTime) {
      globals.sendSmsAttempts = 0;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text('Too many attempts please wait ' +
                ((globals.lockedSmsUntill - currentTime) / 1000).round().toString() +
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
            title: new Text('Too many attemts please wait one minute.'),
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
  }
}
