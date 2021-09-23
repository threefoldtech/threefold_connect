import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/screens/preference_screen.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:shuftipro_flutter_sdk/ShuftiPro.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AskIdentityScreen extends StatefulWidget {
  @override
  _AskIdentityScreenState createState() => _AskIdentityScreenState();
}

class _AskIdentityScreenState extends State<AskIdentityScreen> {
  _AskIdentityScreenState() {}

  bool isDoc = true;
  bool isFace = true;

  // Create authentication object to have access to the API
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

  // Set isVerified to true + save the data
  Future<void> _executeAcceptedVerification(data) async {
    Globals().identityVerified.value = true;
    await saveIdentity(data);
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

      var dt = DateTime.now();
      var reference = "kyc-attempt-$dt";
      createdPayload["reference"] = reference;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutDrawer(
        titleText: 'Validate your identity',
        content: Stack(children: <Widget>[
          SvgPicture.asset(
            'assets/bg.svg',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => new ShuftiPro(
                                        authObject: authObject,
                                        createdPayload: createdPayload,
                                        async: false,
                                        callback: (res) async {
                                          Map<String, dynamic> data =
                                              jsonDecode(res);


                                          print('EVENT');
                                          print(data['event']);
                                          print('GEOLOCATION');
                                          print(data['geolocation']);
                                          print('VERIFICATION DATA');
                                          print(data['verification_data']);

                                          if (data['event'] ==
                                              'verification.accepted') {
                                            await _executeAcceptedVerification(data.toString());
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PreferenceScreen()));

                                            return showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) =>
                                                  CustomDialog(
                                                image: Icons.check,
                                                title:
                                                    "Identity has been verified",
                                                description:
                                                    "Your identity has been verified",
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

                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PreferenceScreen()));

                                          return showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) =>
                                                  CustomDialog(
                                                    image: Icons.error,
                                                    title: "Verified failed",
                                                    description:
                                                        "Verify has failed",
                                                    actions: <Widget>[
                                                      FlatButton(
                                                        child: new Text("Ok"),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ],
                                                  ));
                                        },
                                        homeClass: AskIdentityScreen())));
                          },
                          child: Text('Validate yourself')),
                    ],
                  ))
            ],
          ),
        ]));
  }
}
