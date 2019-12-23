import 'package:shared_preferences/shared_preferences.dart';

void saveImportedWallet(List<dynamic> params) async {
  String importedWallet = params[0].toString();
  final prefs = await SharedPreferences.getInstance();
  List<String> importedWallets = await getImportedWallets();

  if (importedWallets == null) {
    importedWallets = new List<String>();
  }

  if (!importedWallets.contains(importedWallet)) {
    importedWallets.add(importedWallet);

    await prefs.remove('importedWallets');
    await prefs.setStringList('importedWallets', importedWallets);
  }
}

Future<List<String>> getImportedWallets() async {
  final prefs = await SharedPreferences.getInstance();

  return prefs.getStringList("importedWallets");
}

void saveAppWallet(List<dynamic> params) async {
  String appWallet = params[0].toString();
  final prefs = await SharedPreferences.getInstance();
  List<String> appWallets = await getAppWallets();

  if (appWallet == null) {
    await prefs.remove('appWallets');
    await prefs.setStringList('appWallets', []);
    return;
  }

  if (appWallets == null) {
    appWallets = new List<String>();
  }

  if (!appWallets.contains(appWallet)) {
    appWallets.add(appWallet);

    await prefs.remove('appWallets');
    await prefs.setStringList('appWallets', appWallets);
  }
}

Future<List<String>> getAppWallets() async {
  final prefs = await SharedPreferences.getInstance();
  var wallets = prefs.getStringList("appWallets");
  return wallets;
}

Future<void> clearAllData() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('importedWallets');
  prefs.remove('appWallets');
}
