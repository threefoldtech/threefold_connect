import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:idenfy_sdk_flutter/idenfy_sdk_flutter.dart';
import 'package:idenfy_sdk_flutter/models/idenfy_identification_status.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/identity_callback_event.dart';
import 'package:threebotlogin/models/idenfy.dart';
import 'package:threebotlogin/screens/wizard/web_view.dart';
import 'package:threebotlogin/services/idenfy_service.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/services/wallet_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:idenfy_sdk_flutter/models/auto_identification_status.dart';

termsAndConditionsDialog(
    {required BuildContext context, required String walletSeed}) {
  bool isAccepted = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext customContext) {
      return StatefulBuilder(
        builder: (BuildContext childContext, StateSetter setState) {
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
                  SizedBox(
                      height: MediaQuery.of(childContext).size.height * 0.01),
                  RichText(
                    text: TextSpan(
                      text:
                          "As part of the verification process, we utilize iDenfy to verify your identity. Please ensure you review iDenfy's ",
                      style: Theme.of(childContext)
                          .textTheme
                          .bodyMedium!
                          .copyWith(
                            color: Theme.of(childContext).colorScheme.onSurface,
                          ),
                      children: [
                        TextSpan(
                          text: 'Security and Compliance',
                          style: Theme.of(childContext)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(childContext)
                                    .colorScheme
                                    .onSurface,
                              ),
                        ),
                        TextSpan(
                          text: ', which include their ',
                          style: Theme.of(childContext)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                color: Theme.of(childContext)
                                    .colorScheme
                                    .onSurface,
                              ),
                        ),
                        TextSpan(
                          text: 'Terms & Conditions, Privacy Policy,',
                          style: Theme.of(childContext)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(childContext)
                                    .colorScheme
                                    .onSurface,
                              ),
                        ),
                        TextSpan(
                          text: ' and other relevant documents.',
                          style: Theme.of(childContext)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                color: Theme.of(childContext)
                                    .colorScheme
                                    .onSurface,
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
                            style: Theme.of(childContext)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(childContext)
                                      .colorScheme
                                      .onSurface,
                                ),
                            children: [
                              TextSpan(
                                text: 'iDenfy Terms and Conditions.',
                                style: Theme.of(childContext)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Theme.of(childContext)
                                          .colorScheme
                                          .primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      childContext,
                                      MaterialPageRoute(
                                        builder: (context) => const WebView(
                                          url:
                                              'https://www.idenfy.com/security/',
                                          title: 'iDenfy Terms and Conditions',
                                        ),
                                      ),
                                    );
                                  },
                              ),
                              TextSpan(
                                text: '.',
                                style:
                                    Theme.of(childContext).textTheme.bodyMedium,
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
                        await verifyIdentityProcess(
                            context: context, walletSeed: walletSeed);
                      }
                    : null,
                child: Text(
                  'Continue',
                  style: Theme.of(childContext).textTheme.bodyMedium!.copyWith(
                        color: isAccepted
                            ? Theme.of(childContext).colorScheme.primary
                            : Theme.of(childContext).disabledColor,
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

Future<void> verifyIdentityProcess({
  required BuildContext context,
  required String walletSeed,
}) async {
  Token token;
  try {
    token = await getToken(walletSeed);
  } on BadRequest catch (e) {
    showWarningDialog(
      context: context,
      title: 'Bad Request',
      description: '$e \nIf this issue persist, please contact support.',
    );
    return;
  } on Unauthorized catch (e) {
    showWarningDialog(
      context: context,
      title: 'Unauthorized',
      description: '$e \nIf this issue persist, please contact support.',
    );
    return;
  } on TooManyRequests catch (_) {
    final maxRetries = Globals().maximumKYCRetries;
    showWarningDialog(
      context: context,
      title: 'Maximum Requests Reached',
      description:
          'You already had $maxRetries requests in last 24 hours.\nPlease try again in 24 hours.',
    );
    return;
  } on NotEnoughBalance catch (_) {
    final wallets =
        (await getPkidWallets()).where((w) => w.seed == walletSeed).toList();
    final minimumBalance = Globals().minimumTFChainBalanceForKYC;
    showWarningDialog(
        context: context,
        title: 'Not enough balance',
        description: wallets.isEmpty
            ? 'Please initialize a wallet and fund it with at least $minimumBalance TFTs.'
            : 'Please fund your ${wallets.first.name} TFChain wallet with at least $minimumBalance TFTs.');
    return;
  } on NoTwinId catch (_) {
    showWarningDialog(
        context: context,
        title: "Account doesn't exist",
        description:
            'Your account is not activated.\nPlease go to wallet section and initialize your wallet.');
    return;
  } on AlreadyVerified catch (_) {
    return await handleIdenfyResponse(context: context, walletSeed: walletSeed);
  } catch (e) {
    logger.e(e);
    showErrorDialog(
      context: context,
      title: 'Failed to setup process',
      description:
          'Something went wrong. \nIf this issue persist, please contact support.',
    );
    return;
  }
  await initIdenfySdk(token.authToken,
      context: context, walletSeed: walletSeed);
}

Future<void> handleIdenfyResponse({
  required BuildContext context,
  required String walletSeed,
  AutoIdentificationStatus? idenfyState,
}) async {
  VerificationStatus verificationStatus;

  const timeoutDuration = Duration(minutes: 2);
  const retryInterval = Duration(seconds: 5);
  final startTime = DateTime.now();
  try {
    while (DateTime.now().difference(startTime) < timeoutDuration) {
      final idenfyServiceUrl = Globals().idenfyServiceUrl;
      verificationStatus = await getVerificationStatus(
        address: walletSeed,
        idenfyServiceUrl: idenfyServiceUrl,
      );

      if (_areStatesMatching(idenfyState, verificationStatus.status)) {
        if (verificationStatus.status == VerificationState.VERIFIED) {
          Events().emit(IdentityCallbackEvent(type: 'success'));
        } else {
          Events().emit(IdentityCallbackEvent(type: 'failed'));
        }
        return;
      }

      logger.i(
          'States do not match yet. Retrying in ${retryInterval.inSeconds} seconds...');
      await Future.delayed(retryInterval);
    }

    Events().emit(IdentityCallbackEvent(type: 'failed'));
    logger.e('Timeout reached. States still do not match.');
    showErrorDialog(
      context: context,
      title: 'Error',
      description:
          'Something went wrong. Please contact support if this issue persists.',
    );
  } catch (e) {
    Events().emit(IdentityCallbackEvent(type: 'failed'));
    logger.e(e);
    showErrorDialog(
      context: context,
      title: 'Error',
      description:
          'Failed to get the verification status. \nIf this issue persist, please contact support.',
    );
    return;
  }
}

Future<void> initIdenfySdk(String token,
    {required BuildContext context, required String walletSeed}) async {
  IdenfyIdentificationResult? idenfySDKresult;
  try {
    idenfySDKresult = await IdenfySdkFlutter.start(token);
  } catch (e) {
    logger.e(e);
    if (context.mounted) {
      showErrorDialog(
          context: context,
          title: 'Error',
          description:
              'Something went wrong. Please contact support if this issue persists.');
    }
  }
  await Future.delayed(const Duration(seconds: 10));
  if (idenfySDKresult != null) {
    await handleIdenfyResponse(
        context: context,
        walletSeed: walletSeed,
        idenfyState: idenfySDKresult.autoIdentificationStatus);
  }
}

void showWarningDialog({
  required BuildContext context,
  required String title,
  required String description,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) => CustomDialog(
      type: DialogType.Warning,
      image: Icons.warning,
      title: title,
      description: description,
      actions: [
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

void showErrorDialog({
  required BuildContext context,
  required String title,
  required String description,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) => CustomDialog(
      type: DialogType.Error,
      image: Icons.error,
      title: title,
      description: description,
      actions: [
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

Widget pleaseWait(BuildContext context) {
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

Future<dynamic> showIdentityDetails(BuildContext context, String walletSeed) {
  return showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
            child: FutureBuilder(
              future: getVerificationData(walletSeed),
              builder: (BuildContext customContext,
                  AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return pleaseWait(context);
                } else if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data == null) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'No data available for the provided wallet address.',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface),
                        textAlign: TextAlign.center,
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
                }
                final data = snapshot.data;
                final firstName =
                    utf8.decode(latin1.encode(data.orgFirstName!));
                final lastName = utf8.decode(latin1.encode(data.orgLastName!));
                final fullName = '$firstName $lastName';
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                fullName,
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                data.docDob != 'None' ? data.docDob : 'Unknown',
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                data.docIssuingCountry != 'None'
                                    ? data.docIssuingCountry
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                data.docSex != 'None' ? data.docSex : 'Unknown',
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

bool _areStatesMatching(AutoIdentificationStatus? idenfyState,
    VerificationState? verificationState) {
  if (idenfyState == null || verificationState == null) {
    return false;
  }

  final stateMapping = {
    'APPROVED': VerificationState.VERIFIED,
    'FAILED': VerificationState.REJECTED,
    'UNVERIFIED': VerificationState.UNVERIFIED,
  };

  final mappedState = stateMapping[idenfyState.name];
  return mappedState == verificationState;
}
