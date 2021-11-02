import 'dart:convert';
import 'dart:core';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:http/http.dart';
import 'package:shuftipro_flutter_sdk/ShuftiProVerifications.dart';
import 'package:threebotlogin/helpers/kyc_helpers.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/migration_service.dart';
import 'package:threebotlogin/services/open_kyc_service.dart';
import 'package:threebotlogin/services/tools_service.dart';
import 'package:threebotlogin/services/user_service.dart';

class RecoverScreen extends StatefulWidget {
  final Widget recoverScreen;

  RecoverScreen({Key key, this.recoverScreen}) : super(key: key);

  _RecoverScreenState createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  final TextEditingController doubleNameController = TextEditingController();
  final TextEditingController seedPhrasecontroller = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _autoValidate = false;

  String doubleName = '';
  String seedPhrase = '';
  String error = '';
  String privateKey;

  String errorStepperText = '';

  checkSeedPhrase(doubleName, seedPhrase) async {
    checkSeedLength(seedPhrase);
    Map<String, String> keys = await generateKeysFromSeedPhrase(seedPhrase);

    setState(() {
      privateKey = keys['privateKey'];
    });

    Response userInfoResult = await getUserInfo(doubleName);

    if (userInfoResult.statusCode != 200) {
      throw new Exception('Name was not found.');
    }

    Map<String, dynamic> body = json.decode(userInfoResult.body);

    if (body['publicKey'] != keys['publicKey']) {
      throw new Exception('Seed phrase does not match with $doubleName');
    }
  }

  continueRecoverAccount() async {
    Map<String, String> keys = await generateKeysFromSeedPhrase(seedPhrase);
    await savePrivateKey(keys['privateKey']);
    await savePublicKey(keys['publicKey']);

    Map<String, dynamic> keyPair = await generateKeyPairFromSeedPhrase(seedPhrase);
    var client = FlutterPkid(pkidUrl, keyPair);

    List<String> keyWords = ['email', 'phone', 'identity'];

    var futures = keyWords.map((keyword) async {
      var pKidResult = await client.getPKidDoc(keyword, keyPair);
      return pKidResult.containsKey('data') && pKidResult.containsKey('success') ? jsonDecode(pKidResult['data']) : {};
    });

    var pKidResult = await Future.wait(futures);
    Map<int, Object> dataMap = pKidResult.asMap();


    await savePhrase(seedPhrase);
    await saveFingerprint(false);
    await saveDoubleName(doubleName);

    await handleKYCData(dataMap[0], dataMap[1], dataMap[2]);

    await migrateToNewSystem();
    // await sendVerificationEmail();
  }



  checkSeedLength(seedPhrase) {
    int seedLength = seedPhrase.split(" ").length;
    if (seedLength <= 23) {
      throw new Exception('Seed phrase is too short');
    } else if (seedLength > 24) {
      throw new Exception('Seed phrase is too long');
    }
  }

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    doubleNameController.dispose();
    seedPhrasecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Globals.color,
        title: Text('Recover Account'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: recoverForm(),
        ),
      ),
    );
  }

  Widget recoverForm() {
    return new Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Please insert your info',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.5),
              child: TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'NAME',
                    suffixText: '.3bot',
                    suffixStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  controller: doubleNameController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter your Name';
                    }
                    return null;
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.5),
              child: TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'SEED PHRASE'),
                controller: seedPhrasecontroller,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter your Seed phrase';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              error,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            RaisedButton(
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(10),
              child: Text(
                'Recover Account',
                style: TextStyle(color: Colors.white),
              ),
              color: Theme.of(context).primaryColor,
              onPressed: () async {
                setState(() {
                  error = '';
                });

                FocusScope.of(context).requestFocus(new FocusNode());

                String doubleNameValue =
                    doubleNameController.text?.toLowerCase()?.trim()?.replaceAll(new RegExp(r"\s+"), " ");
                String seedPhraseValue =
                    seedPhrasecontroller.text?.toLowerCase()?.trim()?.replaceAll(new RegExp(r"\s+"), " ");

                setState(() {
                  doubleNameController.text = doubleNameValue;
                  seedPhrasecontroller.text = seedPhraseValue;

                  _autoValidate = true;

                  doubleName = doubleNameController.text + '.3bot';
                  seedPhrase = seedPhrasecontroller.text;
                });

                try {
                  showSpinner();

                  await checkSeedPhrase(doubleName, seedPhrase);
                  await continueRecoverAccount();

                  Navigator.pop(context); // To dismiss the spinner
                  Navigator.pop(context, true); // to dismiss the recovery screen.

                } catch (e) {
                  print(e);
                  // To dismiss the spinner
                  Navigator.pop(context);
                  if (e.message != "") {
                    setState(() {
                      error = e.message;
                    });
                  } else {
                    setState(() {
                      error = "Something went wrong";
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void showSpinner() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
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
            new Text("Loading"),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
