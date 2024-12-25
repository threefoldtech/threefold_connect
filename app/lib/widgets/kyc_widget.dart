import 'package:flutter/material.dart';
import 'package:threebotlogin/models/idenfy.dart';
import 'package:threebotlogin/services/idenfy_service.dart';
import 'package:threebotlogin/services/wallet_service.dart';
import 'package:threebotlogin/models/wallet.dart';

class IdentityVerificationService {
  final BuildContext context;
  final Future<void> Function(String authToken) initIdenfySdk;
  final Future<void> Function() handleIdenfyResponse;
  final Logger logger;
  final Globals globals;

  IdentityVerificationService({
    required this.context,
    required this.initIdenfySdk,
    required this.handleIdenfyResponse,
    required this.logger,
    required this.globals,
  });

  Future<void> verifyIdentityProcess({
    required ValueNotifier<bool> isLoadingNotifier,
    required ValueNotifier<bool> isInIdentityProcessNotifier,
  }) async {
    isLoadingNotifier.value = true;

    try {
      Token token = await getToken();
      isLoadingNotifier.value = false;
      isInIdentityProcessNotifier.value = true;
      await initIdenfySdk(token.authToken);
    } on BadRequest catch (e) {
      _handleError(
        title: 'Bad Request',
        description: '$e \nIf this issue persists, please contact support.',
      );
    } on Unauthorized catch (e) {
      _handleError(
        title: 'Unauthorized',
        description: '$e \nIf this issue persists, please contact support.',
      );
    } on TooManyRequests catch (_) {
      _handleError(
        title: 'Maximum Requests Reached',
        description:
            'You already had ${globals.maximumKYCRetries} requests in the last 24 hours.\nPlease try again in 24 hours.',
      );
    } on NotEnoughBalance catch (_) {
      final wallets = (await getPkidWallets())
          .where((w) => w.type == WalletType.NATIVE)
          .toList();
      final minimumBalance = globals.minimumTFChainBalanceForKYC;
      _handleError(
        title: 'Not enough balance',
        description: wallets.isEmpty
            ? 'Please initialize a wallet and fund it with at least $minimumBalance TFTs.'
            : 'Please fund your ${wallets.first.name} TFChain wallet with at least $minimumBalance TFTs.',
      );
    } on NoTwinId catch (_) {
      _handleError(
        title: "Account doesn't exist",
        description:
            'Your account is not activated.\nPlease go to the wallet section and initialize your wallet.',
      );
    } on AlreadyVerified catch (_) {
      isLoadingNotifier.value = false;
      await handleIdenfyResponse();
    } catch (e) {
      logger.e(e);
      _handleError(
        title: 'Failed to setup process',
        description:
            'Something went wrong. \nIf this issue persists, please contact support.',
      );
    }
  }

  void _handleError({required String title, required String description}) {
    isLoadingNotifier.value = false;
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        type: DialogType.Warning,
        image: Icons.warning,
        title: title,
        description: description,
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

// Example usage:
// final service = IdentityVerificationService(
//   context: context,
//   getToken: getToken,
//   initIdenfySdk: initIdenfySdk,
//   getPkidWallets: getPkidWallets,
//   handleIdenfyResponse: handleIdenfyResponse,
//   logger: logger,
//   globals: globals,
// );
// service.verifyIdentityProcess(
//   isLoadingNotifier: ValueNotifier(false),
//   isInIdentityProcessNotifier: ValueNotifier(false),
// );
