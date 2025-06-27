import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:budget/common/utils/date_utils.dart';

void main() {
  group('DateUtils', () {
    group('parseFirebaseTimestamp', () {
      test('should throw ArgumentError when value is null', () {
        // Arrange
        const value = null;

        // Act & Assert
        expect(
          () => DateUtils.parseFirebaseTimestamp(value),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should convert Firebase Timestamp to DateTime', () {
        // Arrange
        final testDateTime = DateTime(2024, 1, 15, 10, 30, 45);
        final timestamp = Timestamp.fromDate(testDateTime);

        // Act
        final result = DateUtils.parseFirebaseTimestamp(timestamp);

        // Assert
        expect(result, equals(testDateTime));
      });

      test('should convert positive milliseconds timestamp to DateTime', () {
        // Arrange
        final testDateTime = DateTime(2024, 1, 15, 10, 30, 45);
        final milliseconds = testDateTime.millisecondsSinceEpoch;

        // Act
        final result = DateUtils.parseFirebaseTimestamp(milliseconds);

        // Assert
        expect(result, equals(testDateTime));
      });

      test('should throw ArgumentError for unknown type', () {
        // Arrange
        const value = 'invalid_type';

        // Act & Assert
        expect(
          () => DateUtils.parseFirebaseTimestamp(value),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for zero milliseconds timestamp', () {
        // Arrange
        const milliseconds = 0;

        // Act & Assert
        expect(
          () => DateUtils.parseFirebaseTimestamp(milliseconds),
          throwsA(isA<ArgumentError>()),
        );
      });

      test(
        'should throw ArgumentError for negative milliseconds timestamp',
        () {
          // Arrange
          const milliseconds = -1000;

          // Act & Assert
          expect(
            () => DateUtils.parseFirebaseTimestamp(milliseconds),
            throwsA(isA<ArgumentError>()),
          );
        },
      );

      test(
        'should throw ArgumentError with correct message for null value',
        () {
          // Arrange
          const value = null;

          // Act & Assert
          expect(
            () => DateUtils.parseFirebaseTimestamp(value),
            throwsA(
              predicate(
                (e) =>
                    e is ArgumentError && e.message == 'Value cannot be null',
              ),
            ),
          );
        },
      );

      test(
        'should throw ArgumentError with correct message for non-positive int',
        () {
          // Arrange
          const milliseconds = 0;

          // Act & Assert
          expect(
            () => DateUtils.parseFirebaseTimestamp(milliseconds),
            throwsA(
              predicate(
                (e) =>
                    e is ArgumentError &&
                    e.message == 'Value must be positive, got 0',
              ),
            ),
          );
        },
      );

      test(
        'should throw ArgumentError with correct message for invalid type',
        () {
          // Arrange
          const value = 'invalid_type';

          // Act & Assert
          expect(
            () => DateUtils.parseFirebaseTimestamp(value),
            throwsA(
              predicate(
                (e) =>
                    e is ArgumentError &&
                    e.message ==
                        'Value must be either Timestamp or int, got String',
              ),
            ),
          );
        },
      );
    });

    group('toFirebaseTimestamp', () {
      test('should return FieldValue.serverTimestamp()', () {
        // Arrange
        final testDateTime = DateTime(2024, 1, 15, 10, 30, 45);

        // Act
        final result = DateUtils.toFirebaseTimestamp(testDateTime);

        // Assert
        expect(result, isA<FieldValue>());
        expect(result, equals(FieldValue.serverTimestamp()));
      });

      test('should return FieldValue.serverTimestamp() for any DateTime', () {
        // Arrange
        final testDateTime1 = DateTime.fromMillisecondsSinceEpoch(0);
        final testDateTime2 = DateTime.now();
        final testDateTime3 = DateTime(2024, 1, 15, 10, 30, 45, 123, 456);

        // Act
        final result1 = DateUtils.toFirebaseTimestamp(testDateTime1);
        final result2 = DateUtils.toFirebaseTimestamp(testDateTime2);
        final result3 = DateUtils.toFirebaseTimestamp(testDateTime3);

        // Assert
        expect(result1, equals(FieldValue.serverTimestamp()));
        expect(result2, equals(FieldValue.serverTimestamp()));
        expect(result3, equals(FieldValue.serverTimestamp()));
      });
    });

    group('formatDate', () {
      test('should format date with day and month', () {
        // Arrange
        final testDateTime = DateTime(2024, 1, 15);

        // Act
        final result = DateUtils.formatDate(testDateTime);

        // Assert
        expect(result, equals('15.1'));
      });

      test('should format date with single digit day and month', () {
        // Arrange
        final testDateTime = DateTime(2024, 3, 5);

        // Act
        final result = DateUtils.formatDate(testDateTime);

        // Assert
        expect(result, equals('5.3'));
      });

      test('should format date with double digit day and month', () {
        // Arrange
        final testDateTime = DateTime(2024, 12, 25);

        // Act
        final result = DateUtils.formatDate(testDateTime);

        // Assert
        expect(result, equals('25.12'));
      });

      test(
        'should format date with single digit day and double digit month',
        () {
          // Arrange
          final testDateTime = DateTime(2024, 10, 7);

          // Act
          final result = DateUtils.formatDate(testDateTime);

          // Assert
          expect(result, equals('7.10'));
        },
      );

      test(
        'should format date with double digit day and single digit month',
        () {
          // Arrange
          final testDateTime = DateTime(2024, 4, 20);

          // Act
          final result = DateUtils.formatDate(testDateTime);

          // Assert
          expect(result, equals('20.4'));
        },
      );

      test('should format date with time components (should ignore time)', () {
        // Arrange
        final testDateTime = DateTime(2024, 6, 15, 14, 30, 45, 123);

        // Act
        final result = DateUtils.formatDate(testDateTime);

        // Assert
        expect(result, equals('15.6'));
      });

      test('should format date with different years (should ignore year)', () {
        // Arrange
        final testDateTime1 = DateTime(2023, 8, 10);
        final testDateTime2 = DateTime(2024, 8, 10);
        final testDateTime3 = DateTime(2025, 8, 10);

        // Act
        final result1 = DateUtils.formatDate(testDateTime1);
        final result2 = DateUtils.formatDate(testDateTime2);
        final result3 = DateUtils.formatDate(testDateTime3);

        // Assert
        expect(result1, equals('10.8'));
        expect(result2, equals('10.8'));
        expect(result3, equals('10.8'));
      });
    });
  });
}
