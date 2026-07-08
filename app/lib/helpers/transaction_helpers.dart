import 'package:decimal/decimal.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:threebotlogin/helpers/logger.dart';

String formatAmount(String amount) {
  double parsedAmount = roundAmount(amount).toDouble();
  String formattedAmount = NumberFormat('#,##0.##').format(parsedAmount);
  return formattedAmount;
}

Decimal roundAmount(String amount) {
  Decimal parsedAmount = Decimal.parse(amount).shift(2).floor().shift(-2);
  return parsedAmount;
}

/// Formats an ISO date string to a user-friendly format
/// Uses the same format as the overview screen: yyyy-MM-dd HH:mm:ss
String formatDateTime(String isoString) {
  try {
    DateTime dateTime = DateTime.parse(isoString).toLocal();
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} '
        '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}';
  } catch (e) {
    logger.e('Error formatting date: $e');
    return 'Unknown date';
  }
}

/// Helper function to pad single digits with leading zero
String _twoDigits(int n) => n.toString().padLeft(2, '0');
