import 'dart:convert';
import 'dart:io';
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
  if (response.statusCode == HttpStatus.ok ||
      response.statusCode == HttpStatus.created) {
    return Token.fromJson(jsonDecode(response.body)['result']);
  } else if (response.statusCode == HttpStatus.badRequest) {
    throw BadRequest(response.body);
  } else if (response.statusCode == HttpStatus.unauthorized) {
    throw Unauthorized(response.body);
  } else if (response.statusCode == HttpStatus.paymentRequired) {
    throw NotEnoughBalance(response.body);
  } else if (response.statusCode == HttpStatus.conflict) {
    throw AlreadyVerified(response.body);
  } else if (response.statusCode == HttpStatus.tooManyRequests) {
    throw TooManyRequests(response.body);
  }
  throw Exception('Failed to get token due to ${response.body}');
}

Future<VerificationStatus> getVerificationStatus({required String address}) async {
  final idenfyServiceUrl = Globals().idenfyServiceUrl;

  final response = await http.get(
    Uri.https(idenfyServiceUrl, '/api/v1/status', {'client_id': address}),
  );
  if (response.statusCode == HttpStatus.ok) {
    return VerificationStatus.fromJson(jsonDecode(response.body)['result']);
  } else if (response.statusCode == HttpStatus.notFound) {
    return VerificationStatus(
        idenfyRef: '',
        final_: false,
        clientId: address,
        status: VerificationState.UNVERIFIED);
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
  if (response.statusCode == HttpStatus.ok) {
    return VerificationData.fromJson(jsonDecode(response.body)['result']);
  } else if (response.statusCode == HttpStatus.badRequest) {
    throw BadRequest(response.body);
  } else if (response.statusCode == HttpStatus.unauthorized) {
    throw Unauthorized(response.body);
  }
  throw Exception('Failed to fetch verification data due to ${response.body}');
}
