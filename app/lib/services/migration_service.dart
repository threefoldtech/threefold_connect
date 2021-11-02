import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:threebotlogin/services/pkid_service.dart';
import 'package:threebotlogin/services/user_service.dart';

import 'crypto_service.dart';

Future<void> migrateToNewSystem() async {
  Map<String, dynamic> keyPair = await generateKeyPairFromSeedPhrase(await getPhrase());
  var client = FlutterPkid(pkidUrl, keyPair);

  await saveEmailToPKid(client, keyPair);
  await savePhoneToPKid(client, keyPair);

}