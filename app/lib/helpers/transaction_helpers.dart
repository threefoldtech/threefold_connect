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

/// Adds thousand separators to large numbers for better readability
String _addThousandSeparators(String number) {
  if (!number.contains('.')) {
    // Whole number
    final formatter = NumberFormat('#,###');
    return formatter.format(int.parse(number));
  } else {
    // Decimal number
    List<String> parts = number.split('.');
    final formatter = NumberFormat('#,###');
    String wholePart = formatter.format(int.parse(parts[0]));
    return '$wholePart.${parts[1]}';
  }
}

/// Formats decimal amounts for display with user-friendly precision
/// following cryptocurrency app best practices for everyday users
String formatAmountDisplay(String amount) {
  try {
    final Decimal decimalAmount = Decimal.parse(amount);

    // Handle zero case
    if (decimalAmount == Decimal.zero) {
      return '0';
    }

    final double doubleAmount = decimalAmount.toDouble();
    String formatted;

    // User-friendly formatting based on amount size
    if (doubleAmount >= 1000) {
      // Large amounts: 2 decimal places max with thousand separators (e.g., 1,234.57)
      formatted = decimalAmount.toStringAsFixed(2);
      formatted = _addThousandSeparators(formatted);
    } else if (doubleAmount >= 1) {
      // Medium amounts: 3 decimal places max (e.g., 123.456)
      formatted = decimalAmount.toStringAsFixed(3);
    } else if (doubleAmount >= 0.01) {
      // Small amounts: 4 decimal places max (e.g., 0.1234)
      formatted = decimalAmount.toStringAsFixed(4);
    } 
    else {
      // Small amounts: Show with approximation for clarity
      String str = decimalAmount.toString();
      if (str.contains('.')) {
        List<String> parts = str.split('.');
        String decimals = parts[1];

        // Find first non-zero digit
        int firstNonZero = -1;
        for (int i = 0; i < decimals.length; i++) {
          if (decimals[i] != '0') {
            firstNonZero = i;
            break;
          }
        }

        if (firstNonZero != -1) {
          // Show 2-3 significant digits with approximation
          int precision = firstNonZero + 2;
          if (precision > 8) precision = 8; // Max 8 decimal places

          String approximated = decimalAmount.toStringAsFixed(precision);
          // Only add ~ if we're actually truncating/rounding
          if (decimals.length > precision) {
            formatted = '~$approximated';
          } else {
            formatted = approximated;
          }
        } else {
          formatted = decimalAmount.toString();
        }
      } else {
        formatted = decimalAmount.toString();
      }
    }

    // Remove trailing zeros (but keep approximation symbol if present)
    if (formatted.startsWith('~')) {
      String number = formatted.substring(1);
      number = number.replaceAll(RegExp(r'0+$'), '');
      number = number.replaceAll(RegExp(r'\.$'), '');
      formatted = '~$number';
    } else {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    }

    return formatted;
  } catch (e) {
    // If parsing fails, return the original amount
    return amount;
  }
}
