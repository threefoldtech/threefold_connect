import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/services/tfchain_service.dart';
import 'package:convert/convert.dart';
import 'package:threebotlogin/models/idenfy.dart';

Future<Map<String, String>> _prepareRequestHeaders() async {
  final idenfyServiceUrl = Globals().idenfyServiceUrl;
  final signer = await getMySigner();
  final address = signer.keypair!.address;
  final now = DateTime.now();
  final content = hex.encode('$idenfyServiceUrl:$now'.codeUnits);
  final signedContent = signer.sign(content);
  final headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'X-Client-ID': address,
    'X-Challenge': content,
    'X-Signature': signedContent,
  };
  return headers;
}

Future<Token> getToken() async {
  final idenfyServiceUrl = Globals().idenfyServiceUrl;
  final headers = await _prepareRequestHeaders();

  final response = await http.post(
    Uri.https(idenfyServiceUrl, '/api/v1/token'),
    headers: headers,
  );
  if (response.statusCode == 200) {
    return Token.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to get token');
  }
}

Future<VerificationStatus> getVerificationStatus() async {
  final idenfyServiceUrl = Globals().idenfyServiceUrl;
  final headers = await _prepareRequestHeaders();

  final response = await http.get(
    Uri.https(idenfyServiceUrl, '/api/v1/status'),
    headers: headers,
  );
  if (response.statusCode == 200) {
    return VerificationStatus.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to fetch verification status');
  }
}

Future<VerificationData> getVerificationData() async {
  final idenfyServiceUrl = Globals().idenfyServiceUrl;
  final headers = await _prepareRequestHeaders();

  final response = await http.get(
    Uri.https(idenfyServiceUrl, '/api/v1/data'),
    headers: headers,
  );
  if (response.statusCode == 200) {
    return VerificationData.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to fetch verification data');
  }
}
