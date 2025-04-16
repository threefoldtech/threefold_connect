import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/screens/authentication_screen.dart';
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
      IdentityVerificationScreenState();
}

class IdentityVerificationScreenState
    extends State<IdentityVerificationScreen> {
  static final GlobalKey<IdentityVerificationScreenState> globalKey =
      GlobalKey<IdentityVerificationScreenState>();

  final emailController = TextEditingController();
  final changeEmailController = TextEditingController();
  Globals globals = Globals();
  String doubleName = '';
  String phrase = '';
  String email = '';
  String phone = '';
  bool emailVerified = false;
  bool phoneVerified = false;
  bool isLoading = false;
  bool failed = false;
  bool hidePhoneVerifyButton = false;
  bool emailInputValidated = false;
  int emailCountdown = 60;
  int phoneCountdown = 120;
  Timer? emailTimer;
  Timer? phoneTimer;
  bool newPhone = false;
  ValueNotifier<int> emailCountdownNotifier = ValueNotifier(-1);
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
    emailCountdownNotifier.dispose();
    super.dispose();
  }

  void getPhoneCountdown() {
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
      emailCountdownNotifier.value = emailCountdown;

      emailTimer?.cancel();

      emailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        int currentTime = DateTime.now().millisecondsSinceEpoch;
        int lockedUntil = Globals().emailSentOn +
            (Globals().emailMinutesCoolDown * 60 * 1000);
        int remainingTime = ((lockedUntil - currentTime) / 1000).round();

        if (remainingTime > 0) {
          emailCountdownNotifier.value = remainingTime;
        } else {
          emailCountdownNotifier.value = -1;
          timer.cancel();
        }
      });
    } else {
      emailCountdownNotifier.value = -1;
    }
  }

  setEmailVerified() {
    if (mounted) {
      setState(() {
        emailVerified = Globals().emailVerified.value;
        if (emailVerified) {
          emailCountdownNotifier.value = -1;
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

  verifyButton(bool valid, verificationPhoneNumber) async {
    try {
      if (!valid) return;
      loadingDialog();
      await savePhone(verificationPhoneNumber, null);
      FlutterPkid client = await getPkidClient();
      client.setPKidDoc(
          'phone', json.encode({'phone': verificationPhoneNumber}));
      await sendPhoneVerification();
      Navigator.pop(context);
      getPhoneCountdown();
    } catch (e) {
      logger.e(e);
    }
  }

  sendPhoneVerification() async {
    await sendVerificationSms();
    Globals().hidePhoneButton.value = true;
    Globals().smsSentOn = DateTime.now().millisecondsSinceEpoch;
    if (mounted) {
      setState(() {
        phoneSendDialog(context);
        Navigator.pop(context);
      });
    }
  }

  void getUserValues() async {
    setState(() => isLoading = true);
    try {
      doubleName =
          (await getDoubleName())?.replaceAll('.3bot', '') ?? 'Unknown';
      phrase = (await getPhrase()) ?? '';
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
    } catch (e) {
      setState(() {
        failed = true;
      });
      logger.e('Failed to get user values due to $e');
      if (context.mounted) {
        final loadingFarmsFailure = SnackBar(
          content: Text(
            'Failed to get user values',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.errorContainer),
          ),
          duration: const Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(loadingFarmsFailure);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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

  Future loadingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogueContext) {
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
          return KeyboardVisibilityBuilder(
              builder: (context, isKeyboardVisible) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child:
                  StatefulBuilder(builder: (statefulContext, setCustomState) {
                return AlertDialog(
                  title: Text('Change email',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                              color: Theme.of(context).colorScheme.onSurface)),
                  contentPadding: const EdgeInsets.all(24),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          'Changing your email will require re-\u200dverification.',
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
                          loadingDialog();

                          String emailValue =
                              controller.text.toLowerCase().trim();
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
              }),
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

  Future<void> verifyEmail() async {
    if (emailVerified) {
      return;
    }

    await sendVerificationEmail();
    resendEmailDialog(context);
  }

  Future<void> verifyPhone() async {
    if (phoneVerified) {
      return;
    }
    loadingDialog();
    await sendPhoneVerification();
    Navigator.pop(context);
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

  formatCountdownMsg(bool isEmail, int countdownValue) {
    if (isEmail) {
      return 'Verification email sent, retry in $countdownValue second${countdownValue == 1 ? '' : 's'}';
    }

    return 'SMS sent, retry in ${_formatTime(countdownValue)}';
  }

  Widget _buildCountdown(BuildContext context, bool isEmail) {
    return ValueListenableBuilder<int>(
      valueListenable:
          isEmail ? emailCountdownNotifier : phoneCountdownNotifier,
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
      valueListenable:
          step == 1 ? emailCountdownNotifier : phoneCountdownNotifier,
      builder: (context, countdownValue, child) {
        return Padding(
          padding: const EdgeInsets.only(left: 20),
          child: ElevatedButton(
            onPressed: countdownValue > 0
                ? null
                : () async {
                    if (step == 1) {
                      await verifyEmail();
                      getEmailCountdown(startNew: true);
                    } else {
                      await verifyPhone();
                      getPhoneCountdown();
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

  _handleInfoWidget(step) async {
    if (step == 1 && emailCountdownNotifier.value == -1) {
      _changeEmailDialog();
    }

    if (step == 2 && phoneCountdownNotifier.value == -1) {
      await addPhoneNumberDialog(context,
          newPhone: newPhone, oldPhone: phone, onVerify: verifyButton);
      var phoneMap = await getPhone();
      String? phoneNumber = phoneMap['phone'];
      setState(() {
        phone = phoneNumber!;
      });
    }
  }

  Widget infoWidget(int step, String text, IconData icon, bool isVerified) {
    return InkWell(
      onTap: () async {
        newPhone = text == '';
        await _handleInfoWidget(step);
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width * 0.5,
                      ),
                      child: Text(
                        text.isEmpty ? 'Unknown' : text,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 5),
                    isVerified
                        ? Text(
                            'Verified',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          )
                        : _buildCountdown(context, step == 1)
                  ],
                ),
              ),
              isVerified || text == 'Unknown' || text == ''
                  ? const Icon(Icons.edit)
                  : _buildVerificationBtn(step),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (isLoading) {
      content = Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 15),
          Text(
            'Loading identity information...',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold),
          ),
        ],
      ));
    } else if (failed) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: () {
                setState(() {
                  failed = false;
                  isLoading = true;
                });
                getUserValues();
              },
            ),
          ],
        ),
      );
    } else {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                        title: Text(doubleName),
                      ),
                      customDivider(context: context),
                      if (phrase.isNotEmpty) ...[
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
                      ],
                      infoWidget(1, email, Icons.email, emailVerified),
                      customDivider(context: context),
                      infoWidget(2, phone, Icons.phone, phoneVerified),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return LayoutDrawer(
      titleText: 'Identity',
      content: content,
    );
  }
}
