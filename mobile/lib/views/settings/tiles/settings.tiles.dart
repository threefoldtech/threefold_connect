import 'package:flutter/material.dart';
import 'package:threebotlogin/views/settings/dialogs/settings.dialogs.dart';
import 'package:threebotlogin/views/settings/helpers/settings.helpers.dart';

const globalSettingsTile = ListTile(title: Text("Global settings"));

Widget usernameTile(String username) {
  return ListTile(leading: Icon(Icons.person), title: Text(username));
}

Widget phraseTile(String seedPhrase) {
  return ListTile(
      trailing: Padding(
        padding: new EdgeInsets.only(right: 7.5),
        child: Icon(Icons.visibility),
      ),
      leading: Icon(Icons.vpn_key),
      title: Text("Show phrase"),
      onTap: () => showPhrase(seedPhrase));
}

Widget changePinTile() {
  return ListTile(leading: Icon(Icons.lock), title: Text("Change PIN"), onTap: changePin);
}

Widget versionTile(String version, String buildNumber) {
  return ListTile(
      leading: Icon(Icons.perm_device_information),
      title: Text("Version: " + version + " - " + buildNumber),
      onTap: showVersion);
}

Widget tosTile() {
  return ListTile(
      leading: Icon(Icons.info_outline), title: Text("Terms and conditions"), onTap: launchTermsAndConditions);
}

Widget removeAccountTile() {
  return ExpansionTile(
    title: Text(
      "Advanced settings",
      style: TextStyle(color: Colors.black),
    ),
    children: <Widget>[
      ListTile(
        leading: Icon(Icons.person),
        title: Text(
          "Remove Account From Device",
          style: TextStyle(color: Colors.red),
        ),
        trailing: Icon(
          Icons.remove_circle,
          color: Colors.red,
        ),
        onTap: showSureToRemoveDialog,
      ),
    ],
  );
}
