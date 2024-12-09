import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:http/http.dart';
import 'package:idenfy_sdk_flutter/idenfy_sdk_flutter.dart';
import 'package:idenfy_sdk_flutter/models/auto_identification_status.dart';
import 'package:idenfy_sdk_flutter/models/idenfy_identification_status.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/identity_callback_event.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/kyc_helpers.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/models/idenfy.dart';
import 'package:threebotlogin/screens/authentication_screen.dart';
import 'package:threebotlogin/screens/wizard/web_view.dart';
import 'package:threebotlogin/services/gridproxy_service.dart';
import 'package:threebotlogin/services/idenfy_service.dart';
import 'package:threebotlogin/services/identity_service.dart';
import 'package:threebotlogin/services/open_kyc_service.dart';
import 'package:threebotlogin/services/pkid_service.dart';
import 'package:threebotlogin/services/tools_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
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

  String kycLogs = '';

  String reference = '';

  bool emailVerified = false;
  bool phoneVerified = false;
  bool identityVerified = false;

  bool isInIdentityProcess = false;
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

  setIdentityVerified() {
    if (mounted) {
      setState(() {
        identityVerified = Globals().identityVerified.value;
      });
    }
  }

  setHidePhoneVerify() {
    if (mounted) {
      setState(() {
        hidePhoneVerifyButton = Globals().identityVerified.value;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    Globals().emailVerified.addListener(setEmailVerified);
    Globals().phoneVerified.addListener(setPhoneVerified);
    Globals().identityVerified.addListener(setIdentityVerified);
    Globals().hidePhoneButton.addListener(setHidePhoneVerify);
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
    getIdentity().then((verificationDate) {
      setState(() {
        if (verificationDate['identityName'] != null) {
          identityVerified = true;
          setIsIdentityVerified(true);
        } else {
          identityVerified = false;
          setIsIdentityVerified(false);
        }
      });
    });
    getSpending();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutDrawer(
      titleText: 'Identity',
      content: FutureBuilder(
        future: getEmail(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (isLoading) {
              return _pleaseWait();
            }

            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 24, 15, 24),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                          animation: Listenable.merge([
                            Globals().emailVerified,
                            Globals().phoneVerified,
                            Globals().identityVerified
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
                                Center(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    child: const Divider(
                                      thickness: 0.5,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                FutureBuilder(
                                  future: getPhrase(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return ListTile(
                                        trailing: Icon(Icons.visibility),
                                        leading: const Icon(Icons.vpn_key),
                                        title: const Text('Show phrase'),
                                        onTap: () async {
                                          _showPhrase();
                                        },
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                                Center(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    child: const Divider(
                                      thickness: 0.5,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                // Step one: verify email
                                _fillCard(
                                    getCorrectState(1, emailVerified,
                                        phoneVerified, identityVerified),
                                    1,
                                    email,
                                    Icons.email),
                                Center(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    child: const Divider(
                                      thickness: 0.5,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                // Step two: verify phone
                                (Globals().phoneVerification == true ||
                                        (Globals().spendingLimit > 0 &&
                                            spending > Globals().spendingLimit))
                                    ? _fillCard(
                                        getCorrectState(2, emailVerified,
                                            phoneVerified, identityVerified),
                                        2,
                                        phone,
                                        Icons.phone)
                                    : Container(),
                                Center(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    child: const Divider(
                                      thickness: 0.5,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                // Step three: verify identity
                                (Globals().isOpenKYCEnabled ||
                                        (Globals().spendingLimit > 0 &&
                                            spending > Globals().spendingLimit))
                                    ? _fillCard(
                                        getCorrectState(3, emailVerified,
                                            phoneVerified, identityVerified),
                                        3,
                                        extract3Bot(doubleName),
                                        Icons.perm_identity)
                                    : Container(),

                                Globals().redoIdentityVerification &&
                                        identityVerified == true
                                    ? ElevatedButton(
                                        onPressed: () async {
                                          await verifyIdentityProcess();
                                        },
                                        child: const Text(
                                            'Redo identity verification'))
                                    : Container(),
                                Globals().debugMode == true
                                    ? ElevatedButton(
                                        onPressed: () async {
                                          bool? isEmailVerified =
                                              await getIsEmailVerified();
                                          bool? isPhoneVerified =
                                              await getIsPhoneVerified();
                                          bool? isIdentityVerified =
                                              await getIsIdentityVerified();

                                          kycLogs = '';
                                          kycLogs +=
                                              'Email verified: $isEmailVerified\n';
                                          kycLogs +=
                                              'Phone verified: $isPhoneVerified\n';
                                          kycLogs +=
                                              'Identity verified: $isIdentityVerified\n';

                                          setState(() {});
                                        },
                                        child: const Text('KYC Status'))
                                    : Container(),
                                Text(kycLogs),
                              ],
                            );
                          })
                    ],
                  ),
                )
              ],
            );
          }
          return _pleaseWait();
        },
      ),
    );
  }

  termsAndConditionsDialog() {
    bool isAccepted = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext customContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return CustomDialog(
              title: 'Terms and Conditions',
              type: DialogType.Info,
              image: Icons.info,
              widgetDescription: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    RichText(
                      text: TextSpan(
                        text:
                            "As part of the verification process, we utilize iDenfy to verify your identity. Please ensure you review iDenfy's ",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        children: [
                          TextSpan(
                            text: 'Security and Compliance',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          TextSpan(
                            text: ', which include their ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          TextSpan(
                            text: 'Terms & Conditions, Privacy Policy,',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          TextSpan(
                            text: ' and other relevant documents.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          )
                          //
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: isAccepted,
                          onChanged: (bool? value) {
                            setState(() {
                              isAccepted = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: 'I have read and agreed to ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                              children: [
                                TextSpan(
                                  text: 'iDenfy Terms and Conditions.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const WebView(
                                            url:
                                                'https://www.idenfy.com/security/',
                                            title:
                                                'iDenfy Terms and Conditions',
                                          ),
                                        ),
                                      );
                                    },
                                ),
                                TextSpan(
                                  text: '.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(customContext);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isAccepted
                      ? () async {
                          Navigator.pop(customContext);
                          await verifyIdentityProcess();
                        }
                      : null,
                  child: Text(
                    'Continue',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: isAccepted
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).disabledColor,
                        ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  showAreYouSureToExitDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext customContext) => CustomDialog(
        type: DialogType.Warning,
        image: Icons.warning,
        title: 'Are you sure',
        description: 'Are you sure you want to exit the verification process',
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () async {
              Navigator.pop(customContext);
            },
          ),
          TextButton(
            child: Text(
              'Yes',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Theme.of(context).colorScheme.warning),
            ),
            onPressed: () async {
              Navigator.pop(customContext);
              setState(() {
                isInIdentityProcess = false;
              });
            },
          ),
        ],
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

  Future<void> initIdenfySdk(String token) async {
    IdenfyIdentificationResult? idenfySDKresult;
    try {
      idenfySDKresult = await IdenfySdkFlutter.start(token);
    } catch (e) {
      logger.e(e);
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) => CustomDialog(
            type: DialogType.Error,
            image: Icons.close,
            title: 'Error',
            description:
                'Something went wrong. Please contact support if this issue persists.',
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Close'))
            ],
          ),
        );
      }
    }
    await Future.delayed(const Duration(seconds: 5));
    if (idenfySDKresult != null &&
        idenfySDKresult.autoIdentificationStatus !=
            AutoIdentificationStatus.UNVERIFIED) {
      await handleIdenfyResponse();
    }
  }

  Future<void> handleIdenfyResponse() async {
    VerificationStatus verificationStatus;
    try {
      verificationStatus = await getVerificationStatus();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      logger.e(e);
      return showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          type: DialogType.Error,
          image: Icons.error,
          title: 'Error',
          description:
              'Failed to get the verification status. \nIf this issue persist, please contact support.',
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
    if (verificationStatus.status == VerificationState.VERIFIED) {
      identityVerified = true;
      setIsIdentityVerified(true);
      Globals().identityVerified.value = true;
      try {
        final data = await getVerificationData();
        final firstName = utf8.decode(latin1.encode(data.orgFirstName!));
        final lastName = utf8.decode(latin1.encode(data.orgLastName!));
        await saveIdentity('$lastName $firstName', data.docIssuingCountry,
            data.docDob, data.docSex, data.idenfyRef);
        Events().emit(IdentityCallbackEvent(type: 'success'));
      } on BadRequest catch (e) {
        setState(() {
          isLoading = false;
        });
        return showDialog(
            context: context,
            builder: (BuildContext context) => CustomDialog(
                  type: DialogType.Warning,
                  image: Icons.warning,
                  title: 'Bad Request',
                  description:
                      '$e \nIf this issue persist, please contact support.',
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Close'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ));
      } on Unauthorized catch (e) {
        setState(() {
          isLoading = false;
        });
        return showDialog(
            context: context,
            builder: (BuildContext context) => CustomDialog(
                  type: DialogType.Warning,
                  image: Icons.warning,
                  title: 'Unauthorized',
                  description:
                      '$e \nIf this issue persist, please contact support.',
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Close'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ));
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        logger.e(e);
        return showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
            type: DialogType.Error,
            image: Icons.error,
            title: 'Error',
            description:
                'Failed to process the verification details. \nIf this issue persist, please contact support.',
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
    } else {
      identityVerified = false;
      setIsIdentityVerified(false);
      Globals().identityVerified.value = false;
      Events().emit(IdentityCallbackEvent(type: 'failed'));
    }
    setState(() {});
  }

  Widget _pleaseWait() {
    return Dialog(
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
    );
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
                    title: Flexible(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(text == '' ? 'Unknown' : text,
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface)),
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
                              const Padding(padding: EdgeInsets.only(left: 5)),
                              Text(
                                'Not verified',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              )
                            ],
                          ),
                        ])),
                  ))
            ],
          ),
        ));
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

            await addPhoneNumberDialog(context);

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
                                          step == 3
                                              ? 'Identity'
                                              : (text.isEmpty
                                                  ? 'Unknown'
                                                  : text),
                                        ),
                                      )
                                    ],
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
                        : Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: ElevatedButton(
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
                                      }
                                      break;
                                    default:
                                      {}
                                      break;
                                  }
                                },
                                child: const Text('Verify'))),
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
          // Only make this section clickable if it is Identity Verification + Current Phase
          if (step != 3) {
            return;
          }

          return showIdentityDetails();
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
                        step == 3
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 15),
                                      child: Icon(
                                        Icons.chevron_right,
                                      ),
                                    ),
                                  ])
                            : const Column()
                      ],
                    ),
                  ],
                ),
              ))
        ]));
  }

  Future verifyIdentityProcess() async {
    setState(() {
      isLoading = true;
    });

    Token token;
    try {
      token = await getToken();

      setState(() {
        isLoading = false;
        isInIdentityProcess = true;
      });
    } on BadRequest catch (e) {
      setState(() {
        isLoading = false;
      });
      return showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
                type: DialogType.Warning,
                image: Icons.warning,
                title: 'Bad Request',
                description:
                    '$e \nIf this issue persist, please contact support.',
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ));
    } on Unauthorized catch (e) {
      setState(() {
        isLoading = false;
      });
      return showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
                type: DialogType.Warning,
                image: Icons.warning,
                title: 'Unauthorized',
                description:
                    '$e \nIf this issue persist, please contact support.',
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ));
    } on TooManyRequests catch (_) {
      setState(() {
        isLoading = false;
      });
      final maxRetries = Globals().maximumKYCRetries;
      return showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
                type: DialogType.Warning,
                image: Icons.warning,
                title: 'Maximum Requests Reached',
                description:
                    'You already had $maxRetries requests in last 24 hours.\nPlease try again in 24 hours.',
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ));
    } on NotEnoughBalance catch (_) {
      setState(() {
        isLoading = false;
      });
      final minimumBalance = Globals().minimumTFChainBalanceForKYC;
      return showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
                type: DialogType.Warning,
                image: Icons.warning,
                title: 'Not enough balance',
                description:
                    'Please fund your account with at least $minimumBalance TFTs.',
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ));
    } on NoTwinId catch (_) {
      setState(() {
        isLoading = false;
      });
      return showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
                type: DialogType.Warning,
                image: Icons.warning,
                title: "Account doesn't exist",
                description:
                    'Your account is not activated.\nPlease go to wallet section and initialize your wallet.',
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ));
    } on AlreadyVerified catch (_) {
      setState(() {
        isLoading = false;
      });
      return await handleIdenfyResponse();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      logger.e(e);
      return showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          type: DialogType.Error,
          image: Icons.error,
          title: 'Failed to setup process',
          description:
              'Something went wrong. \nIf this issue persist, please contact support.',
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
    await initIdenfySdk(token.authToken);
  }

  Future<dynamic> showIdentityDetails() {
    return showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
              child: FutureBuilder(
                future: getIdentity(),
                builder: (BuildContext customContext,
                    AsyncSnapshot<dynamic> snapshot) {
                  if (!snapshot.hasData) {
                    return _pleaseWait();
                  }
                  String name = snapshot.data['identityName'];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Column(
                            children: [
                              Text(
                                'ID CARD',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 5),
                              Row(children: [
                                Text(
                                  'Your own personal KYC ID CARD',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer),
                                ),
                              ]),
                            ],
                          )),
                      Container(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Full name',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Birthday',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  snapshot.data['identityDOB'] != 'None'
                                      ? snapshot.data['identityDOB']
                                      : 'Unknown',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Country',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  snapshot.data['identityCountry'] != 'None'
                                      ? snapshot.data['identityCountry']
                                      : 'Unknown',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Gender',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  snapshot.data['identityGender'] != 'None'
                                      ? snapshot.data['identityGender']
                                      : 'Unknown',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(customContext);
                              },
                              child: const Text('OK')),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      )
                    ],
                  );
                },
              ),
            ));
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
                          'Changing your email will require you to go through the email verification process again.',
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
      await addPhoneNumberDialog(context);

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

      return;
    }

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
