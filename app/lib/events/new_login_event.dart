import 'package:threebotlogin/models/login.dart';

class NewLoginEvent {
  String loginId;
  Login loginData;

  NewLoginEvent({this.loginData, this.loginId});
}
