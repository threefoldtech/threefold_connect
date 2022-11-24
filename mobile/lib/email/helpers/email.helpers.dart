import 'dart:convert';

import 'package:http/http.dart';
import 'package:threebotlogin/api/kyc/services/kyc.service.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';
import 'package:threebotlogin/email/widgets/email.widgets.dart';

Future<String?> getSignedEmailIdentifier() async {
  String doubleName = (await getUsername())!;

  Response r = await getSignedEmailIdentifierFromOpenKYC(doubleName);

  if (r.statusCode != 200) {
    print("getSignedEmailIdentifierFromOpenKYC failed with statusCode ${r.statusCode}");
    showFailedEmailVerifiedDialog();
    return null;
  }

  Map<String, String> body = jsonDecode(r.body);
  String? signedEmailIdentifier = body["signed_email_identifier"];

  if (signedEmailIdentifier == null || signedEmailIdentifier.isEmpty) {
    print("getSignedEmailIdentifierFromOpenKYC failed because the signedEmailIdentifier is null");
    showFailedEmailVerifiedDialog();
    return null;
  }

  return signedEmailIdentifier;
}

Future<String?> verifySignedEmailIdentifier(String signedEmailIdentifier) async {
  Response r = await verifySignedEmailIdentifierFromOpenKYC(signedEmailIdentifier);

  if (r.statusCode != 200) {
    print("verifySignedEmailIdentifier failed with statusCode ${r.statusCode}");
    showFailedEmailVerifiedDialog();
    return null;
  }

  Map<String, dynamic> body = jsonDecode(r.body);
  String? responseEmail = body["email"];
  String? responseIdentifier = body["identifier"];

  if (responseEmail == null || responseEmail.isEmpty) {
    print("verifySignedEmailIdentifier failed because responseEmail is null");
    showFailedEmailVerifiedDialog();
    return null;
  }

  if (responseIdentifier == null || responseIdentifier.isEmpty) {
    print("verifySignedEmailIdentifier failed because responseIdentifier is null");
    showFailedEmailVerifiedDialog();
    return null;
  }

  return responseEmail;
}
