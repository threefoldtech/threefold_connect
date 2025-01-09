import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:http/http.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/kyc_helpers.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/screens/authentication_screen.dart';
import 'package:threebotlogin/services/gridproxy_service.dart';
import 'package:threebotlogin/services/identity_service.dart';
import 'package:threebotlogin/services/open_kyc_service.dart';
import 'package:threebotlogin/services/pkid_service.dart';
import 'package:threebotlogin/services/tools_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/widgets/kyc_widget.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:threebotlogin/widgets/phone_widget.dart';

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  State<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState
    extends State<IdentityVerificationScreen> {
  String doubleName = '';
  String phrase = '';
  String email = '';
  String phone = '';

  String reference = '';

  bool emailVerified = false;
  bool phoneVerified = false;

  bool isLoading = false;

  bool hidePhoneVerifyButton = false;

  Globals globals = Globals();

  final emailController = TextEditingController();
  final changeEmailController = TextEditingController();
  bool emailInputValidated = false;

  double spending = 0.0;

  int emailCountdown = 60;
  Timer? emailTimer;
  ValueNotifier<int> countdownNotifier = ValueNotifier(-1);

  void startOrResumeEmailCountdown({bool startNew = false}) {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int lockedUntil =
        Globals().emailSentOn + (Globals().emailMinutesCoolDown * 60 * 1000);
    int timeLeft = ((lockedUntil - currentTime) / 1000).round();

    if (startNew) {
      Globals().emailSentOn = currentTime;
      timeLeft = Globals().emailMinutesCoolDown * 60;
    }

    if (timeLeft > 0) {
      emailCountdown = timeLeft;
      countdownNotifier.value = emailCountdown;

      emailTimer?.cancel();

      emailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        int currentTime = DateTime.now().millisecondsSinceEpoch;
        int lockedUntil = Globals().emailSentOn +
            (Globals().emailMinutesCoolDown * 60 * 1000);
        int remainingTime = ((lockedUntil - currentTime) / 1000).round();

        if (remainingTime > 0) {
          countdownNotifier.value = remainingTime;
        } else {
          countdownNotifier.value = -1;
          timer.cancel();
        }
      });
    } else {
      countdownNotifier.value = -1;
    }
  }

  setEmailVerified() {
    if (mounted) {
      setState(() {
        emailVerified = Globals().emailVerified.value;
        if (emailVerified) {
          countdownNotifier.value = -1;
          emailTimer?.cancel();
        }
      });
    }
  }

  setPhoneVerified() {
    if (mounted) {
      setState(() {
        phoneVerified = Globals().phoneVerified.value;
        Globals().smsSentOn = 0;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    Globals().emailVerified.addListener(setEmailVerified);
    Globals().phoneVerified.addListener(setPhoneVerified);
    checkPhoneStatus();
    getUserValues();
    startOrResumeEmailCountdown();
  }

  @override
  void dispose() {
    emailTimer?.cancel();
    countdownNotifier.dispose();
    super.dispose();
  }

  checkPhoneStatus() {
    if (Globals().smsSentOn + (Globals().smsMinutesCoolDown * 60 * 1000) >
        DateTime.now().millisecondsSinceEpoch) {
      return Globals().hidePhoneButton.value = true;
    }

    return Globals().hidePhoneButton.value = false;
  }

  void getUserValues() {
    getDoubleName().then((dn) {
      setState(() {
        doubleName = dn!;
      });
    });
    getPhrase().then((seedPhrase) {
      setState(() {
        phrase = seedPhrase!;
      });
    });
    getEmail().then((emailMap) {
      setState(() {
        if (emailMap['email'] != null) {
          email = emailMap['email']!;
          changeEmailController.text = email;
          emailVerified = (emailMap['sei'] != null);
        }
      });
    });
    getPhone().then((phoneMap) {
      setState(() {
        if (phoneMap['phone'] != null) {
          phone = phoneMap['phone']!;
          phoneVerified = (phoneMap['spi'] != null);
        }
      });
    });
    getSpending();
  }

  Widget customDivider({
    required BuildContext context,
  }) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: const Divider(
          thickness: 0.5,
          color: Colors.grey,
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return LayoutDrawer(
      titleText: 'Identity',
      content: 
      FutureBuilder(
        future: getEmail(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (isLoading) {
              return pleaseWait(context);
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        Globals().emailVerified,
                        Globals().phoneVerified,
                      ]),
                      builder: (BuildContext context, _) {
                        return Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(
                                doubleName.isNotEmpty
                                    ? doubleName.substring(
                                        0, doubleName.length - 5)
                                    : 'Unknown',
                              ),
                            ),
                            customDivider(context: context),
                            FutureBuilder(
                              future: getPhrase(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 2.0),
                                    child: ListTile(
                                      trailing: const Icon(Icons.visibility),
                                      leading: const Icon(Icons.vpn_key),
                                      title: const Text('Show phrase'),
                                      onTap: () async {
                                        _showPhrase();
                                      },
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                            customDivider(context: context),

                                // Step one: verify email
                                _fillCard(
                                    getCorrectState(1, emailVerified,
                                        phoneVerified),
                                    1,
                                    email,
                                    Icons.email),
                                customDivider(context: context),

                                // Step two: verify phone
                                (Globals().phoneVerification == true ||
                                        (Globals().spendingLimit > 0 &&
                                            spending > Globals().spendingLimit))
                                    ? _fillCard(
                                        getCorrectState(2, emailVerified,
                                            phoneVerified),
                                        2,
                                        phone,
                                        Icons.phone)
                                    : Container(),
                                customDivider(context: context),
                                const ListTile(
                                  leading: Icon(Icons.info),
                                  title: Text(
                                    'KYC Verification has been moved to wallet page.'
                                  ),
                                ),                                

                              ],
                            );
                          })
                    ],
                  ),
                )
              
            );
          }
          return pleaseWait(context);
        },
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

  void _showPhrase() async {
    String? pin = await getPin();
    bool? authenticated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuthenticationScreen(
            correctPin: pin!,
            userMessage: 'Please enter your PIN code',
          ),
        ));

    if (authenticated != null && authenticated) {
      final phrase = await getPhrase();

      showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          hiddenAction: copySeedPhrase,
          image: Icons.info,
          title: 'Please write this down on a piece of paper',
          description: phrase.toString(),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
  }

  Future _loadingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () => Future.value(false),
          child: Dialog(
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
                  'One moment please',
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
      },
    );
  }

  Widget _fillCard(String phase, int step, String text, IconData icon) {
    switch (phase) {
      case 'Unverified':
        {
          return unVerifiedWidget(step, text, icon);
        }

      case 'Verified':
        {
          return verifiedWidget(step, text, icon);
        }

      case 'CurrentPhase':
        {
          return currentPhaseWidget(step, text, icon);
        }

      default:
        {
          return Container();
        }
    }
  }

  Widget unVerifiedWidget(step, text, icon) {
    return GestureDetector(
      onTap: () async {},
      child: Opacity(
        opacity: 0.5,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ListTile(
                leading: Icon(icon),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            text == '' ? 'Unknown' : text,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.close,
                          color: Theme.of(context).colorScheme.error,
                          size: 18.0,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Not verified',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget currentPhaseWidget(step, text, icon) {
    return GestureDetector(
        onTap: () async {
          if (step == 1 && countdownNotifier.value == -1) {
            return _changeEmailDialog(false);
          }

          if (step == 2) {
            if (Globals().hidePhoneButton.value == true) {
              return;
            }
            await addPhoneNumberDialog(context,
                newPhone: false, oldPhone: phone);

            var phoneMap = (await getPhone());
            if (phoneMap.isEmpty || !phoneMap.containsKey('phone')) {
              return;
            }

            String? phoneNumber = phoneMap['phone'];
            if (phoneNumber == null || phoneNumber.isEmpty) {
              return;
            }

            setState(() {
              phone = phoneNumber;
            });

            FlutterPkid client = await getPkidClient();
            client.setPKidDoc('phone', json.encode({'phone': phone}));

            if (phone.isEmpty) {
              return;
            }
          }
        },
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ListTile(
                leading: Icon(icon),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                        child: Container(
                            constraints: Globals().hidePhoneButton.value ==
                                        false ||
                                    (step != 2 &&
                                        Globals().hidePhoneButton.value == true)
                                ? BoxConstraints(
                                    minWidth:
                                        MediaQuery.of(context).size.width * 0.5,
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.5)
                                : BoxConstraints(
                                    minWidth:
                                        MediaQuery.of(context).size.width * 0.7,
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.7),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                              (text.isEmpty
                                                  ? 'Unknown'
                                                  : text),
                                        ),
                                      )
                                    ],
                                  ),
                                  if (step == 1)
                                    ValueListenableBuilder<int>(
                                      valueListenable: countdownNotifier,
                                      builder:
                                          (context, countdownValue, child) {
                                        if (countdownValue > 0) {
                                          return Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Text(
                                                  'Verification email sent, retry in $countdownValue second${countdownValue == 1 ? '' : 's'}',
                                                  overflow: TextOverflow.clip,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .warning),
                                                ),
                                              ),
                                            ],
                                          );
                                        } else {
                                          return Container();
                                        }
                                      },
                                    ),
                                  step == 2 &&
                                          Globals().hidePhoneButton.value ==
                                              true
                                      ? const SizedBox(
                                          height: 5,
                                        )
                                      : Container(),
                                  step == 2 &&
                                          Globals().hidePhoneButton.value ==
                                              true
                                      ? Row(
                                          children: <Widget>[
                                            Text(
                                              'SMS sent, retry in ${calculateMinutes()} minute${calculateMinutes() == '1' ? '' : 's'}',
                                              overflow: TextOverflow.clip,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .warning),
                                            )
                                          ],
                                        )
                                      : Container(),
                                ]))),
                    Globals().hidePhoneButton.value == true && step == 2
                        ? Container()
                        : ValueListenableBuilder(
                            valueListenable: countdownNotifier,
                            builder: (context, countdownValue, child) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: ElevatedButton(
                                    onPressed: countdownValue > 0
                                        ? null
                                        : () async {
                                            switch (step) {
                                              // Verify email
                                              case 1:
                                                {
                                                  startOrResumeEmailCountdown(
                                                      startNew: true);
                                                  verifyEmail();
                                                }
                                                break;

                                    // Verify phone
                                    case 2:
                                      {
                                        await verifyPhone();
                                      }
                                      break;
                                    default:
                                      {}
                                      break;
                                  }
                                },
                                child: const Text('Verify')));
                            }
                        )
                  ],
                ),
              ))
        ]));
  }

  String calculateMinutes() {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int lockedUntil =
        Globals().smsSentOn + (Globals().smsMinutesCoolDown * 60 * 1000);
    String difference =
        ((lockedUntil - currentTime) / 1000 / 60).round().toString();

    if (int.parse(difference) >= 0) {
      return difference;
    }

    return '0';
  }

  Widget verifiedWidget(step, text, icon) {
    return GestureDetector(
        onTap: () async {
          if (step == 1) {
            return _changeEmailDialog(false);
          }
          if (step == 2) {
            await addPhoneNumberDialog(context,
                newPhone: false, oldPhone: phone);
            var phoneMap = (await getPhone());
            String? phoneNumber = phoneMap['phone'];
            if (phone != phoneNumber) {
              setState(() {
                phone = phoneNumber!;
              });
            }
            return;
          }
        },
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ListTile(
                leading: Icon(icon),
                title: Row(
                  children: [
                    Row(
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
                                        minWidth:
                                            MediaQuery.of(context).size.width *
                                                0.65,
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.65),
                                    child: Text(
                                      text == '' ? 'Unknown' : text,
                                      overflow: TextOverflow.clip,
                                    ))
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  'Verified',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.bold),
                                )
                              ],
                            )
                          ],
                        ),
                        step == 1
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 15),
                                      child: Icon(
                                        Icons.edit,
                                      ),
                                    ),
                                  ])
                            : const Column(),
                        step == 2
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 15),
                                      child: Icon(
                                        Icons.edit,
                                      ),
                                    ),
                                  ])
                            : const Column(),
                      ],
                    ),
                  ],
                ),
              ))
        ]));
  }

  Future<dynamic> resendEmailDialog(context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CustomDialog(
        image: Icons.check,
        title: 'Email has been resent.',
        description: 'A verification email has been sent.',
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _changeEmailDialog(bool emailWasEmpty) {
    TextEditingController controller = TextEditingController();

    bool validEmail = false;
    String? errorEmail;
    Text statusMessage = const Text('');

    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(builder: (statefulContext, setCustomState) {
            return AlertDialog(
              title: emailWasEmpty == true
                  ? Text(
                      'Add email',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                              color: Theme.of(context).colorScheme.onSurface),
                    )
                  : Text('Change email',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                              color: Theme.of(context).colorScheme.onSurface)),
              contentPadding: const EdgeInsets.all(24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  emailWasEmpty == true
                      ? Text('Please pass us your email address',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface))
                      : Text(
                          'Changing your email will require re-verification.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface)),
                  TextField(
                    controller: controller,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: validEmail == true ? null : errorEmail),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  statusMessage
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () async {
                      _loadingDialog();

                      String emailValue = controller.text
                          .toLowerCase()
                          .trim()
                          .replaceAll(RegExp(r'\s+'), ' ');
                      bool isValidEmail = validateEmail(emailValue);

                      var oldEmail = await getEmail();

                      if (oldEmail['email'] == emailValue) {
                        validEmail = false;
                        errorEmail = 'Please enter a different email';
                        setCustomState(() {});
                        Navigator.pop(context);
                        return;
                      }

                      if (isValidEmail == false) {
                        validEmail = false;
                        errorEmail = 'Please enter a valid email';
                        setCustomState(() {});
                        Navigator.pop(context);
                        return;
                      }

                      try {
                        errorEmail = null;
                        await saveEmail(emailValue, null);

                        Response res = await updateEmailAddressOfUser();

                        if (res.statusCode != 200) {
                          throw Exception();
                        }

                        sendVerificationEmail();

                        email = emailValue;

                        await setIsEmailVerified(false);
                        await saveEmailToPKid();

                        Navigator.pop(context);
                        Navigator.pop(dialogContext);
                        resendEmailDialog(context);
                        startOrResumeEmailCountdown(startNew: true);

                        setState(() {});
                      } catch (e) {
                        logger.e(e);
                        Navigator.pop(context);

                        await saveEmail(oldEmail['email']!, oldEmail['sei']);
                        await saveEmailToPKid();

                        statusMessage = const Text('Something went wrong',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold));

                        setState(() {});
                        setCustomState(() {});
                      }
                    },
                    child: const Text('Ok'))
              ],
            );
          });
        });
  }

  Future<dynamic> showEmailChangeDialog() async {
    FlutterPkid client = await getPkidClient();

    var emailPKidResult = await client.getPKidDoc('email');
    logger.i(emailPKidResult);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change your email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please pass us your email address'),
              const SizedBox(height: 16),
              TextField(
                controller: changeEmailController,
                decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: emailInputValidated
                        ? null
                        : 'Please enter a valid email'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () async {
                bool isValid = checkEmail(changeEmailController.text);
                if (!isValid) {
                  setState(() {
                    emailInputValidated = false;
                  });
                  return;
                }

                setState(() {
                  emailInputValidated = true;
                  email = changeEmailController.text;
                });

                await saveEmail(changeEmailController.text, null);

                FlutterPkid client = await getPkidClient();

                client.setPKidDoc('email', json.encode({'email': email}));

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void verifyEmail() {
    if (emailVerified) {
      return;
    }

    if (email == '' && countdownNotifier.value == -1) {
      return _changeEmailDialog(true);
    }

    sendVerificationEmail();
    resendEmailDialog(context);
  }

  Future verifyPhone() async {
    if (phoneVerified) {
      return;
    }

    if (phone.isEmpty) {
      await addPhoneNumberDialog(context, newPhone: true, oldPhone: phone);

      var phoneMap = (await getPhone());
      if (phoneMap.isEmpty || !phoneMap.containsKey('phone')) {
        return;
      }
      String? phoneNumber = phoneMap['phone'];
      if (phoneNumber == null || phoneNumber.isEmpty) {
        return;
      }

      setState(() {
        phone = phoneNumber;
      });

      FlutterPkid client = await getPkidClient();
      client.setPKidDoc('phone', json.encode({'phone': phone}));

      startPhoneNumberCounter();
      return;
    } else {
      PhoneAlertDialogState().sendPhoneVerification();
      return;
    }
  }

  void startPhoneNumberCounter() {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    if (globals.tooManySmsAttempts && globals.lockedSmsUntil > currentTime) {
      globals.sendSmsAttempts = 0;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                'Too many attempts please wait ${((globals.lockedSmsUntil - currentTime) / 1000).round()} seconds.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
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
    if (globals.sendSmsAttempts >= 2) {
      globals.tooManySmsAttempts = true;
      globals.lockedSmsUntil = currentTime + 60000;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Too many attempts please wait one minute.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
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
    Globals().hidePhoneButton.value = true;
    Globals().smsSentOn = DateTime.now().millisecondsSinceEpoch;

    phoneSendDialog(context);
  }

  Future<void> getSpending() async {
    if (Globals().spendingLimit <= 0) return;
    try {
      setState(() {
        isLoading = true;
      });
      spending = await getMySpending();
    } catch (e) {
      final loadingSpendingFailure = SnackBar(
        content: Text(
          'Failed to load user spending',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Theme.of(context).colorScheme.errorContainer),
        ),
        duration: const Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(loadingSpendingFailure);
      logger.e('Failed to load user spending due to $e');
      spending = 0.0;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
