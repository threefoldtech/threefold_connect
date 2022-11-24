import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

final LocalAuthentication auth = LocalAuthentication();

Future<int> getLockedUntil() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  int? lockedUntil = prefs.getInt('lockedUntil');

  return lockedUntil == null ? 0 : lockedUntil;
}

Future<void> setLockedUntil(int lockedUntil) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('lockedUntil', lockedUntil);
}

Future<int> getFailedAuthAttempts() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  int? failedAttempts = prefs.getInt('failedAuthAttempts');

  return failedAttempts == null ? 0 : failedAttempts;
}

Future<void> setFailedAuthAttempts(int? attempts) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  if (attempts != null) {
    prefs.setInt('failedAuthAttempts', attempts);
    return;
  }

  int currentFailedAttempts = await getFailedAuthAttempts();
  currentFailedAttempts++;
  prefs.setInt('failedAuthAttempts', currentFailedAttempts);
}

Future<void> savePin(String pin) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('pin');
  prefs.setString('pin', pin);
}

Future<String?> getPin() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('pin');
}
