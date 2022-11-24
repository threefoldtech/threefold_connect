import 'package:flutter/material.dart';
import 'package:threebotlogin/core/auth/pin/helpers/pin.helpers.dart';
import 'package:threebotlogin/core/auth/pin/views/change.pin.view.dart';
import 'package:threebotlogin/core/config/classes/config.classes.dart';
import 'package:threebotlogin/core/config/enums/config.enums.dart';
import 'package:threebotlogin/core/events/classes/event.classes.dart';
import 'package:threebotlogin/core/events/services/events.service.dart';
import 'package:threebotlogin/core/storage/auth/auth.storage.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/views/landing/views/landing.view.dart';
import 'package:threebotlogin/views/settings/dialogs/settings.dialogs.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showPhrase(String seed) async {
  bool? isAuthenticated = await authenticateYourself();
  if (isAuthenticated == null || !isAuthenticated) return;

  showSeedPhraseDialog(seed);
}

Future<void> changePin() async {
  String pin = (await getPin())!;

  bool? isAuthenticated = await authenticateYourself();
  if (isAuthenticated == null || !isAuthenticated) return null;

  bool? pinChanged = await Navigator.push(
    Globals().globalBuildContext,
    MaterialPageRoute(
      builder: (context) => ChangePinScreen(
        currentPin: pin,
        hideBackButton: false,
      ),
    ),
  );

  if (pinChanged == null || !pinChanged) return null;

  showPinChangedDialog();
}

Future<void> showVersion() async {
  AppConfig appConfig = AppConfig();
  if (appConfig.environment == Environment.Production) return;

  showVersionDialog();
}

Future<void> launchTermsAndConditions() async {
  Uri url = Uri.parse(Globals().termsAndConditionsUrl);
  await launchUrl(url);
}

Future<void> removeAccountFromDevice() async {
  Events().emit(CloseSocketEvent());
  Events().emit(CloseVpnEvent());
  Events().emit(DisconnectPkidClient());

  bool isCleared = await clearData();

  if (!isCleared) return showRemoveAccountFailedDialog();

  await Navigator.pushReplacement(
      Globals().globalBuildContext, MaterialPageRoute(builder: (context) => LandingScreen()));
}
