import 'package:decimal/decimal.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

String formatAmount(String amount) {
  double parsedAmount = roundAmount(amount).toDouble();
  String formattedAmount = NumberFormat('#,##0.##').format(parsedAmount);
  return formattedAmount;
}

Decimal roundAmount(String amount) {
  Decimal parsedAmount = Decimal.parse(amount).shift(2).floor().shift(-2);
  return parsedAmount;
}

/// Formats decimal amounts for display, preserving significant digits for small amounts
/// while keeping reasonable precision for larger amounts
String formatSmallAmount(String amount) {
  try {
    final Decimal decimalAmount = Decimal.parse(amount);
    final double doubleAmount = decimalAmount.toDouble();

    // For very small amounts (less than 0.01), show up to 8 significant digits
    if (doubleAmount > 0 && doubleAmount < 0.01) {
      // Remove trailing zeros and show significant digits
      String formatted = doubleAmount.toStringAsFixed(8);
      // Remove trailing zeros
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      // Remove trailing decimal point if all decimals were zeros
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
      return formatted;
    }

    // For amounts >= 0.01, use the standard 2 decimal places
    return roundAmount(amount).toString();
  } catch (e) {
    // If parsing fails, return the original amount
    return amount;
  }
}
