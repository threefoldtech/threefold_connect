import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:threebotlogin/helpers/logger.dart';

Future<dynamic> getCountry() async {
  Uri url = Uri.parse('https://freegeoip.app/json/');
  logger.i('Sending call: ${url.toString()}');
  final res = await http.get(url);
  final data = jsonDecode(res.body);
  return data['country_code'];
}
