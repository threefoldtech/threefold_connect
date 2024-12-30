import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:idenfy_sdk_flutter/idenfy_sdk_flutter.dart';
import 'package:idenfy_sdk_flutter/models/idenfy_identification_status.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/identity_callback_event.dart';
import 'package:threebotlogin/models/idenfy.dart';
import 'package:threebotlogin/services/idenfy_service.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/services/wallet_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:idenfy_sdk_flutter/models/auto_identification_status.dart';

Future<void> verifyIdentityProcess({
  required BuildContext context,
  required String walletName,
  required ValueChanged<bool> setLoading,
  required ValueChanged<bool> setIdentityProcess,
  required String walletAddress,
}) async {
  setLoading(true);

  Token token;
  try {
    token = await getToken(walletAddress);

    setLoading(false);
    setIdentityProcess(true);
  } on BadRequest catch (e) {
    setLoading(false);
    await showWarningDialog(
      context: context,
      title: 'Bad Request',
      description: '$e \nIf this issue persist, please contact support.',
    );
    return;
  } on Unauthorized catch (e) {
    setLoading(false);
    await showWarningDialog(
      context: context,
      title: 'Unauthorized',
      description: '$e \nIf this issue persist, please contact support.',
    );
    return;
  } on TooManyRequests catch (_) {
    setLoading(false);
    final maxRetries = Globals().maximumKYCRetries;
    await showWarningDialog(
      context: context,
      title: 'Maximum Requests Reached',
      description:
          'You already had $maxRetries requests in last 24 hours.\nPlease try again in 24 hours.',
    );
    return;
  } on NotEnoughBalance catch (_) {
    final wallets =
        (await getPkidWallets()).where((w) => w.name == walletName).toList();
    setLoading(false);
    final minimumBalance = Globals().minimumTFChainBalanceForKYC;
    await showWarningDialog(
        context: context,
        title: 'Not enough balance',
        description: wallets.isEmpty
            ? 'Please initialize a wallet and fund it with at least $minimumBalance TFTs.'
            : 'Please fund your ${wallets.first.name} TFChain wallet with at least $minimumBalance TFTs.');
    return;
  } on NoTwinId catch (_) {
    setLoading(false);
    await showWarningDialog(
        context: context,
        title: "Account doesn't exist",
        description:
            'Your account is not activated.\nPlease go to wallet section and initialize your wallet.');
    return;
  } on AlreadyVerified catch (_) {
    setLoading(false);
    return await handleIdenfyResponse(
        context: context,
        setLoading: setLoading,
        setIdentityVerified: setIdentityProcess,
        walletName: walletName,
        walletAddress: walletAddress);
  } catch (e) {
    setLoading(false);
    logger.e(e);
    await showErrorDialog(
      context: context,
      title: 'Failed to setup process',
      description:
          'Something went wrong. \nIf this issue persist, please contact support.',
    );
    return;
  }
  await initIdenfySdk(token.authToken,
      context: context,
      setLoading: setLoading,
      setIdentityVerified: setIdentityProcess,
      walletName: walletName,
      walletAddress: walletAddress);
}

Future<void> handleIdenfyResponse({
  required BuildContext context,
  required ValueChanged<bool> setLoading,
  required ValueChanged<bool> setIdentityVerified,
  required String walletName,
  required String walletAddress,
}) async {
  VerificationStatus verificationStatus;
  try {
    final idenfyServiceUrl = Globals().idenfyServiceUrl;
    verificationStatus = await getVerificationStatus(
        address: walletAddress, idenfyServiceUrl: idenfyServiceUrl);
  } catch (e) {
    setLoading(false);
    logger.e(e);
    await showErrorDialog(
      context: context,
      title: 'Error',
      description:
          'Failed to get the verification status. \nIf this issue persist, please contact support.',
    );
    return;
  }

  if (verificationStatus.status == VerificationState.VERIFIED) {
    setIdentityVerified(true);
    Globals().identityVerified.value = true;

    try {
      final data = await getVerificationData(walletAddress);
      final firstName = utf8.decode(latin1.encode(data.orgFirstName!));
      final lastName = utf8.decode(latin1.encode(data.orgLastName!));
      final wallets =
          (await getPkidWallets()).where((w) => w.name == walletName).toList();
      await saveIdentity('$lastName $firstName', data.docIssuingCountry,
          data.docDob, data.docSex, data.idenfyRef, wallets.first.seed);
      Events().emit(IdentityCallbackEvent(type: 'success'));
    } on BadRequest catch (e) {
      setLoading(false);
      await showWarningDialog(
          context: context,
          title: 'Bad Request',
          description: '$e \nIf this issue persist, please contact support.');
    } on Unauthorized catch (e) {
      setLoading(false);
      await showWarningDialog(
          context: context,
          title: 'Unauthorized',
          description: '$e \nIf this issue persist, please contact support.');
    } catch (e) {
      setLoading(false);
      logger.e(e);
      await showErrorDialog(
        context: context,
        title: 'Error',
        description: 'Failed to process verification details',
      );
    }
  } else {
    setIdentityVerified(false);
    Globals().identityVerified.value = false;
    Events().emit(IdentityCallbackEvent(type: 'failed'));
  }
}

Future<void> initIdenfySdk(String token,
    {required BuildContext context,
    required ValueChanged<bool> setLoading,
    required ValueChanged<bool> setIdentityVerified,
    required String walletName,
    required String walletAddress}) async {
  IdenfyIdentificationResult? idenfySDKresult;
  try {
    idenfySDKresult = await IdenfySdkFlutter.start(token);
  } catch (e) {
    logger.e(e);
    if (context.mounted) {
      await showErrorDialog(
          context: context,
          title: 'Error',
          description:
              'Something went wrong. Please contact support if this issue persists.');
    }
  }
  await Future.delayed(const Duration(seconds: 5));
  if (idenfySDKresult != null &&
      idenfySDKresult.autoIdentificationStatus !=
          AutoIdentificationStatus.UNVERIFIED) {
    await handleIdenfyResponse(
        context: context,
        setLoading: setLoading,
        setIdentityVerified: setIdentityVerified,
        walletName: walletName,
        walletAddress: walletAddress);
  }
}

Future<void> showWarningDialog({
  required BuildContext context,
  required String title,
  required String description,
}) async {
  await showDialog(
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

Future<void> showErrorDialog({
  required BuildContext context,
  required String title,
  required String description,
}) async {
  await showDialog(
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

Future<dynamic> showIdentityDetails(BuildContext context) {
  return showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
            child: FutureBuilder(
              future: getIdentity(),
              builder: (BuildContext customContext,
                  AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) {
                  return pleaseWait(context);
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
