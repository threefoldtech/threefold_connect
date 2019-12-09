import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'RegistrationWithoutScanScreen.dart';

class RecoverScreen extends StatefulWidget {
  final Widget recoverScreen;
  RecoverScreen({Key key, this.recoverScreen}) : super(key: key);
  _RecoverScreenState createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  final doubleNameController = TextEditingController();
  final emailController = TextEditingController();
  final seedPhrasecontroller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _autoValidate = false;
  bool emailVerified = false;
  bool emailCheck = false;

  String doubleName = '';
  String emailFromForm = '';
  String seedPhrase = '';

  String error = '';

  String privateKey;

  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  checkSeedPhrase(doubleName, seedPhrase) async {
    checkSeedLength(seedPhrase);
    var keys = await generateKeysFromSeedPhrase(seedPhrase);

    setState(() {
      privateKey = keys['privateKey'];
    });

    var userInfoResult = await getUserInfo(doubleName);

    if (userInfoResult.statusCode != 200) {
      throw new Exception('User not found');
    }

    var body = json.decode(userInfoResult.body);

    if (body['publicKey'] != keys['publicKey']) {
      throw new Exception('Seed phrase does not correspond to given name');
    }
  }

  continueRecoverAccount() async {
    updateDeviceId(await messaging.getToken(), doubleName, privateKey)
        .then((onValue) {
      logger.log(onValue);
    }).catchError((e) {
      logger.log(e);
    });

    var registrationData = {
      "privateKey": privateKey,
      "doubleName": doubleName,
      "emailVerified": emailVerified,
      "email": emailFromForm,
      "phrase": seedPhrase,
    };

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RegistrationWithoutScanScreen(
                registrationData,
                resetPin: true)));
  }

  checkSeedLength(seedPhrase) {
    int seedLength = seedPhrase.split(" ").length;
    if (seedLength <= 23) {
      throw new Exception('Seed phrase is too short');
    } else if (seedLength > 24) {
      throw new Exception('Seed phrase is too long');
    }
  }

  String validateEmail(String value) {
    Pattern pattern = r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      emailCheck = false;
      return 'Enter Valid Email';
    }
    emailCheck = true;
    return null;
  }

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    doubleNameController.dispose();
    emailController.dispose();
    seedPhrasecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recover Account'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).primaryColor,
        child: Container(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Container(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: recoverForm(),
                  ),
                ),
              ),
            ),
          ),
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
                    labelText: 'Name',
                    suffixText: '.3bot',
                    suffixStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  controller: doubleNameController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter your Name';
                    }
                    return null;
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.5),
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Email'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Enter an email';
                  }
                  return null;
                },
                controller: emailController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.5),
              child: TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Seed phrase'),
                controller: seedPhrasecontroller,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Enter your Seedphrase';
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
              color: Theme.of(context).accentColor,
              onPressed: () async {
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
                setState(() {
                  error = '';
                });
                FocusScope.of(context).requestFocus(new FocusNode());
                setState(() {
                  _autoValidate = true;
                  doubleName = doubleNameController.text + '.3bot';
                  emailFromForm = emailController.text;
                  seedPhrase = seedPhrasecontroller.text;
                  validateEmail(emailFromForm);
                });
                try {
                  if (emailFromForm != null &&
                      emailFromForm.isNotEmpty &&
                      emailCheck == true) {
                    await checkSeedPhrase(doubleName, seedPhrase);
                    // await checkEmail(doubleName, (emailFromForm.toLowerCase()));
                    Navigator.pop(context);
                    await continueRecoverAccount();
                  } else {
                    throw new Exception('Please enter an email.');
                  }
                } catch (e) {
                  Navigator.pop(context);
                  logger.log(e);
                  setState(() {
                    error = e.message;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
