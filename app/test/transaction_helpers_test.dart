import 'package:flutter_test/flutter_test.dart';
import 'package:threebotlogin/helpers/transaction_helpers.dart';

void main() {
  group('formatAmountDisplay', () {
    test('handles large amounts (user-friendly)', () {
      expect(formatAmountDisplay('1234.567890'), equals('1,234.57')); // 2 decimals + thousand separators
      expect(formatAmountDisplay('5000.00'), equals('5,000')); // Remove trailing zeros + separators
      expect(formatAmountDisplay('10000.123'), equals('10,000.12')); // 2 decimals max + separators
      expect(formatAmountDisplay('1000000.00'), equals('1,000,000')); // Large numbers with separators
    });

    test('handles medium amounts (user-friendly)', () {
      expect(formatAmountDisplay('123.456789'), equals('123.457')); // 3 decimals for medium amounts
      expect(formatAmountDisplay('1.50'), equals('1.5')); // Remove trailing zeros
      expect(formatAmountDisplay('99.999'), equals('99.999')); // Keep significant decimals
    });

    test('handles small amounts (user-friendly)', () {
      expect(formatAmountDisplay('0.12345678'), equals('0.1235')); // 4 decimals for small amounts
      expect(formatAmountDisplay('0.1000'), equals('0.1')); // Remove trailing zeros
    });

    test('handles very small amounts with approximation', () {
      expect(formatAmountDisplay('0.00670241'), equals('~0.0067')); // Approximated with ~ symbol
      expect(formatAmountDisplay('0.001234567'), equals('~0.0012')); // Approximated with ~ symbol
      expect(formatAmountDisplay('0.0005'), equals('0.0005')); // Keep as-is if short enough
      expect(formatAmountDisplay('0.000100'), equals('0.0001')); // Remove trailing zeros
    });

    test('handles tiny amounts with approximation', () {
      expect(formatAmountDisplay('0.000012345678'), equals('~0.000012')); // Approximate tiny amounts
      expect(formatAmountDisplay('0.00000123456789'), equals('~0.0000012')); // Show 2 significant digits
      expect(formatAmountDisplay('0.00000006'), equals('0.00000006')); // Keep if short enough
    });

    test('handles whole numbers', () {
      expect(formatAmountDisplay('5'), equals('5'));
      expect(formatAmountDisplay('100'), equals('100'));
      expect(formatAmountDisplay('1000'), equals('1,000')); // Thousand separator added
    });

    test('handles edge cases', () {
      expect(formatAmountDisplay('0'), equals('0'));
      expect(formatAmountDisplay('0.0'), equals('0'));
      expect(formatAmountDisplay('0.00'), equals('0'));
    });

    test('removes trailing zeros consistently', () {
      expect(formatAmountDisplay('1.50000000'), equals('1.5'));
      expect(formatAmountDisplay('0.12345600'), equals('0.1235'));
      expect(formatAmountDisplay('1000.00'), equals('1,000')); // Thousand separator added
      expect(formatAmountDisplay('0.001200'), equals('0.0012'));
    });
  });
}
