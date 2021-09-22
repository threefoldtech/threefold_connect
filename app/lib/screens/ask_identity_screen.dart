import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:threebotlogin/services/user_service.dart';
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

  var authObject = {
    "auth_type": "basic_auth",
    "client_id": dotenv.env['SHUFTI_CLIENT_ID'],
    "secret_key": dotenv.env['SHUFTI_CLIENT_SECRET'],
  };

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


  @override
  void initState() {
    super.initState();

    setState(() async {
      createdPayload["document"] = verificationObj['document'];
      // createdPayload["face"] = verificationObj['face'];
      createdPayload["verification_mode"] = "image_only";


      var v = DateTime.now();
      var reference = "ShuftiPro_Flutter_$v";
      createdPayload["reference"] = reference;

      var email = await getEmail();
      createdPayload['email'] = email;



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
                                        callback: (res) {
                                          Map<String, dynamic> data = jsonDecode(res);

                                          // print("\n\nResponse: " +
                                          //     res.toString());


                                          print('EVENT');
                                          print(data['event']);
                                          print('GEOLOCATION');
                                          print(data['geolocation']);
                                          print('VERIFICATION DATA');
                                          print(data['verification_data']);


                                          if(data['event'] == 'verification.accepted') {
                                            // TODO: SET VARIABLE IN GLOBALS ON TRUE
                                          }

                                        //  TODO: GIVE INVALID VERIFICATION


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
