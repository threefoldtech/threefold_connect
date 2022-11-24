import 'dart:convert';

import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/core/storage/kyc/kyc.storage.dart';

Future<void> saveEmailToPKidForMigration() async {
  Map<String, String?> email = await getEmail();
  var emailPKidResult = await Globals().pkidClient?.getPKidDoc('email');

  // Email is not in PKID yet
  if (!emailPKidResult.containsKey('success') && email['email'] != null) {
    if (email['sei'] != null) {
      await Globals().pkidClient?.setPKidDoc('email', json.encode({'email': email['email'], 'sei': email['sei']}));
      return;
    }

    if (email['email'] != null) {
      await Globals().pkidClient?.setPKidDoc('email', json.encode({'email': email['email']}));
      return;
    }
  }

  await Globals().pkidClient?.setPKidDoc('email', json.encode({'email': ''}));
}

Future<void> savePhoneToPKidForMigration() async {
  Map<String, String?> phone = await getPhone();
  var phonePKidResult = await Globals().pkidClient?.getPKidDoc('phone');

  // Phone is not in PKID yet
  if (!phonePKidResult.containsKey('success') && phone['phone'] != null) {
    if (phone['spi'] != null) {
      await Globals().pkidClient?.setPKidDoc('phone', json.encode({'phone': phone['phone'], 'spi': phone['spi']}));
      return;
    }

    if (phone['phone'] != null) {
      await Globals().pkidClient?.setPKidDoc('phone', json.encode({'phone': phone}));
      return;
    }
  }

  await Globals().pkidClient?.setPKidDoc('phone', json.encode({'phone': ''}));
}

Future<void> saveEmailToPKid() async {
  Map<String, String?> email = await getEmail();

  if (email['sei'] != null) {
    await Globals().pkidClient?.setPKidDoc('email', json.encode({'email': email['email'], 'sei': email['sei']}));
    return;
  }

  if (email['email'] != null) {
    await Globals().pkidClient?.setPKidDoc('email', json.encode({'email': email['email']}));
    return;
  }
}

Future<void> savePhoneToPKid() async {
  Map<String, String?> phone = await getPhone();

  if (phone['spi'] != null) {
    await Globals().pkidClient?.setPKidDoc('phone', json.encode({'phone': phone['phone'], 'spi': phone['spi']}));
    return;
  }

  if (phone['phone'] != null) {
    await Globals().pkidClient?.setPKidDoc('phone', json.encode({'phone': phone['phone']}));
    return;
  }
}

Future<dynamic> getEmailFromPKid() async {
  return await Globals().pkidClient?.getPKidDoc('email');
}

Future<dynamic> getPhoneFromPkid() async {
  return await Globals().pkidClient?.getPKidDoc('phone');
}

Future<void> getEmailFromPkidAndStore() async {
  Map<String, dynamic> emailData = await getEmailFromPKid();

  try {
    dynamic email = jsonDecode(emailData['data']);

    if (email['email'] != null && email['sei'] != null) {
      await setEmail(email['email'], email['sei']);
    }

    if (email['email'] != null) {
      await setEmail(email['email'], null);
    }
  } catch (e) {
    print("Error when destructing PKID data for email: $e");
    await setEmail('', null);
    await saveEmailToPKid();
  }
}

Future<void> getPhoneFromPkidAndStore() async {
  Map<String, dynamic> phoneData = await getPhoneFromPkid();

  try {
    dynamic phone = jsonDecode(phoneData['data']);

    if (phone['phone'] != null && phone['spi'] != null) {
      await setPhone(phone['phone'], phone['spi']);
    }

    if (phone['phone'] != null) {
      await setPhone(phone['spi'], null);
    }
  } catch (e) {
    print("Error when destructing PKID data for phone: $e");
    await setPhone('', null);
    await savePhoneToPKid();
  }
}
