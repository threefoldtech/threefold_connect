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
