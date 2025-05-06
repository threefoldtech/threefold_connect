import 'package:crypto/crypto.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/services/tfchain_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> md5Sign(
    {required String data, required String walletSecretSeed}) async {
  final contentHash = md5.convert(data.codeUnits).toString();
  final signer = await getSignerFromSeed(walletSecretSeed);
  return signer.sign(contentHash);
}

Future<bool> sendSignedData(String destUrl, String signature) async {
  try {
    final response = await http.post(
      Uri.parse(destUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'signature': signature}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send signature to destination');
    }
    return true;
  } catch (e) {
    logger.e('Error sending signature to destination: $e');
    return false;
  }
}
