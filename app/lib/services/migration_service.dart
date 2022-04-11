import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:threebotlogin/services/pkid_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

import 'crypto_service.dart';

Future<void> fixPkidMigration() async {
  try {
    print('Doing the migration... ');
    await saveEmailToPKidForMigration();
    await savePhoneToPKidForMigration();

    await setPKidMigrationIssueSolved(true);
  }
  catch(e) {
    await setPKidMigrationIssueSolved(false);
  }
}

Future<void> saveEmailInCorrectFormatPKid(Map<dynamic, dynamic> emailData) async {
  try {
    if (emailData['email']['email'] != null) {
      if (emailData['email']['sei'] != null) {
        await saveEmail(emailData['email']['email'], emailData['email']['sei']);
        await saveEmailToPKid();
        return;
      }
      await saveEmail(emailData['email']['email'], null);
      await saveEmailToPKid();
    }
  } catch (e) {
    if (emailData['sei'] != null) {
      await saveEmail(emailData['email'], emailData['sei']);
      return;
    }
    if (emailData['email'] != null) {
      await saveEmail(emailData['email'], null);
    }
  }
}

Future<void> savePhoneInCorrectFormatPKid(Map<dynamic, dynamic> phoneData) async {
  try {
    if (phoneData['phone']['phone'] != null) {
      if (phoneData['phone']['spi'] != null) {
        await savePhone(phoneData['phone']['phone'], phoneData['phone']['spi']);
        await savePhoneToPKid();
        return;
      }

      await savePhone(phoneData['phone']['phone'], null);
      await savePhoneToPKid();
    }
  } catch (e) {
    if (phoneData['spi'] != null) {
      await savePhone(phoneData['phone'], phoneData['spi']);
      return;
    }
    if (phoneData['phone'] != null) {
      await savePhone(phoneData['phone'], null);
    }
  }
}
