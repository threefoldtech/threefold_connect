import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:threebotlogin/services/pkid_service.dart';
import 'package:threebotlogin/services/user_service.dart';

import 'crypto_service.dart';

Future<void> migrateToNewSystem() async {
  await saveEmailToPKidForMigration();
  await savePhoneToPKidForMigration();

}