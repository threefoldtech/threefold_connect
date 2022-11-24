import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, String?>> getEmail() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return {'email': prefs.getString('email'), 'sei': prefs.getString('signedEmailIdentifier')};
}

Future<void> setEmail(String email, String? signedEmailIdentifier) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('email', email);

  if (signedEmailIdentifier != null) {
    prefs.setString('signedEmailIdentifier', signedEmailIdentifier);
  }
}

Future<bool> getFingerPrint() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  bool? fingerprint = prefs.getBool('useFingerPrint');
  if (fingerprint == null) {
    prefs.setBool('useFingerPrint', false);
    fingerprint = prefs.getBool('useFingerPrint');
  }

  bool hasFingerprint = fingerprint == true;
  return hasFingerprint;
}

Future<void> setFingerPrint(fingerprint) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('useFingerPrint', fingerprint);
}

Future<Map<String, String?>> getPhone() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return {'phone': prefs.getString('phone'), 'spi': prefs.getString('signedPhoneIdentifier')};
}

Future<void> setPhone(String phone, String? signedPhoneIdentifier) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.setString('phone', phone);
  if (signedPhoneIdentifier != null) {
    prefs.setString('signedPhoneIdentifier', signedPhoneIdentifier);
  }
}