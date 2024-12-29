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
import 'package:threebotlogin/services/tfchain_service.dart';
import 'package:threebotlogin/services/wallet_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:idenfy_sdk_flutter/models/auto_identification_status.dart';

Future<void> verifyIdentityProcess({
  required BuildContext context,
  required ValueChanged<bool> setLoading,
  required ValueChanged<bool> setIdentityProcess,
}) async {
  setLoading(true);

  late Token token;
  try {
    token = await getToken();

    setLoading(false);
    setIdentityProcess(true);
  } on BadRequest catch (e) {
    setLoading(false);
    await showWarningDialog(
      context: context,
      title: 'Bad Request',
      description: '$e \nIf this issue persist, please contact support.',
    );
  } on Unauthorized catch (e) {
    setLoading(false);
    await showWarningDialog(
      context: context,
      title: 'Unauthorized',
      description: '$e \nIf this issue persist, please contact support.',
    );
  } on TooManyRequests catch (_) {
    setLoading(false);
    final maxRetries = Globals().maximumKYCRetries;
    await showWarningDialog(
      context: context,
      title: 'Maximum Requests Reached',
      description:
          'You already had $maxRetries requests in last 24 hours.\nPlease try again in 24 hours.',
    );
  } on NotEnoughBalance catch (_) {
    final wallets = (await getPkidWallets())
        .where((w) => w.type == WalletType.NATIVE)
        .toList();
    setLoading(false);
    final minimumBalance = Globals().minimumTFChainBalanceForKYC;
    await showWarningDialog(
        context: context,
        title: 'Not enough balance',
        description: wallets.isEmpty
            ? 'Please initialize a wallet and fund it with at least $minimumBalance TFTs.'
            : 'Please fund your ${wallets.first.name} TFChain wallet with at least $minimumBalance TFTs.');
  } on NoTwinId catch (_) {
    setLoading(false);
    await showWarningDialog(
        context: context,
        title: "Account doesn't exist",
        description:
            'Your account is not activated.\nPlease go to wallet section and initialize your wallet.');
  } on AlreadyVerified catch (_) {
    setLoading(false);
    await handleIdenfyResponse(
        context: context,
        setLoading: setLoading,
        setIdentityVerified: setIdentityProcess);
  } catch (e) {
    setLoading(false);
    logger.e(e);
    await showErrorDialog(
      context: context,
      title: 'Failed to setup process',
      description:
          'Something went wrong. \nIf this issue persist, please contact support.',
    );
  }

  await initIdenfySdk(
      context: context,
      token.authToken,
      setLoading: setLoading,
      setIdentityVerified: setIdentityProcess);
}

Future<void> handleIdenfyResponse({
  required BuildContext context,
  required ValueChanged<bool> setLoading,
  required ValueChanged<bool> setIdentityVerified,
}) async {
  VerificationStatus verificationStatus;
  try {
    final address = await getMyAddress();
    verificationStatus = await getVerificationStatus(address: address);
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
      final data = await getVerificationData();
      final firstName = utf8.decode(latin1.encode(data.orgFirstName!));
      final lastName = utf8.decode(latin1.encode(data.orgLastName!));
      final wallets = (await getPkidWallets())
          .where((w) => w.type == WalletType.NATIVE)
          .toList();
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
    required ValueChanged<bool> setIdentityVerified}) async {
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
        setIdentityVerified: setIdentityVerified);
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
