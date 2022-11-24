import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:threebotlogin/core/crypto/services/crypto.service.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/core/storage/wallet/wallet.storage.dart';
import 'package:threebotlogin/views/wallet/classes/wallet.classes.dart';
import 'package:threebotlogin/views/wallet/views/qr.view.dart';

Future<String> signCallback(List<dynamic> params) async {
  String data = params[0];

  try {
    Uint8List sk = await getPrivateKey();
    String signedData = await signData(data, sk);
    return signedData;
  } catch (e) {
    print(e);
    return '';
  }
}

Future<void> saveWalletCallback(List<dynamic> params) async {
  try {
    List<WalletData> walletData = [];
    for (var data in params[0]) {
      walletData.add(WalletData(data['name'], data['chain'], data['address']));
    }

    await saveWallets(walletData);
  } catch (e) {
    print(e);
  }
}

Future<String?> scanQrCode(List<dynamic> params) async {
  await SystemChannels.textInput.invokeMethod('TextInput.hide');
  // QRCode scanner is black if we don't sleep here.
  bool slept = await Future.delayed(const Duration(milliseconds: 400), () => true);
  late Barcode result;
  if (slept) {
    result = await Navigator.push(Globals().globalBuildContext, MaterialPageRoute(builder: (context) => ScanScreen()));
  }
  return result.code;
}
