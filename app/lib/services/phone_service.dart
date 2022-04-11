import 'package:http/http.dart' as http;
import 'package:http/http.dart';

// https://api.ipgeolocationapi.com/geolocate
Future<Response> getCountry() async {
  Uri url = Uri.parse('https://ipinfo.io/country');
  print('Sending call: ${url.toString()}');

  return await http.get(url);
}
