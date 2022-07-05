import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:http/http.dart';
import 'package:threebotlogin/helpers/kyc_helpers.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/migration_service.dart';
import 'package:threebotlogin/services/pkid_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

class RecoverScreen extends StatefulWidget {
  final Widget? recoverScreen;

  RecoverScreen({Key? key, this.recoverScreen}) : super(key: key);

  _RecoverScreenState createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  final TextEditingController doubleNameController = TextEditingController();
  final TextEditingController seedPhraseController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String doubleName = '';
  String seedPhrase = '';
  String error = '';

  String errorStepperText = '';

  checkSeedPhrase(doubleName, seedPhrase) async {
    checkSeedLength(seedPhrase);
    KeyPair keyPair = await generateKeyPairFromSeedPhrase(seedPhrase);

    Response userInfoResult = await getUserInfo(doubleName);

    if (userInfoResult.statusCode != 200) {
      throw new Exception('Name was not found.');
    }

    Map<String, dynamic> body = json.decode(userInfoResult.body);

    if (body['publicKey'] != base64.encode(keyPair.pk)) {
      throw new Exception('Seed phrase does not match with $doubleName');
    }
  }

  continueRecoverAccount() async {
    try {
      KeyPair keyPair = await generateKeyPairFromSeedPhrase(seedPhrase);
      await savePrivateKey(keyPair.sk);
      await savePublicKey(keyPair.pk);

      FlutterPkid client = await getPkidClient(seedPhrase: seedPhrase);
      List<String> keyWords = ['email', 'phone', 'identity'];

      var futures = keyWords.map((keyword) async {
        var pKidResult = await client.getPKidDoc(keyword);
        return pKidResult.containsKey('data') && pKidResult.containsKey('success')
            ? jsonDecode(pKidResult['data'])
            : {};
      });

      var pKidResult = await Future.wait(futures);
      Map<int, dynamic> dataMap = pKidResult.asMap();

      await savePhrase(seedPhrase);
      await saveFingerprint(false);
      await saveDoubleName(doubleName);

      await handleKYCData(dataMap[0], dataMap[1], dataMap[2]);

      await fixPkidMigration();

    } catch (e) {
      print(e);
      throw Exception('Something went wrong');
    }
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
    seedPhraseController.dispose();
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
                    // suffixText: '.3bot',
                    suffixStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  controller: doubleNameController,
                  validator: (String? value) {
                    if (value!.isEmpty) {
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
                controller: seedPhraseController,
                validator: (String? value) {
                  if (value!.isEmpty) {
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

                String doubleNameValue = doubleNameController.text
                    .toLowerCase()
                    .trim()
                    .replaceAll(new RegExp(r"\s+"), " ");

                if(doubleNameValue.endsWith('.3bot')) {
                  doubleNameValue  = doubleNameValue.replaceAll('.3bot', '');
                }

                String seedPhraseValue = seedPhraseController.text
                    .toLowerCase()
                    .trim()
                    .replaceAll(new RegExp(r"\s+"), " ");

                setState(() {
                  doubleNameController.text = doubleNameValue;
                  seedPhraseController.text = seedPhraseValue;

                  doubleName = doubleNameController.text + '.3bot';
                  seedPhrase = seedPhraseController.text;
                });

                try {
                  showSpinner();

                  await checkSeedPhrase(doubleName, seedPhrase);
                  await continueRecoverAccount();

                  Navigator.pop(context); // To dismiss the spinner
                  Navigator.pop(context, true); // to dismiss the recovery screen.

                } catch (e) {
                  print(e);
                  Navigator.pop(context);
                  error = e.toString();
                  setState(() {});
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
