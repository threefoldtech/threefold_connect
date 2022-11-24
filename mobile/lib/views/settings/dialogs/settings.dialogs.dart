import 'package:flutter/material.dart';
import 'package:threebotlogin/core/components/dialogs/custom.dialog.core.dart';
import 'package:threebotlogin/core/config/classes/config.classes.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/core/utils/core.utils.dart';
import 'package:threebotlogin/views/settings/helpers/settings.helpers.dart';

void showSeedPhraseDialog(String seedPhrase) async {
  return showDialog(
    context: Globals().globalBuildContext,
    builder: (BuildContext context) => CustomDialog(
      hiddenAction: () => setToClipboard(seedPhrase),
      image: Icons.create,
      title: "Please write this down on a piece of paper",
      description: seedPhrase,
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        TextButton(
          child: new Text("Close"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

void showChangedBiometricsDialog() async {
  return showDialog(
    context: Globals().globalBuildContext,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.fingerprint,
      title: "Biometrics",
      description: "Your biometrics have successfully been updated!",
      actions: <Widget>[
        TextButton(child: new Text("Ok"), onPressed: () => Navigator.pop(context)),
      ],
    ),
  );
}

void showPinChangedDialog() async {
  return showDialog(
    context: Globals().globalBuildContext,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.lock,
      title: "PIN changed",
      description: "Your PIN is successfully changed.",
      actions: <Widget>[
        TextButton(child: new Text("Ok"), onPressed: () => Navigator.pop(context)),
      ],
    ),
  );
}

void showVersionDialog() async {
  AppConfig appConfig = AppConfig();

  return showDialog(
    context: Globals().globalBuildContext,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.perm_device_information,
      title: "Build information",
      description: "Type: ${appConfig.environment}\nGit hash: ${appConfig.gitHash}\nTime: ${appConfig.time}",
      actions: <Widget>[
        TextButton(
          child: new Text("Ok"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

void showRemoveAccountFailedDialog() async {
  return showDialog(
    context: Globals().globalBuildContext,
    builder: (BuildContext context) => CustomDialog(
      title: 'Error',
      description: 'Something went wrong when trying to remove your account.',
      actions: <Widget>[
        TextButton(
          child: Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    ),
  );
}

void showSureToRemoveDialog() async {
  return showDialog(
    context: Globals().globalBuildContext,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.error,
      title: "Are you sure?",
      description:
          "If you confirm, your account will be removed from this device. You can always recover your account with your username and phrase.",
      actions: <Widget>[
        TextButton(
          child: new Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: new Text("Yes"),
          onPressed: removeAccountFromDevice,
        ),
      ],
    ),
  );
}
