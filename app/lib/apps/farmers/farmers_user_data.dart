import 'package:shared_preferences/shared_preferences.dart';

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

Future<List<String>?> getImportedWallets() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList("importedWallets");
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
  List<String>? wallets = prefs.getStringList("appWallets");
  return wallets;
}

Future<void> clearAllData() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('importedWallets');
  prefs.remove('appWallets');
}
