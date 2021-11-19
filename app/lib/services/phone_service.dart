import 'package:http/http.dart' as http;
import 'package:http/http.dart';

Future<Response> getCountry() async {
  // https://api.ipgeolocationapi.com/geolocate
  return await http.get('https://ipinfo.io/country');
}