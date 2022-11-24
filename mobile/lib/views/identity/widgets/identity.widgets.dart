import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:threebotlogin/api/kyc/services/kyc.service.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';
import 'package:threebotlogin/core/storage/kyc/kyc.storage.dart';
import 'package:threebotlogin/core/styles/box.styles.dart';
import 'package:threebotlogin/core/styles/text.styles.dart';
import 'package:threebotlogin/views/identity/dialogs/identity.dialogs.dart';
import 'package:threebotlogin/views/identity/helpers/identity.helpers.dart';

Icon verifiedIcon = Icon(Icons.check, color: Colors.white, size: 15.0);
Icon editIcon = Icon(Icons.edit, size: 20, color: Colors.black);

Widget stepIcon(int step) {
  return Container(
    width: 30.0,
    height: 30.0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text('0' + step.toString(), style: kStepTextStyle())],
    ),
    decoration: kCircleBorder,
  );
}

Widget verifiedText() {
  return Text(
    'Verified',
    style: kIdentityVerifiedTextStyle(),
  );
}

Widget notVerifiedText() {
  return Text(
    'Not verified',
    style: kIdentityNotVerifiedTextStyle(),
  );
}

Widget retryInSecondsText() {
  return Text(
    'Retry in ${calculateMinutes()} minutes',
    style: kIdentityInProgressTextStyle(),
  );
}

Widget verifyEmailButton() {
  return ElevatedButton(
      onPressed: () async {
        String username = (await getUsername())!;
        String email = (await getEmail())['email']!;
        String publicKey = base64Encode(await getPublicKey());

        showEmailResentDialog();

        await sendVerificationEmail(username, email, publicKey);
      },
      child: Text('Verify'));
}
