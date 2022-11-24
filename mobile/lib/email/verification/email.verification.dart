import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/core/storage/kyc/kyc.storage.dart';
import 'package:threebotlogin/email/helpers/email.helpers.dart';
import 'package:threebotlogin/email/widgets/email.widgets.dart';

Future emailVerification() async {
  Map<String, String?> email = await getEmail();
  if (email['email'] == null) return;

  String? sei = await getSignedEmailIdentifier();
  if (sei == null) return;

  String? verifiedEmail = await verifySignedEmailIdentifier(sei);
  if (verifiedEmail == null) return;

  await setEmail(verifiedEmail, sei);
  showSuccessEmailVerifiedDialog();

  Globals().emailVerified.value = true;
}
