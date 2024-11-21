import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:threebotlogin/helpers/logger.dart';

// https://api.ipgeolocationapi.com/geolocate
Future<Response> getCountry() async {
  Uri url = Uri.parse('https://ipinfo.io/country');
  logger.i('Sending call: ${url.toString()}');

  return await http.get(url);
}
