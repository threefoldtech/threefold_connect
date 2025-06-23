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

String formatAmountDisplay(String amount) {
  try {
    final Decimal decimalAmount = Decimal.parse(amount);
    if (decimalAmount == Decimal.zero) return '0';

    final Decimal absAmount = decimalAmount.abs();
    final double doubleAmount = absAmount.toDouble();
    String formatted;

    if (absAmount % Decimal.one == Decimal.zero) {
      formatted = NumberFormat('#,##0').format(doubleAmount);
    } else if (doubleAmount >= 1000) {
      formatted = NumberFormat('#,##0.00').format(doubleAmount);
    } else if (doubleAmount >= 1) {
      formatted = NumberFormat('0.###').format(doubleAmount);
    } else if (doubleAmount >= 0.01) {
      formatted = NumberFormat('0.####').format(doubleAmount);
    } else {
      // Very small amounts: Show with approximation for clarity
      String decimals = absAmount.toString().split('.').length > 1
          ? absAmount.toString().split('.')[1]
          : '';
      int firstNonZero = decimals.indexOf(RegExp(r'[1-9]'));
      if (firstNonZero != -1) {
        int precision = (firstNonZero + 2).clamp(0, 8);
        double approxValue = double.parse(absAmount.toStringAsFixed(precision));
        String approximated = NumberFormat('0.${'0' * (precision - 1)}#').format(approxValue);
        formatted = decimals.length > precision ? '~$approximated' : approximated;
      } else {
        formatted = NumberFormat('0.########').format(doubleAmount);
      }
    }

    // Remove trailing zeros after decimal point only (if any), but keep approximation symbol if present
    if (formatted.contains('.')) {
      formatted = formatted.replaceFirst(RegExp(r'(\.\d*?[1-9])0+\u001b'), r'$1\u001b');
      formatted = formatted.replaceFirst(RegExp(r'\.$'), '');
    }
    return formatted;
  } catch (e) {
    return amount;
  }
}