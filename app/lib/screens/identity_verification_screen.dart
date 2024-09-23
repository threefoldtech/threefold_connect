import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:http/http.dart';
import 'package:shuftipro_onsite_sdk/shuftipro_onsite_sdk.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/identity_callback_event.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/kyc_helpers.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/services/gridproxy_service.dart';
import 'package:threebotlogin/services/identity_service.dart';
import 'package:threebotlogin/services/open_kyc_service.dart';
import 'package:threebotlogin/services/pkid_service.dart';
import 'package:threebotlogin/services/socket_service.dart';
import 'package:threebotlogin/services/tools_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:country_picker/country_picker.dart';
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

  Map<String, Object> configObj = {
    'open_webview': false,
    'asyncRequest': false,
    'captureEnabled': false,
    'dark_mode': false,
  };

  Map<String, Object> authObject = {
    'auth_type': 'access_token',
    'access_token': '',
  };

  // Default values for accessing the Shufti API
  Map<String, Object> createdPayload = {
    'country': '',
    'language': 'EN',
    'email': '',
    'callback_url': 'http://www.example.com',
    'redirect_url': 'https://www.dummyurl.com/',
    'show_consent': 1,
    'show_results': 1,
    'show_privacy_policy': 1,
  };

  // Template for Shufti API verification object
  Map<String, Object?> verificationObj = {
    'face': {},
    'background_checks': {},
    'phone': {},
    'document': {
      'supported_types': [
        'passport',
        'id_card',
        'driving_license',
      ],
      'name': {
        'first_name': '',
        'last_name': '',
        'middle_name': '',
      },
      'dob': '',
      'document_number': '',
      'expiry_date': '',
      'issue_date': '',
      'fetch_enhanced_data': '',
      'gender': '',
      'backside_proof_required': '1',
    },
    'document_two': {
      'supported_types': ['passport', 'id_card', 'driving_license'],
      'name': {'first_name': '', 'last_name': '', 'middle_name': ''},
      'dob': '',
      'document_number': '',
      'expiry_date': '',
      'issue_date': '',
      'fetch_enhanced_data': '',
      'gender': '',
      'backside_proof_required': '0',
    },
    'address': {
      'full_address': '',
      'name': {
        'first_name': '',
        'last_name': '',
        'middle_name': '',
        'fuzzy_match': '',
      },
      'supported_types': ['id_card', 'utility_bill', 'bank_statement'],
    },
    'consent': {
      'supported_types': ['printed', 'handwritten'],
      'text': 'My name is John Doe and I authorize this transaction of \$100/-',
    },
  };
  double spending = 0.0;

  setEmailVerified() {
    if (mounted) {
      setState(() {
        emailVerified = Globals().emailVerified.value;
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
    getIdentity().then((identityMap) {
      setState(() {
        if (identityMap['signedIdentityNameIdentifier'] != null) {
          identityVerified =
              (identityMap['signedIdentityNameIdentifier'] != null);
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
                  padding: const EdgeInsets.all(15),
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
                                // Step one: verify email
                                _fillCard(
                                    getCorrectState(1, emailVerified,
                                        phoneVerified, identityVerified),
                                    1,
                                    email,
                                    Icons.email),

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

  showAreYouSureToExitDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext customContext) => CustomDialog(
        image: Icons.info,
        title: 'Are you sure',
        description: 'Are you sure you want to exit the verification process',
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () async {
              Navigator.pop(customContext);
              showCountryPopup();
            },
          ),
          TextButton(
            child: const Text('Yes'),
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

  void showCountryPopup() {
    return showCountryPicker(
      onClosed: () {
        if (createdPayload['country'] == '') {
          showAreYouSureToExitDialog();
        }
      },
      context: context,
      countryListTheme: CountryListThemeData(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Theme.of(context).colorScheme.onSecondaryContainer),
        searchTextStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Theme.of(context).colorScheme.onSecondaryContainer),
      ),
      showPhoneCode:
          false, // optional. Shows phone code before the country name.
      onSelect: (Country country) async {
        setState(() {
          createdPayload['country'] = country.countryCode;
        });

        print('Select country: ${country.displayName}');
        var brightness =
            SchedulerBinding.instance.platformDispatcher.platformBrightness;
        configObj['dark_mode'] = brightness == Brightness.dark;
        String r = await ShuftiproSdk.sendRequest(
            authObject: authObject,
            createdPayload: createdPayload,
            configObject: configObj);

        print('Receiving response');
        debugPrint(r);

        await handleShuftiCallBack(r);
      },
    );
  }

  Future<void> handleShuftiCallBack(String res) async {
    try {
      if (!isJson(res)) {
        String resData = res.toString();

        if (resData.contains('verification_process_closed')) {
          return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) => CustomDialog(
              image: Icons.close,
              title: 'Request canceled',
              description: 'Verification process has been canceled.',
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('OK'))
              ],
            ),
          );
        }

        if (resData.contains('internet.connection.problem')) {
          return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) => CustomDialog(
              image: Icons.close,
              title: 'Request canceled',
              description:
                  'Please make sure your internet connection is stable.',
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('OK'))
              ],
            ),
          );
        }
      }

      // Close your eyes for one second
      Map<String, dynamic> data = jsonDecode(res);
      switch (data['event']) {
        // AUTHORIZATION IS WRONG
        case 'request.unauthorized':
          {
            Events().emit(IdentityCallbackEvent(type: 'unauthorized'));
            break;
          }
        // NO BALANCE
        case 'request.invalid':
        // DECLINED
        case 'verification.declined':
        // TIME OUT
        case 'request.timeout':
          {
            Events().emit(IdentityCallbackEvent(type: 'failed'));
            break;
          }

        // ACCEPTED
        case 'verification.accepted':
          {
            await verifyIdentity(reference);
            await identityVerification(reference).then((value) {
              if (value == null) {
                return Events().emit(IdentityCallbackEvent(type: 'failed'));
              }
              Events().emit(IdentityCallbackEvent(type: 'success'));
            });
            break;
          }
        default:
          {
            return;
          }
      }
    } catch (e) {
      print(e);
    } finally {
      dispose();
    }
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
                .copyWith(color: Theme.of(context).colorScheme.onBackground),
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
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground),
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
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(width: 0.5, color: Colors.grey)),
            height: 75,
            width: MediaQuery.of(context).size.width * 100,
            child: Row(
              children: [
                const Padding(padding: EdgeInsets.only(left: 10)),
                Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2),
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.background),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('0$step',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12))
                    ],
                  ),
                ),
                const Padding(padding: EdgeInsets.only(left: 20)),
                Icon(
                  icon,
                  size: 20,
                ),
                const Padding(padding: EdgeInsets.only(left: 15)),
                Flexible(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              text == '' ? 'Unknown' : text,
                              overflow: TextOverflow.clip,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
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
                const Padding(padding: EdgeInsets.only(right: 10))
              ],
            ),
          ),
        ));
  }

  Widget currentPhaseWidget(step, text, icon) {
    return GestureDetector(
        onTap: () async {
          if (step == 1) {
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
        child: Container(
          decoration: BoxDecoration(
              border: Border(
                  left: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 5),
                  right: const BorderSide(color: Colors.grey, width: 0.5),
                  bottom: const BorderSide(color: Colors.grey, width: 0.5),
                  top: const BorderSide(color: Colors.grey, width: 0.5))),
          height: 75,
          width: MediaQuery.of(context).size.width * 100,
          child: Row(
            children: [
              const Padding(padding: EdgeInsets.only(left: 10)),
              Container(
                width: 30.0,
                height: 30.0,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primary, width: 2),
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.background),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('0$step',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12))
                  ],
                ),
              ),
              const Padding(padding: EdgeInsets.only(left: 15)),
              Icon(
                icon,
                size: 20,
              ),
              const Padding(padding: EdgeInsets.only(left: 10)),
              Row(
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
                                      MediaQuery.of(context).size.width * 0.4,
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.4)
                              : BoxConstraints(
                                  minWidth:
                                      MediaQuery.of(context).size.width * 0.6,
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.6),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        text == '' ? 'Unknown' : text,
                                        overflow: TextOverflow.clip,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground),
                                      ),
                                    )
                                  ],
                                ),
                                step == 2 &&
                                        Globals().hidePhoneButton.value == true
                                    ? const SizedBox(
                                        height: 5,
                                      )
                                    : Container(),
                                step == 2 &&
                                        Globals().hidePhoneButton.value == true
                                    ? Row(
                                        children: <Widget>[
                                          Text(
                                            'SMS sent, retry in ${calculateMinutes()} minute${calculateMinutes() == '1' ? '' : 's'}',
                                            overflow: TextOverflow.clip,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                    fontWeight: FontWeight.bold,
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
                      : ElevatedButton(
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
                          child: const Text('Verify'))
                ],
              ),
              const Padding(padding: EdgeInsets.only(right: 10)),
            ],
          ),
        ));
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
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(width: 0.5, color: Colors.grey)),
        height: 75,
        width: MediaQuery.of(context).size.width * 100,
        child: Row(
          children: [
            const Padding(padding: EdgeInsets.only(left: 10)),
            Container(
              width: 30.0,
              height: 30.0,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check,
                    size: 15.0,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.only(left: 20)),
            Icon(
              icon,
              size: 20,
            ),
            const Padding(padding: EdgeInsets.only(left: 15)),
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
                                    MediaQuery.of(context).size.width * 0.55,
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.55),
                            child: Text(text == '' ? 'Unknown' : text,
                                overflow: TextOverflow.clip,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground)))
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
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold),
                        )
                      ],
                    )
                  ],
                ),
                step == 1
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.edit, size: 20)],
                      )
                    : const Column(),
                step == 3
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                          )
                        ],
                      )
                    : const Column()
              ],
            ),
            const Padding(padding: EdgeInsets.only(right: 10))
          ],
        ),
      ),
    );
  }

  Future verifyIdentityProcess() async {
    setState(() {
      isLoading = true;
    });

    try {
      Response accessTokenResponse = await getShuftiAccessToken();
      if (accessTokenResponse.statusCode == 403) {
        setState(() {
          isLoading = false;
        });

        return showDialog(
            context: context,
            builder: (BuildContext context) => CustomDialog(
                  image: Icons.warning,
                  title: 'Maximum requests Reached',
                  description:
                      'You already had 5 requests in last 24 hours. \nPlease try again in 24 hours.',
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Ok'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ));
      }

      if (accessTokenResponse.statusCode != 200) {
        setState(() {
          isLoading = false;
        });

        return showDialog(
            context: context,
            builder: (BuildContext context) => CustomDialog(
                  image: Icons.warning,
                  title: "Couldn't setup verification process",
                  description:
                      'Something went wrong. Please contact support if this issue persists.',
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Ok'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ));
      }

      Map<String, dynamic> details = jsonDecode(accessTokenResponse.body);
      authObject['access_token'] = details['access_token'];

      Response identityResponse = await sendVerificationIdentity();
      Map<String, dynamic> identityDetails = jsonDecode(identityResponse.body);
      String verificationCode = identityDetails['verification_code'];

      reference = verificationCode;

      createdPayload['reference'] = reference;
      createdPayload['document'] = verificationObj['document']!;
      createdPayload['face'] = verificationObj['face']!;
      createdPayload['verification_mode'] = 'image_only';

      showCountryPopup();

      setState(() {
        isLoading = false;
        isInIdentityProcess = true;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      print(e);
      return showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          image: Icons.warning,
          title: 'Failed to setup process',
          description:
              'Something went wrong. \n If this issue persist, please contact support',
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
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

                  String name = getFullNameOfObject(
                      jsonDecode(snapshot.data['identityName']));
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
                                'OpenKYC ID CARD',
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
            child: const Text('Ok'),
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
                              color:
                                  Theme.of(context).colorScheme.onBackground),
                    )
                  : Text('Change email',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                              color:
                                  Theme.of(context).colorScheme.onBackground)),
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground))
                      : Text(
                          'Changing your email will require you to go through the email verification process again.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground)),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
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

                        setState(() {});
                      } catch (e) {
                        print(e);
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
    print(emailPKidResult);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change your email'),
          content: Container(
            child: Column(
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

    if (email == '') {
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
      print('Failed to load user spending due to $e');
      spending = 0.0;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
