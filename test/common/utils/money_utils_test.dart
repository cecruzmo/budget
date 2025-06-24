import 'package:flutter_test/flutter_test.dart';

import 'package:budget/common/utils/money_utils.dart';

void main() {
  group('MoneyUtils', () {
    group('formatMoney', () {
      test('should format whole dollar amounts without decimals', () {
        // Arrange
        const amount = 100.0;

        // Act
        final result = MoneyUtils.formatMoney(amount);

        // Assert
        expect(result, equals('\$100'));
      });

      test('should format amounts with one decimal place', () {
        // Arrange
        const amount = 100.5;

        // Act
        final result = MoneyUtils.formatMoney(amount);

        // Assert
        expect(result, equals('\$100.50'));
      });

      test('should format amounts with two decimal places', () {
        // Arrange
        const amount = 100.25;

        // Act
        final result = MoneyUtils.formatMoney(amount);

        // Assert
        expect(result, equals('\$100.25'));
      });

      test('should format zero amount', () {
        // Arrange
        const amount = 0.0;

        // Act
        final result = MoneyUtils.formatMoney(amount);

        // Assert
        expect(result, equals('\$0'));
      });

      test('should format negative amounts', () {
        // Arrange
        const amount = -50.0;

        // Act
        final result = MoneyUtils.formatMoney(amount);

        // Assert
        expect(result, equals('-\$50'));
      });

      test('should format negative amounts with decimals', () {
        // Arrange
        const amount = -50.75;

        // Act
        final result = MoneyUtils.formatMoney(amount);

        // Assert
        expect(result, equals('-\$50.75'));
      });

      test('should format large amounts', () {
        // Arrange
        const amount = 999999.99;

        // Act
        final result = MoneyUtils.formatMoney(amount);

        // Assert
        expect(result, equals('\$999,999.99'));
      });

      test('should format small decimal amounts', () {
        // Arrange
        const amount = 0.01;

        // Act
        final result = MoneyUtils.formatMoney(amount);

        // Assert
        expect(result, equals('\$0.01'));
      });

      test('should format amounts ending with .00', () {
        // Arrange
        const amount = 123.00;

        // Act
        final result = MoneyUtils.formatMoney(amount);

        // Assert
        expect(result, equals('\$123'));
      });

      test('should format amounts ending with .10', () {
        // Arrange
        const amount = 123.10;

        // Act
        final result = MoneyUtils.formatMoney(amount);

        // Assert
        expect(result, equals('\$123.10'));
      });

      test('should format amounts with more than two decimal places', () {
        // Arrange
        const amount = 123.456;

        // Act
        final result = MoneyUtils.formatMoney(amount);

        // Assert
        expect(result, equals('\$123.46'));
      });

      test('should format amounts with exactly two decimal places', () {
        // Arrange
        const amount = 123.45;

        // Act
        final result = MoneyUtils.formatMoney(amount);

        // Assert
        expect(result, equals('\$123.45'));
      });
    });

    group('Edge cases', () {
      test('should handle very large numbers', () {
        // Arrange
        const amount = 999999999.99;

        // Act
        final result = MoneyUtils.formatMoney(amount);

        // Assert
        expect(result, equals('\$999,999,999.99'));
      });

      test('should handle very small numbers', () {
        // Arrange
        const amount = 0.001;

        // Act
        final result = MoneyUtils.formatMoney(amount);

        // Assert
        expect(result, equals('\$0'));
      });

      test('should handle infinity', () {
        // Arrange
        const amount = double.infinity;

        // Act
        final result = MoneyUtils.formatMoney(amount);

        // Assert
        expect(result, equals('\$∞'));
      });

      test('should handle negative infinity', () {
        // Arrange
        const amount = double.negativeInfinity;

        // Act
        final result = MoneyUtils.formatMoney(amount);

        // Assert
        expect(result, equals('-\$∞'));
      });

      test('should handle NaN', () {
        // Arrange
        const amount = double.nan;

        // Act
        final result = MoneyUtils.formatMoney(amount);

        // Assert
        expect(result, equals('NaN'));
      });
    });
  });
}
