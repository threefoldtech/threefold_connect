import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:threebotlogin/apps/wallet/wallet_config.dart';
import 'package:threebotlogin/models/contact.dart';
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

  Map<int, dynamic> dataMap = result.asMap();
  final pkidWallets =
      dataMap.values.map((e) => PkidContact.fromJson(e)).toList();
  return pkidWallets;
}