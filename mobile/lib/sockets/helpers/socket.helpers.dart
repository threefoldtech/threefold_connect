import 'package:threebotlogin/core/storage/globals.storage.dart';

bool checkIfLoginAttemptIsValid(data) {
  int currentTimestamp = new DateTime.now().millisecondsSinceEpoch;

  if (data['created'] != null && ((currentTimestamp - data['created']) / 1000) > Globals().loginTimeout) {
    print('Receiving an expired login attempt: created on ${data['createdOn']}');
    return false;
  }

  return true;
}
