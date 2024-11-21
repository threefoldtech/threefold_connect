import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:threebotlogin/apps/wallet/wallet_config.dart';
import 'package:threebotlogin/models/contact.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/pkid_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:convert/convert.dart';

Future<FlutterPkid> _getPkidClient() async {
  Uint8List seed = await getDerivedSeed(WalletConfig().appId());
  final mnemonic = bip39.entropyToMnemonic(hex.encode(seed));
  FlutterPkid client = await getPkidClient(seedPhrase: mnemonic);
  return client;
}

Future<List<PkidContact>> getPkidContacts() async {
  FlutterPkid client = await _getPkidClient();
  final pKidResult = await client.getPKidDoc('contacts');
  final result =
      pKidResult.containsKey('data') && pKidResult.containsKey('success')
          ? jsonDecode(pKidResult['data'])
          : {};
  if (result.isEmpty) {
    return [];
  }
  Map<int, dynamic> dataMap = result.asMap();
  final pkidWallets =
      dataMap.values.map((e) => PkidContact.fromJson(e)).toList();
  return pkidWallets;
}

Future<void> addContact(String name, String address, ChainType type) async {
  List<PkidContact> contacts = await getPkidContacts();
  contacts.add(PkidContact(name: name, address: address, type: type));

  await _saveContactsToPkid(contacts);
}

Future<void> editContact(
    String oldName, String newName, String newAddress) async {
  List<PkidContact> contacts = await getPkidContacts();
  for (final w in contacts) {
    if (w.name == oldName) {
      w.name = newName;
      w.address = newAddress;
      break;
    }
  }
  await _saveContactsToPkid(contacts);
}

Future<void> deleteContact(String walletName) async {
  List<PkidContact> contacts = await getPkidContacts();
  contacts = contacts.where((w) => w.name != walletName).toList();
  await _saveContactsToPkid(contacts);
}

Future<void> _saveContactsToPkid(List<PkidContact> contacts) async {
  FlutterPkid client = await _getPkidClient();
  final encodedContacts = json.encode(contacts.map((w) => w.toMap()).toList());
  await client.setPKidDoc('contacts', encodedContacts);
}
