import 'package:flutter/material.dart';
import 'package:threebotlogin/core/auth/biometrics/services/biometric.service.dart';
import 'package:threebotlogin/core/auth/pin/helpers/pin.helpers.dart';
import 'package:threebotlogin/core/router/tabs/views/tabs.views.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/core/storage/kyc/kyc.storage.dart';
import 'package:threebotlogin/core/styles/color.styles.dart';
import 'package:threebotlogin/views/settings/dialogs/settings.dialogs.dart';
import 'package:threebotlogin/views/settings/tiles/settings.tiles.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen();

  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  _SettingsScreenState();

  late String username = '';
  late String seedPhrase = '';
  late String biometricsName = '';
  late bool useBiometrics = false;
  late String version = '';
  late String buildNumber = '';

  late bool showBiometricsTab;

  bool isLoading = true;

  Widget listviewListTiles() {
    return this.isLoading
        ? Container()
        : ListView(
            children: [
              globalSettingsTile,
              usernameTile(username),
              phraseTile(seedPhrase),
              biometricsTile(useBiometrics, biometricsName),
              changePinTile(),
              versionTile(version, buildNumber),
              tosTile(),
              removeAccountTile()
            ],
          );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await setSettingsData();
    });
  }

  Future<void> setSettingsData() async {
    this.username = (await getUsername())!;
    this.seedPhrase = (await getPhrase())!;

    this.useBiometrics = await getFingerPrint();
    this.biometricsName = await getBiometricDeviceName();
    this.showBiometricsTab = await checkBiometricsAvailable() && Globals().canUseBiometrics;

    Map<String, String> appInfo = await getAppInfo();
    this.version = (appInfo['version'])!;
    this.buildNumber = (appInfo['buildNumber'])!;

    this.isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Globals().globalBuildContext = context;
    return LayoutDrawer(
        titleText: 'Settings',
        content: Stack(
          children: [listviewListTiles()],
        ));
  }

  Widget biometricsTile(bool isEnabled, String biometricsDeviceName) {
    if (!showBiometricsTab) return Container();
    return CheckboxListTile(
      secondary: Icon(Icons.fingerprint),
      value: isEnabled,
      activeColor: kThreeFoldGreenColor,
      title: Text(biometricsDeviceName),
      onChanged: (bool? newValue) async {
        bool? isAuthenticated = await authenticateYourself();
        if (isAuthenticated == null || !isAuthenticated) return;

        await setFingerPrint(!isEnabled);
        showChangedBiometricsDialog();

        this.useBiometrics = await getFingerPrint();
        setState(() {});
      },
    );
  }
}
