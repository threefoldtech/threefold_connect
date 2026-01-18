import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:threebotlogin/helpers/logger.dart';

class InputValidator {
  static const int maxUrlLength = 2048;
  static const int maxContentLength = 100000;
  static const int maxScopeLength = 10000;
  static const Duration httpTimeout = Duration(seconds: 30);

  static Uri? validateUrl(String url, {int? maxLength}) {
    try {
      final trimmedUrl = url.trim();
      if (trimmedUrl.length > (maxLength ?? maxUrlLength)) return null;

      final uri = Uri.parse(trimmedUrl);
      if (!uri.isScheme('http') && !uri.isScheme('https')) return null;
      if (!uri.hasAuthority) return null;

      return uri;
    } catch (e) {
      logger.e('Invalid URL: $e');
      return null;
    }
  }

  static Map<String, dynamic>? decodeJson(String jsonString, {int? maxLength}) {
    try {
      if (jsonString.length > (maxLength ?? maxContentLength)) return null;

      final decoded = json.decode(jsonString);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      logger.e('Invalid JSON: $e');
      return null;
    }
  }

  static bool isValidLength(String? value, int maxLength) {
    return value != null && value.length <= maxLength;
  }

  static Future<String?> fetchValidatedContent(Uri uri,
      {int? maxLength}) async {
    try {
      final response = await http.get(uri).timeout(httpTimeout);

      if (response.statusCode != 200) {
        logger.e('Failed to fetch: HTTP ${response.statusCode}');
        return null;
      }

      if (response.body.isEmpty) {
        logger.e('Empty response body');
        return null;
      }

      final maxLen = maxLength ?? maxContentLength;
      if (response.body.length > maxLen) {
        logger.e(
            'Response too large: ${response.body.length} bytes (max: $maxLen)');
        return null;
      }

      return response.body;
    } catch (e) {
      logger.e('Error fetching content: $e');
      return null;
    }
  }
}
