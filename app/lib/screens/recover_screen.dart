import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:http/http.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:threebotlogin/helpers/kyc_helpers.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/migration_service.dart';
import 'package:threebotlogin/services/pkid_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

class RecoverScreen extends StatefulWidget {
  const RecoverScreen({super.key, this.recoverScreen});

  final Widget? recoverScreen;

  @override
  State<RecoverScreen> createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  final TextEditingController doubleNameController = TextEditingController();
  final TextEditingController seedPhraseController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String doubleName = '';
  String seedPhrase = '';
  String error = '';

  String errorStepperText = '';

  validateNameSeed(doubleName, seedPhrase) async {
    try {
      // Check connectivity first
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        throw ('No internet connection. Please check your network.');
      }

      // Get user info with timeout
      Response userInfoResult = await getUserInfo(doubleName).timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          throw TimeoutException('Loading user information timed out');
        },
      );

      await validateName(doubleName, userInfoResult);
      await validateSeed(seedPhrase, userInfoResult);
    } on TimeoutException catch (e) {
      logger.e('Timeout during name/seed validation', error: e);
      throw ('Login timed out. Please check your network connection.');
    } catch (e) {
      rethrow;
    }
  }

  validateName(String doubleName, userInfoResult) async {
    if (doubleName == '.3bot') {
      throw ('Name is required.');
    }

    if (userInfoResult.statusCode != 200) {
      throw ('Name was not found.');
    }
  }

  validateSeed(String seedPhrase, userInfoResult) async {
    if (seedPhrase.isEmpty) {
      throw ('Seed Phrase is required');
    }
    try {
      checkSeedLength(seedPhrase);
      KeyPair keyPair = await generateKeyPairFromSeedPhrase(seedPhrase);
      Map<String, dynamic> body = json.decode(userInfoResult.body);
      if (body['publicKey'] != base64.encode(keyPair.publicKey)) {
        throw ('Seed phrase does not match with ${doubleName.replaceAll('.3bot', '')}');
      }
    } catch (e) {
      if (e.toString().contains('Invalid mnemonic')) {
        throw ('Invalid mnemonic');
      }
      rethrow;
    }
  }

  continueRecoverAccount() async {
    try {
      // Check connectivity before PKid operations
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        throw ('No internet connection. Please check your network.');
      }

      KeyPair keyPair = await generateKeyPairFromSeedPhrase(seedPhrase);
      await savePrivateKey(keyPair.secretKey.extractBytes());
      await savePublicKey(keyPair.publicKey);

      FlutterPkid client = await getPkidClient(seedPhrase: seedPhrase);
      List<String> keyWords = ['email', 'phone'];

      var futures = keyWords.map((keyword) async {
        var pKidResult = await client.getPKidDoc(keyword).timeout(
          const Duration(minutes: 1),
          onTimeout: () {
            throw TimeoutException('Loading $keyword data timed out');
          },
        );
        return pKidResult.containsKey('data') &&
                pKidResult.containsKey('success')
            ? jsonDecode(pKidResult['data'])
            : {};
      });

      var pKidResult = await Future.wait(futures).timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          throw TimeoutException('Loading account data timed out');
        },
      );
      Map<int, dynamic> dataMap = pKidResult.asMap();

      await savePhrase(seedPhrase);
      await saveFingerprint(false);
      await saveDoubleName(doubleName);
      await handleKYCData(dataMap[0], dataMap[1]);

      await fixPkidMigration();
    } on TimeoutException catch (e) {
      logger.e('Timeout during account recovery', error: e);
      throw ('Account recovery timed out. Please check your network connection.');
    } catch (e) {
      logger.e('Error during account recovery', error: e);
      if (e.toString().contains('No internet connection')) {
        rethrow;
      }
      throw ('Something went wrong during account recovery. Please try again.');
    }
  }

  checkSeedLength(seedPhrase) {
    int seedLength = seedPhrase.split(' ').length;
    if (seedLength == 1) {
      throw ('Seed phrase is required.');
    }
    if (seedLength <= 23) {
      throw ('Seed phrase is too short');
    } else if (seedLength > 24) {
      throw ('Seed phrase is too long');
    }
  }

  @override
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
        title: const Text('Log In'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: recoverForm(),
        ),
      ),
    );
  }

  Widget recoverForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Please insert your info',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      decorationColor: Theme.of(context).colorScheme.onSurface),
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Name',
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
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    decorationColor: Theme.of(context).colorScheme.onSurface),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Seed Phrase',
                ),
                controller: seedPhraseController,
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return 'Please enter your Seed phrase';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                error,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(),
              child: Text(
                'Log In',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              onPressed: () async {
                setState(() {
                  error = '';
                });

                FocusScope.of(context).requestFocus(FocusNode());

                String doubleNameValue = doubleNameController.text
                    .toLowerCase()
                    .trim()
                    .replaceAll(RegExp(r'\s+'), ' ');

                if (doubleNameValue.endsWith('.3bot')) {
                  doubleNameValue = doubleNameValue.replaceAll('.3bot', '');
                }

                String seedPhraseValue = seedPhraseController.text
                    .toLowerCase()
                    .trim()
                    .replaceAll(RegExp(r'\s+'), ' ');

                setState(() {
                  doubleNameController.text = doubleNameValue;
                  seedPhraseController.text = seedPhraseValue;

                  doubleName = '${doubleNameController.text}.3bot';
                  seedPhrase = seedPhraseController.text;
                });

                try {
                  showSpinner();

                  await validateNameSeed(doubleName, seedPhrase);
                  await continueRecoverAccount();

                  // To dismiss the spinner
                  Navigator.pop(context);
                  // to dismiss the recovery screen.
                  Navigator.pop(context, true);
                } catch (e) {
                  logger.e(e);
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
            const SizedBox(
              height: 10,
            ),
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Loading',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
