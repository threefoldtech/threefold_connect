import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:threebotlogin/core/config/classes/config.classes.dart';
import 'package:threebotlogin/core/crypto/services/crypto.service.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:threebotlogin/core/events/classes/event.classes.dart';
import 'package:threebotlogin/core/events/services/events.service.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/pkid/helpers/pkid.helpers.dart';

class PkidClient {
  late String username;
  late String phrase;

  PkidClient(this.username, this.phrase);

  Future<void> initializePkidClient(bool migrate) async {
    String pKidUrl = AppConfig().pKidUrl();

    KeyPair keyPair = generateKeyPairFromMnemonic(phrase);
    Globals().pkidClient = FlutterPkid(pKidUrl, keyPair);

    if (migrate == true) {
      await _addMigrationIfNeeded();
    }

    if (Globals().canVerifyEmail) await getEmailFromPkidAndStore();
    if (Globals().canVerifyPhone) await getPhoneFromPkidAndStore();

    print('[PKID] Client established for user $username');

    Events().onEvent(DisconnectPkidClient().runtimeType, (DisconnectPkidClient event) async {
      print('[PKID] Client disconnected');
      disconnectClient();
    });
  }

  Future<void> _addMigrationIfNeeded() async {
    bool isMigrated = await getIsMigratedInPkid();
    if (isMigrated) return;

    await saveEmailToPKidForMigration();
    await savePhoneToPKidForMigration();

    await setIsMigratedInPkid();
  }

  FlutterPkid? getClient() {
    return Globals().pkidClient;
  }

  void disconnectClient() {
    Globals().pkidClient = null;
  }
}
