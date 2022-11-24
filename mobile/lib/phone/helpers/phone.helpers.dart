import 'dart:convert';

import 'package:http/http.dart';
import 'package:threebotlogin/api/kyc/services/kyc.service.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';
import 'package:threebotlogin/phone/widgets/phone.widgets.dart';

Future<void> sendSms(String phone) async {
  String username = (await getUsername())!;
  String publicKey = base64Encode(await getPublicKey());

  await sendVerificationSms(username, phone, publicKey);
}


Future<String?> getSignedPhoneIdentifier() async {
  String doubleName = (await getUsername())!;

  Response r = await getSignedPhoneIdentifierFromOpenKYC(doubleName);

  if (r.statusCode != 200) {
    print("getSignedPhoneIdentifierFromOpenKYC failed with statusCode ${r.statusCode}");
    showFailedPhoneVerifiedDialog();
    return null;
  }

  Map<String, String> body = jsonDecode(r.body);
  String? signedPhoneIdentifier = body["signed_phone_identifier"];

  if (signedPhoneIdentifier == null || signedPhoneIdentifier.isEmpty) {
    print("getSignedPhoneIdentifierFromOpenKYC failed because the signedPhoneIdentifier is null");
    showFailedPhoneVerifiedDialog();
    return null;
  }

  return signedPhoneIdentifier;
}

Future<String?> verifySignedPhoneIdentifier(String signedPhoneIdentifier) async {
  Response r = await verifySignedPhoneIdentifierFromOpenKYC(signedPhoneIdentifier);

  if (r.statusCode != 200) {
    print("verifySignedPhoneIdentifierFromOpenKYC failed with statusCode ${r.statusCode}");
    showFailedPhoneVerifiedDialog();
    return null;
  }

  Map<String, dynamic> body = jsonDecode(r.body);
  String? responsePhone = body["phone"];
  String? responseIdentifier = body["identifier"];

  if (responsePhone == null || responsePhone.isEmpty) {
    print("verifySignedPhoneIdentifier failed because responsePhone is null");
    showFailedPhoneVerifiedDialog();
    return null;
  }

  if (responseIdentifier == null || responseIdentifier.isEmpty) {
    print("verifySignedPhoneIdentifier failed because responseIdentifier is null");
    showFailedPhoneVerifiedDialog();
    return null;
  }

  return responsePhone;
}
