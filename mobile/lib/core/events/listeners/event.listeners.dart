import 'package:flutter/material.dart';
import 'package:threebotlogin/core/events/classes/event.classes.dart';
import 'package:threebotlogin/core/events/services/events.service.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/core/yggdrasil/classes/yggdrasil.classes.dart';
import 'package:threebotlogin/login/helpers/login.helpers.dart';
import 'package:threebotlogin/phone/verification/phone.verification.dart';
import 'package:threebotlogin/sign/helpers/sign.helpers.dart';
import 'package:threebotlogin/views/home/views/home.view.dart';
import 'package:threebotlogin/views/recover/dialogs/recover.dialogs.dart';

import '../../../email/verification/email.verification.dart';

Future<void> initializeEventListeners() async {
  Events().onEvent(RecoveredEvent().runtimeType, (RecoveredEvent event) async {
    await Future.delayed(const Duration(milliseconds: 100));
    showSuccessfullyRecovered();
  });

  Events().onEvent(GoHomeEvent().runtimeType, (GoHomeEvent event) async {
    await Navigator.push(Globals().globalBuildContext, MaterialPageRoute(builder: (context) => HomeScreen()));
  });

  Events().onEvent(CloseVpnEvent().runtimeType, (CloseVpnEvent event) async {
    VpnState vpn = Globals().vpnState;
    if (vpn.vpnConnected) Globals().vpnState.plugin.stopVpn();
  });

  Events().onEvent(EmailVerifiedEvent().runtimeType, (EmailVerifiedEvent event) {
    emailVerification();
  });

  Events().onEvent(PhoneVerifiedEvent().runtimeType, (PhoneVerifiedEvent event) {
    phoneVerification();
  });

  Events().onEvent(NewLoginEvent().runtimeType, (NewLoginEvent event) async {
    if (event.loginData == null) return;
    await openLogin(event.loginData!);
  });

  Events().onEvent(NewSignEvent().runtimeType, (NewSignEvent event) async {
    if (event.signData == null) return;
    await openSign(event.signData!);
  });
}
