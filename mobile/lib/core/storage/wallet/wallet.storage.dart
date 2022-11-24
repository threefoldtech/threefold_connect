import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/views/wallet/classes/wallet.classes.dart';

Future<List<String>?> getImportedWallets() async {
  final prefs = await SharedPreferences.getInstance();

  return prefs.getStringList("importedWallets");
}

void saveImportedWallet(List<dynamic> params) async {
  String importedWallet = params[0].toString();
  final prefs = await SharedPreferences.getInstance();
  List<String>? importedWallets = await getImportedWallets();

  if (importedWallets == null) {
    importedWallets = [];
  }

  if (!importedWallets.contains(importedWallet)) {
    importedWallets.add(importedWallet);

    await prefs.remove('importedWallets');
    await prefs.setStringList('importedWallets', importedWallets);
  }
}

Future<void> saveWallets(List<WalletData> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.remove('walletData');
  await prefs.setString('walletData', jsonEncode(data));
}

Future<List<WalletData>> getWallets() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var string = prefs.getString('walletData');

  if (string == null) {
    return [];
  }

  var jsonDecoded = jsonDecode(string);

  List<WalletData> walletData = [];
  for (var data in jsonDecoded) {
    walletData.add(WalletData(data['name'], data['chain'], data['address']));
  }
  return walletData;
}

Future<bool> saveAppWallet(List<dynamic> params) async {
  String? appWalletToAdd = params[0];
  final prefs = await SharedPreferences.getInstance();
  List<String>? appWallets = await getAppWallets();

  if (appWalletToAdd == null) {
    return false;
  }

  if (appWallets == null) {
    appWallets = [];
  }

  if (!appWallets.contains(appWalletToAdd)) {
    appWallets.add(appWalletToAdd);
    await prefs.remove('appWallets');
    await prefs.setStringList('appWallets', appWallets);
    return true;
  }
  return false;
}

Future<List<String>?> getAppWallets() async {
  final prefs = await SharedPreferences.getInstance();
  var wallets = prefs.getStringList("appWallets");
  return wallets;
}
