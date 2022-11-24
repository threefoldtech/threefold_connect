import 'package:threebotlogin/login/classes/login.classes.dart';
import 'package:threebotlogin/sign/classes/sign.classes.dart';

class NewLoginEvent {
  Login? loginData;

  NewLoginEvent({this.loginData});
}

class NewSignEvent {
  Sign? signData;

  NewSignEvent({this.signData});
}

class PopAllLoginEvent {
  String emitCode;

  PopAllLoginEvent(this.emitCode);
}

class PopAllSignEvent {
  String emitCode;

  PopAllSignEvent(this.emitCode);
}


class CloseAllLoginEvent {
  CloseAllLoginEvent();
}

class CloseAuthEvent {
  CloseAuthEvent();
}

class CloseSocketEvent {
  CloseSocketEvent();
}

class CloseVpnEvent {
  CloseVpnEvent();
}

class GoHomeEvent {
  GoHomeEvent();
}

class GoNewsEvent {
  GoNewsEvent();
}

class GoPlanetaryEvent {
  GoPlanetaryEvent();
}

class GoSettingsEvent {
  GoSettingsEvent();
}

class GoSupportEvent {
  GoSupportEvent();
}

class GoWalletEvent {
  GoWalletEvent();
}

class PhoneVerifiedEvent {
  PhoneVerifiedEvent();
}

class EmailVerifiedEvent {
  EmailVerifiedEvent();
}

class RecoveredEvent {
  RecoveredEvent();
}

class NewsGoBack {
  NewsGoBack();
}

class DisconnectPkidClient {
  DisconnectPkidClient();
}
