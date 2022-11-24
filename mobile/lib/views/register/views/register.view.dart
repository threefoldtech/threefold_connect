import 'dart:convert';

import 'package:bip39/bip39.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:threebotlogin/api/3bot/services/user.service.dart';
import 'package:threebotlogin/api/kyc/services/kyc.service.dart';
import 'package:threebotlogin/core/auth/pin/views/change.pin.view.dart';
import 'package:threebotlogin/core/components/dialogs/loading.dialog.dart';
import 'package:threebotlogin/core/components/tabs/tabs.view.dart';
import 'package:threebotlogin/core/crypto/services/crypto.service.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';
import 'package:threebotlogin/core/storage/kyc/kyc.storage.dart';
import 'package:threebotlogin/core/styles/color.styles.dart';
import 'package:threebotlogin/pkid/helpers/pkid.helpers.dart';
import 'package:threebotlogin/views/identity/helpers/identity.helpers.dart';
import 'package:threebotlogin/views/register/classes/register.classes.dart';
import 'package:threebotlogin/views/register/helpers/register.helpers.dart';

class RegisterScreen extends StatefulWidget {
  final String? doubleName;

  RegisterScreen({this.doubleName});

  _RegisterScreenState createState() => _RegisterScreenState();
}

enum _State { DoubleName, Email, SeedPhrase, ConfirmSeedPhrase, Finish }

class RegistrationData {
  String username = '';
  String phrase = '';
  String email = '';
  late KeyPair kp;
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final mnemonicController = TextEditingController();

  _State state = _State.DoubleName;

  bool isVisible = false;
  bool didWriteSeed = false;

  String phraseConfirmationWords = '';
  String errorStepperText = '';

  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode seedFocus = FocusNode();

  RegistrationData _registrationData = RegistrationData();

  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  Future<void> validateEmail() async {
    emailController.text = emailController.text.toLowerCase().trim().replaceAll(new RegExp(r"\s+"), " ");
    setState(() {});

    bool validEmail = isValidEmail(emailController.text);
    if (!validEmail) {
      errorStepperText = "Please enter a valid email.";
      setState(() {});
      return;
    }

    _registrationData.email = emailController.text;
    state = _State.SeedPhrase;
    setState(() {});
  }

  Future<void> validationUsername() async {
    usernameController.text = usernameController.text.toLowerCase().trim().replaceAll(new RegExp(r"\s+"), " ");
    setState(() {});

    Map<String, dynamic> validatedUsername = await validateUsername(usernameController.text);
    if (validatedUsername['valid'] == false) {
      errorStepperText = validatedUsername['reason'];
      setState(() {});
      return;
    }

    _registrationData.username = usernameController.text + '.3bot';

    state = _State.Email;
    setState(() {});
  }

  Future<void> generateKeys() async {
    state = _State.ConfirmSeedPhrase;
    _registrationData.kp = generateKeyPairFromMnemonic(_registrationData.phrase);
    setState(() {});
  }

  void validateMnemonic() {
    mnemonicController.text = mnemonicController.text.toLowerCase().trim().replaceAll(new RegExp(r"\s+"), " ");

    bool isValidMnemonicConfirmation = validateMnemonicWords(_registrationData.phrase, mnemonicController.text);
    if (!isValidMnemonicConfirmation) {
      errorStepperText = 'Please enter the correct words.';
      setState(() {});
      return;
    }

    state = _State.Finish;
    setState(() {});
  }

  Future<void> addUserToBackend() async {
    showLoadingDialog(context);

    String publicKey = base64.encode(_registrationData.kp.pk);

    bool isCreated = await createUser(_registrationData.username, _registrationData.email, publicKey);
    if (!isCreated) {
      Navigator.pop(context);
      return;
    }

    saveRegistration();
  }

  void generateRegistrationMnemonic() {
    if (_registrationData.phrase != '') return;
    _registrationData.phrase = generateMnemonic(strength: 256);
  }

  checkStep(currentStep) async {
    switch (currentStep) {
      case _State.DoubleName:
        await validationUsername();
        FocusScope.of(context).requestFocus(emailFocus);
        break;
      case _State.Email:
        await validateEmail();
        generateRegistrationMnemonic();
        FocusScope.of(context).unfocus();
        break;
      case _State.SeedPhrase:
        await generateKeys();
        FocusScope.of(context).requestFocus(seedFocus);
        break;
      case _State.ConfirmSeedPhrase:
        validateMnemonic();
        FocusScope.of(context).unfocus();
        break;
      case _State.Finish:
        await addUserToBackend();
        break;
      default:
        break;
    }
  }

  checkStepFocus(currentStep) async {
    switch (currentStep) {
      case _State.DoubleName:
        FocusScope.of(context).requestFocus(nameFocus);
        break;
      case _State.Email:
        FocusScope.of(context).requestFocus(emailFocus);
        break;
      case _State.SeedPhrase:
        FocusScope.of(context).unfocus();
        break;
      case _State.ConfirmSeedPhrase:
        FocusScope.of(context).requestFocus(seedFocus);
        break;
      default:
        break;
    }
  }

  void saveRegistration() async {
    setPrivateKey(_registrationData.kp.sk);
    setPublicKey(_registrationData.kp.pk);
    setFingerPrint(false);
    setEmail(_registrationData.email, null);
    setUsername(_registrationData.username);
    setPhrase(_registrationData.phrase);

    await saveEmailToPKid();
    await savePhoneToPKid();

    sendVerificationEmail(_registrationData.username, _registrationData.email, base64.encode(_registrationData.kp.pk));

    await Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePinScreen(hideBackButton: true)));
    Navigator.of(context).popUntil((route) => route.isFirst);

    await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TabsScreen()));
  }

  Widget registrationStepper() {
    return Stepper(
      controlsBuilder: (BuildContext context, ControlsDetails details) {
        return Column(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: kAppBarColor),
                  onPressed: () {
                    details.onStepCancel!();
                  },
                  child: Text(
                    state == _State.DoubleName ? 'CANCEL' : 'PREVIOUS',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: kAppBarColor),
                  onPressed: state == _State.SeedPhrase && didWriteSeed == false
                      ? null
                      : () {
                          details.onStepContinue!();
                        },
                  child: Text(
                    state == _State.Finish ? 'FINISH' : 'NEXT',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ],
        );
      },
      type: StepperType.vertical,
      steps: [
        Step(
          // Ask DoubleName
          isActive: state.index >= _State.DoubleName.index,
          state: state.index > _State.DoubleName.index
              ? StepState.complete
              : state == _State.DoubleName
                  ? StepState.editing
                  : StepState.disabled,
          title: Text('ThreeFold Connect Id.'),
          subtitle: state.index > 0 ? Text(usernameController.text) : null,
          content: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Hi, please choose a ThreeFold Connect username.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.5),
                    child: TextFormField(
                      focusNode: nameFocus,
                      maxLength: 50,
                      autofocus: true,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Name',
                        // suffixText: '.3bot',
                        suffixStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      controller: usernameController,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]"))],
                      enableSuggestions: false,
                      autocorrect: false,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          errorStepperText,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
        ),
        Step(
          isActive: state.index >= _State.Email.index,
          state: state.index > _State.Email.index
              ? StepState.complete
              : state == _State.Email
                  ? StepState.editing
                  : StepState.disabled,
          title: Text('Email'),
          subtitle: state.index > _State.Email.index ? Text(emailController.text) : null,
          content: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ReusableTextFieldStep(
                focusNode: emailFocus,
                titleText: 'What is your email?',
                labelText: 'Email',
                typeText: TextInputType.emailAddress,
                errorStepperText: errorStepperText,
                controller: emailController,
              ),
            ),
          ),
        ),
        Step(
          isActive: state.index >= _State.SeedPhrase.index,
          state: state.index > _State.SeedPhrase.index
              ? StepState.complete
              : state == _State.SeedPhrase
                  ? StepState.editing
                  : StepState.disabled,
          title: Text('Seed phrase'),
          content: Card(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ReusableTextStep(
                      titleText:
                          'In order to ever retrieve your tokens in case of switching to a new device or app, you will have to enter your seedphrase in combination with your TF Connect username. \n\nPlease write this seedphrase and your username on a piece of paper and keep it in a secure place. Do not communicate this key to anyone. ThreeFold can not be held responsible in case of loss of this seedphrase.',
                      extraText: _registrationData.phrase,
                      errorStepperText: errorStepperText,
                    ),
                    CheckboxListTile(
                      title: Text(
                        "I have written down my seedphrase and username",
                        style: TextStyle(fontSize: 14),
                      ),
                      value: didWriteSeed,
                      onChanged: (newValue) {
                        didWriteSeed = newValue!;
                        setState(() {});
                      },
                      controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
                    )
                  ],
                )),
          ),
        ),
        Step(
          isActive: state.index >= _State.ConfirmSeedPhrase.index,
          state: state.index > _State.ConfirmSeedPhrase.index
              ? StepState.complete
              : state == _State.ConfirmSeedPhrase
                  ? StepState.editing
                  : StepState.disabled,
          title: Text('Confirm seed phrase'),
          content: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ReusableTextFieldStep(
                focusNode: seedFocus,
                titleText: 'Type 3 random words from your seed phrase, separated by a space.',
                labelText: 'Seed phrase words',
                typeText: TextInputType.text,
                errorStepperText: errorStepperText,
                controller: mnemonicController,
              ),
            ),
          ),
        ),
        Step(
          isActive: state.index >= _State.Finish.index,
          state: state.index > _State.Finish.index
              ? StepState.complete
              : state == _State.Finish
                  ? StepState.editing
                  : StepState.disabled,
          title: Text('Finishing'),
          content: Card(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Please check the data below, press finish if it is correct. Otherwise click the pencil icon to edit them.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text(usernameController.text),
                    trailing: Icon(Icons.edit),
                    onTap: () => setState(() {
                      state = _State.DoubleName;
                      FocusScope.of(context).requestFocus(nameFocus);
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 15.0),
                  child: ListTile(
                      leading: Icon(Icons.email),
                      title: Text(emailController.text),
                      trailing: Icon(Icons.edit),
                      onTap: () => setState(() {
                            state = _State.Email;
                            FocusScope.of(context).requestFocus(emailFocus);
                          })),
                ),
              ],
            ),
          ),
        )
      ],
      currentStep: state.index,
      onStepTapped: (index) {
        setState(() {
          state = _State.values[index];
        });
        checkStepFocus(state);
      },
      onStepContinue: () {
        errorStepperText = '';
        checkStep(state);
      },
      onStepCancel: () {
        setState(
          () {
            errorStepperText = '';
            if (state.index > _State.DoubleName.index) {
              state = _State.values[state.index - 1];
            } else {
              Navigator.pop(context);
            }
          },
        );
        checkStepFocus(state);
      },
    );
  }

  Widget errorWidget() {
    return errorStepperText.isNotEmpty
        ? Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  errorStepperText,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: Text('ThreeFold Connect - Registration'),
      ),
      body: registrationStepper(),
    );
  }
}
