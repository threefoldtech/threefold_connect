import 'package:flutter/material.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/screens/RegistrationWithoutScanScreen.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/toolsService.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/widgets/CustomScaffold.dart';
import 'package:threebotlogin/widgets/ReusableTextStep.dart';
import 'package:threebotlogin/widgets/ReuseableTextFieldStep.dart';

class MobileRegistrationScreen extends StatefulWidget {
  final String doubleName;

  MobileRegistrationScreen({this.doubleName});

  _MobileRegistrationScreenState createState() =>
      _MobileRegistrationScreenState();
}

class _MobileRegistrationScreenState extends State<MobileRegistrationScreen> {
  final doubleNameController = TextEditingController();
  final emailController = TextEditingController();
  final seedConfirmationController = TextEditingController();

  int _index;
  bool isVisible = false;
  String phrase = '';
  String phraseConfirmationWords = '';
  String doubleName;

  String errorStepperText;

  Map<String, String> keys;

  @override
  void initState() {
    _index = 0;
    errorStepperText = '';
    if (widget.doubleName != null) {
      setState(() {
        doubleNameController.text = widget.doubleName;
      });
    }
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  checkStep(currentStep) async {
    switch (currentStep) {
      case 0:
        loadingDialog();
        if (doubleNameController.text != null ||
            doubleNameController.text != '') {
          doubleName = doubleNameController.text + '.3bot';
          var doubleNameValidation =
              validateDoubleName(doubleNameController.text);
          if (doubleNameValidation == null) {
            var userInfoResult = await getUserInfo(doubleName);
            if (userInfoResult.statusCode != 200) {
              setState(() {
                _index++;
              });
            } else {
              setState(() {
                errorStepperText = 'Name already exists.';
              });
            }
          } else {
            setState(() {
              errorStepperText = 'Name needs to be alphanumeric';
            });
          }
        } else {
          setState(() {
            errorStepperText = 'Name can\'t be empty';
          });
        }
        Navigator.pop(context);
        break;
      case 1:
        var emailValidation = validateEmail(emailController.text);
        setState(() {
          loadingDialog();
          if (emailValidation == null) {
            _index++;
          } else {
            errorStepperText = emailValidation;
          }
          Navigator.pop(context);
        });
        if (phrase == null || phrase == '') {
          phrase = await generateSeedPhrase();
        }
        break;
      case 2:
        setState(() {
          _index++;
        });
        keys = await generateKeysFromSeedPhrase(phrase);
        break;
      case 3:
        bool seedWordConfirmationValidation =
            validateSeedWords(phrase, seedConfirmationController.text);
        if (seedWordConfirmationValidation) {
          setState(() {
            _index++;
          });
        } else {
          setState(() {
            errorStepperText = 'Words are not correct.';
          });
        }
        break;
      case 4:
        loadingDialog();
        var response = await finishRegistration(doubleNameController.text,
            emailController.text, 'random', keys['publicKey']);
        if (response.statusCode == 200) {
          registrationToPin();
        } else {
          Navigator.popAndPushNamed(context, '/');
        }
        break;
      default:
        break;
    }
  }

  void registrationToPin() async {
    updateDeviceId(await messaging.getToken(), doubleName, keys['privateKey']);

    var registrationData = {
      "privateKey": keys['privateKey'],
      "doubleName": doubleNameController.text + '.3bot',
      "emailVerified": false,
      "email": emailController.text,
      "phrase": phrase,
    };

    // Close the modal since we are navigating to another screen
    Navigator.of(context, rootNavigator: true).pop();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RegistrationWithoutScanScreen(
                registrationData,
                resetPin: true)));
  }

  loadingDialog() {
    return showDialog(
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

  Widget registrationStepper() {
    return Theme(
      data: ThemeData(
        primaryColor: Theme.of(context).accentColor,
        accentColor: Theme.of(context).primaryColor,
      ),
      child: Stepper(
        controlsBuilder: (BuildContext context,
            {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
          return Column(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      onStepCancel();
                    },
                    child: Text(
                      _index == 0 ? 'CANCEL' : 'PREVIOUS',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Theme.of(context).accentColor,
                  ),
                  FlatButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      onStepContinue();
                    },
                    child: Text(
                      _index == 4 ? 'FINISH' : 'NEXT',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Theme.of(context).accentColor,
                  )
                ],
              ),
            ],
          );
        },
        type: StepperType.vertical,
        steps: [
          Step(
            isActive: _index >= 0,
            state: _index > 0
                ? StepState.complete
                : _index == 0 ? StepState.editing : StepState.disabled,
            title: Text('3Bot name'),
            subtitle: _index > 0 ? Text(doubleNameController.text) : null,
            content: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Hi, please choose a 3Bot name.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Divider(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.5),
                      child: TextField(
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Name',
                          suffixText: '.3bot',
                          suffixStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        controller: doubleNameController,
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
            isActive: _index >= 1,
            state: _index > 1
                ? StepState.complete
                : _index == 1 ? StepState.editing : StepState.disabled,
            title: Text('Email'),
            subtitle: _index > 1 ? Text(emailController.text) : null,
            content: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ReuseableTextFieldStep(
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
            isActive: _index >= 2,
            state: _index > 2
                ? StepState.complete
                : _index == 2 ? StepState.editing : StepState.disabled,
            title: Text('Seed phrase'),
            content: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ReuseableTextStep(
                  titleText:
                      'Please write this on a piece of paper and keep it in a secure place.',
                  extraText: phrase,
                  errorStepperText: errorStepperText,
                ),
              ),
            ),
          ),
          Step(
            isActive: _index >= 3,
            state: _index > 3
                ? StepState.complete
                : _index == 3 ? StepState.editing : StepState.disabled,
            title: Text('Confirm seed phrase'),
            content: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ReuseableTextFieldStep(
                  titleText:
                      'Type 3 random words from your seed phrase, separated by a space.',
                  labelText: 'Seed phrase words',
                  typeText: TextInputType.text,
                  errorStepperText: errorStepperText,
                  controller: seedConfirmationController,
                ),
              ),
            ),
          ),
          Step(
            isActive: _index >= 4,
            state: _index > 4
                ? StepState.complete
                : _index == 4 ? StepState.editing : StepState.disabled,
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
                      'Please check the data below, press next if it is correct. Otherwise click the pencil icon to edit them.',
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
                      title: Text(doubleNameController.text),
                      trailing: Icon(Icons.edit),
                      onTap: () => setState(() {
                        _index = 0;
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
                              _index = 1;
                            })),
                  ),
                ],
              ),
            ),
          )
        ],
        currentStep: _index,
        onStepTapped: (index) {
          setState(() {
            _index = index;
          });
        },
        onStepContinue: () {
          errorStepperText = '';
          checkStep(_index);
        },
        onStepCancel: () {
          setState(
            () {
              errorStepperText = '';
              if (_index > 0) {
                _index--;
              } else {
                Navigator.pop(context);
              }
            },
          );
        },
      ),
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
    return CustomScaffold(
      appBar: AppBar(
        title: Text('3Bot connect - Registration'),
      ),
      body: registrationStepper(),
    );
  }
}
