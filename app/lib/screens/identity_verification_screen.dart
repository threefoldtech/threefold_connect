import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/screens/authentication_screen.dart';
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
  final emailController = TextEditingController();
  final changeEmailController = TextEditingController();
  Globals globals = Globals();
  String doubleName = '';
  String phrase = '';
  String email = '';
  String phone = '';
  String reference = '';
  bool emailVerified = false;
  bool phoneVerified = false;
  bool isLoading = false;
  bool hidePhoneVerifyButton = false;
  bool emailInputValidated = false;
  int emailCountdown = 60;
  int phoneCountdown = 120;
  Timer? emailTimer;
  Timer? phoneTimer;
  ValueNotifier<int> countdownNotifier = ValueNotifier(-1);
  ValueNotifier<int> phoneCountdownNotifier = ValueNotifier(-1);

  @override
  void initState() {
    super.initState();
    Globals().emailVerified.addListener(setEmailVerified);
    Globals().phoneVerified.addListener(setPhoneVerified);
    checkPhoneStatus();
    getUserValues();
    getEmailCountdown();
    getPhoneCountdown();
  }

  @override
  void dispose() {
    emailTimer?.cancel();
    phoneTimer?.cancel();
    phoneCountdownNotifier.dispose();
    countdownNotifier.dispose();
    super.dispose();
  }

  void getPhoneCountdown() {
    print('countdown entered');
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int lockedUntil =
        Globals().smsSentOn + (Globals().smsMinutesCoolDown * 60 * 1000);
    int timeLeft = ((lockedUntil - currentTime) / 1000).round();

    if (timeLeft > 0) {
      phoneCountdownNotifier.value = timeLeft;

      phoneTimer?.cancel();
      phoneTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        int remainingTime =
            ((lockedUntil - DateTime.now().millisecondsSinceEpoch) / 1000)
                .round();

        if (remainingTime > 0) {
          phoneCountdownNotifier.value = remainingTime;
        } else {
          phoneCountdownNotifier.value = -1;
          timer.cancel();
          Globals().hidePhoneButton.value = false;
        }
      });
    } else {
      phoneCountdownNotifier.value = -1;
      Globals().hidePhoneButton.value = false;
    }
  }

  void getEmailCountdown({bool startNew = false}) {
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
        if (phoneVerified) {
          phoneCountdownNotifier.value = -1;
          phoneTimer?.cancel();
        }
        Globals().smsSentOn = 0;
      });
    }
  }

  checkPhoneStatus() {
    if (phoneCountdownNotifier.value <= 0) {
      Globals().hidePhoneButton.value = false;
    } else {
      Globals().hidePhoneButton.value = true;
    }
  }

  void getUserValues() async {
    doubleName = (await getDoubleName())!.replaceAll('.3bot', '') ?? 'Unknown';
    phrase = (await getPhrase())!;
    final emailMap = await getEmail();
    if (emailMap['email'] != null) {
      email = emailMap['email']!;
      changeEmailController.text = email;
      emailVerified = (emailMap['sei'] != null);
    }
    final phoneMap = await getPhone();
    if (phoneMap['phone'] != null) {
      phone = phoneMap['phone']!;
      phoneVerified = (phoneMap['spi'] != null);
    }
    setState(() {});
  }

  Future copySeedPhrase() async {
    Clipboard.setData(ClipboardData(text: phrase));

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
      showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          hiddenAction: copySeedPhrase,
          image: Icons.info,
          title: 'Please write this down on a piece of paper',
          description: phrase,
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
  }

  Future _loadingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () => Future.value(false),
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'One moment please...',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _changeEmailDialog() {
    TextEditingController controller = TextEditingController();
    bool validEmail = false;
    String? errorEmail;
    Text statusMessage = const Text('');

    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(builder: (statefulContext, setCustomState) {
            return AlertDialog(
              title: Text('Change email',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface)),
              contentPadding: const EdgeInsets.all(24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Changing your email will require re-\u200dverification.',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface)),
                  TextField(
                    controller: controller,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: validEmail ? null : errorEmail),
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

                      String emailValue = controller.text.toLowerCase().trim();
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
                        await updateEmailAddressOfUser();

                        sendVerificationEmail();

                        email = emailValue;

                        await setIsEmailVerified(false);
                        await saveEmailToPKid();

                        Navigator.pop(context);
                        Navigator.pop(dialogContext);
                        resendEmailDialog(context);
                        getEmailCountdown(startNew: true);

                        setState(() {});
                      } catch (e) {
                        logger.e(e);
                        Navigator.pop(context);

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

  void verifyEmail() {
    if (emailVerified) {
      return;
    }

    if (countdownNotifier.value == -1) {
      return _changeEmailDialog();
    }

    sendVerificationEmail();
    resendEmailDialog(context);
  }

  Future<void> verifyPhone() async {
    if (phoneVerified) {
      return;
    }
    getPhoneCountdown();

    await PhoneAlertDialogState().sendPhoneVerification();
    setState(() {});
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

  Widget _fillCard(String phase, int step, String text, IconData icon) {
    switch (phase) {
      case 'Unverified':
        return unVerifiedWidget(step, text, icon);
      case 'Verified':
        return verifiedWidget(step, text, icon);
      case 'CurrentPhase':
        return currentPhaseWidget(step, text, icon);
      default:
        return Container();
    }
  }

  Widget unVerifiedWidget(int step, String text, IconData icon) {
    return InkWell(
      child: Opacity(
        opacity: 0.5,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: ListTile(
            leading: Icon(icon),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        text.isEmpty ? 'Unknown' : text,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget currentPhaseWidget(int step, String text, IconData icon) {
    return InkWell(
      onTap: () async {
        if (step == 1 && countdownNotifier.value == -1) {
          return _changeEmailDialog();
        }

        if (step == 2 && phoneCountdownNotifier.value == -1) {
          if (phone.isEmpty) {
            await addPhoneNumberDialog(context, newPhone: true, oldPhone: '');
          } else {
            await addPhoneNumberDialog(context,
                newPhone: false, oldPhone: phone);
          }

          var phoneMap = await getPhone();
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: ListTile(
              leading: Icon(icon),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      constraints: _getConstraints(context, step),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  text.isEmpty ? 'Unknown' : text,
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          ),
                          if (step == 1) _buildCountdown(context, true),
                          if (step == 2) _buildCountdown(context, false),
                        ],
                      ),
                    ),
                  ),
                  _buildVerificationBtn(step),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxConstraints _getConstraints(BuildContext context, int step) {
    final hidePhoneButton = Globals().hidePhoneButton.value;
    final screenWidth = MediaQuery.of(context).size.width;

    if (hidePhoneButton == false || (step != 2 && hidePhoneButton == true)) {
      return BoxConstraints(
        minWidth: screenWidth * 0.5,
        maxWidth: screenWidth * 0.5,
      );
    } else {
      return BoxConstraints(
        minWidth: screenWidth * 0.7,
        maxWidth: screenWidth * 0.7,
      );
    }
  }

  formatCountdownMsg(bool isEmail, int countdownValue) {
    if (isEmail) {
      return 'Verification email sent, retry in $countdownValue second${countdownValue == 1 ? '' : 's'}';
    }

    return 'SMS sent, retry in ${_formatTime(countdownValue)}';
  }

  Widget _buildCountdown(BuildContext context, bool isEmail) {
    return ValueListenableBuilder<int>(
      valueListenable: isEmail ? countdownNotifier : phoneCountdownNotifier,
      builder: (context, countdownValue, child) {
        if (countdownValue > 0) {
          return Row(
            children: [
              Expanded(
                child: Text(
                  formatCountdownMsg(isEmail, countdownValue),
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.warning,
                      ),
                ),
              ),
            ],
          );
        }
        return Container();
      },
    );
  }

  Widget _buildVerificationBtn(int step) {
    return ValueListenableBuilder<int>(
      valueListenable: step == 1 ? countdownNotifier : phoneCountdownNotifier,
      builder: (context, countdownValue, child) {
        return Padding(
          padding: const EdgeInsets.only(left: 20),
          child: ElevatedButton(
            onPressed: countdownValue > 0
                ? null
                : () async {
                    if (step == 1) {
                      getEmailCountdown(startNew: true);
                      verifyEmail();
                    } else {
                      getPhoneCountdown();
                      await verifyPhone();
                    }
                  },
            child: Text(step == 1 ? 'Resend' : 'Verify'),
          ),
        );
      },
    );
  }

  String _formatTime(int remainingTime) {
    if (remainingTime >= 60) {
      int minutes = remainingTime ~/ 60;
      int seconds = remainingTime % 60;
      return '${minutes}m ${seconds}s';
    } else {
      return '${remainingTime}s';
    }
  }

  String calculateMinutes() {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int lockedUntil =
        Globals().smsSentOn + (Globals().smsMinutesCoolDown * 60 * 1000);
    int remainingTime = ((lockedUntil - currentTime) / 1000).round();

    if (remainingTime > 0) {
      return (remainingTime / 60).ceil().toString();
    }
    return '0';
  }

  Widget verifiedWidget(int step, String text, IconData icon) {
    return InkWell(
      onTap: () async {
        if (step == 1) {
          _changeEmailDialog();
        } else {
          await addPhoneNumberDialog(context, newPhone: false, oldPhone: phone);
          var phoneMap = await getPhone();
          String? phoneNumber = phoneMap['phone'];
          setState(() {
            phone = phoneNumber!;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 10.0,
        ),
        child: ListTile(
          leading: Icon(icon),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width * 0.65,
                      maxWidth: MediaQuery.of(context).size.width * 0.65,
                    ),
                    child: Text(
                      text.isEmpty ? 'Unknown' : text,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Verified',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const Icon(Icons.edit),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutDrawer(
      titleText: 'Identity',
      content: Padding(
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
                  final emailState =
                      getCorrectState(1, emailVerified, phoneVerified);
                  final phoneState =
                      getCorrectState(2, emailVerified, phoneVerified);
                  return Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(doubleName),
                      ),
                      customDivider(context: context),
                      Padding(
                        padding: const EdgeInsets.only(right: 2.0),
                        child: ListTile(
                          trailing: const Icon(Icons.visibility),
                          leading: const Icon(Icons.vpn_key),
                          title: const Text('Show phrase'),
                          onTap: _showPhrase,
                        ),
                      ),
                      customDivider(context: context),
                      _fillCard(emailState, 1, email, Icons.email),
                      customDivider(context: context),
                      _fillCard(phoneState, 2, phone, Icons.phone),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
