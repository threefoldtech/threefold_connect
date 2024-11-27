String formatAmount(String amount) {
  double formattedAmount = double.parse(amount);

  return formattedAmount == formattedAmount.roundToDouble()
      ? amount.split('.').first
      : formattedAmount.toStringAsFixed(2);
}
