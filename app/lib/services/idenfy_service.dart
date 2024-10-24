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
  final now = DateTime.now().millisecondsSinceEpoch;
  final content = '$idenfyServiceUrl:$now';
  final contentHex = hex.encode(content.codeUnits);
  final signedContent = signer.sign(content);
  final headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'X-Client-ID': address,
    'X-Challenge': contentHex,
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
  if (response.statusCode == 201 || response.statusCode == 200) {
    return Token.fromJson(jsonDecode(response.body)['result']);
  } else if (response.statusCode == 400) {
    if (response.body.contains('bad challenge') ||
        response.body.contains('malformed challenge')) {
      throw const InvalidChallenge('Invalid challenge');
    }
  } else if (response.statusCode == 401) {
    if (response.body.contains('bad signature')) {
      throw const InvalidSignature('Invalid signature');
    }
  } else if (response.statusCode == 409) {
    if (response.body.contains('already verified')) {
      throw const AlreadyVerified('Already verified');
    }
  } else if (response.statusCode == 500) {
    if (response.body.contains('Too Many Requests')) {
      throw const TooManyRequests('Too many retries');
    } else if (response.body.contains('Not enough balance')) {
      throw const NotEnoughBalance('Not enough Balance');
    } else if (response.body.contains('No twin id')) {
      throw const NoTwinId('No twin id');
    }
  }
  throw Exception('Failed to get token due to ${response.body}');
}

Future<VerificationStatus> getVerificationStatus() async {
  final idenfyServiceUrl = Globals().idenfyServiceUrl;
  final headers = await _prepareRequestHeaders();

  final response = await http.get(
    Uri.https(idenfyServiceUrl, '/api/v1/status'),
    headers: headers,
  );
  if (response.statusCode == 200) {
    return VerificationStatus.fromJson(jsonDecode(response.body)['result']);
  } else if (response.statusCode == 404) {
    return VerificationStatus(
        idenfyRef: '',
        final_: false,
        clientId: headers['X-Client-ID']!,
        status: VerificationState.NOTVERIFIED);
  } else {
    throw Exception(
        'Failed to fetch verification status due to ${response.body}');
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
    return VerificationData.fromJson(jsonDecode(response.body)['result']);
  } else if (response.statusCode == 400) {
    if (response.body.contains('bad challenge') ||
        response.body.contains('malformed challenge')) {
      throw const InvalidChallenge('Invalid challenge');
    }
  } else if (response.statusCode == 401) {
    if (response.body.contains('bad signature')) {
      throw const InvalidSignature('Invalid signature');
    }
  }
  throw Exception('Failed to fetch verification data');
}
