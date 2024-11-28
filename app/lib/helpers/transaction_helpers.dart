// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

String formatAmount(String amount) {
  double parsedAmount = double.parse(amount);

  String formattedAmount = NumberFormat('#,##0.##').format(parsedAmount);

  return parsedAmount == parsedAmount.roundToDouble()
      ? formattedAmount.split('.').first
      : formattedAmount;
}
