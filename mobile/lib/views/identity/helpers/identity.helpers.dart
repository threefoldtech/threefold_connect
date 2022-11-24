import 'package:threebotlogin/core/storage/globals.storage.dart';

bool isValidPhoneNumber(String phone) {
  if (phone == "") return false;

  RegExp regExp = new RegExp(r"^(\+[0-9]{1,3}|0)[0-9]{3}( ){0,1}[0-9]{7,8}\b$", caseSensitive: false, multiLine: false);
  return regExp.hasMatch(phone);
}

bool isValidEmail(String email) {
  if (email == "") return false;

  RegExp regExp = new RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
  return regExp.hasMatch(email);
}

bool isValidPhone(String phone) {
  if (phone == "") return false;

  RegExp regExp = new RegExp(r"^(\+[0-9]{1,3}|0)[0-9]{3}( ){0,1}[0-9]{7,8}\b$", caseSensitive: false, multiLine: false);
  return regExp.hasMatch(phone);
}

String calculateMinutes() {
  int currentTime = new DateTime.now().millisecondsSinceEpoch;
  int lockedUntil = Globals().smsSentOn + (Globals().smsMinutesCoolDown * 60 * 1000);
  String difference = ((lockedUntil - currentTime) / 1000 / 60).round().toString();

  if (int.parse(difference) >= 0) {
    return difference;
  }

  return '0';
}
