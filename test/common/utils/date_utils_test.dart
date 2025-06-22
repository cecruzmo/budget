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
      test('should convert DateTime to milliseconds timestamp', () {
        // Arrange
        final testDateTime = DateTime(2024, 1, 15, 10, 30, 45);
        final expectedMilliseconds = testDateTime.millisecondsSinceEpoch;

        // Act
        final result = DateUtils.toFirebaseTimestamp(testDateTime);

        // Assert
        expect(result, equals(expectedMilliseconds));
      });

      test('should handle DateTime with zero milliseconds', () {
        // Arrange
        final testDateTime = DateTime.fromMillisecondsSinceEpoch(0);
        const expectedMilliseconds = 0;

        // Act
        final result = DateUtils.toFirebaseTimestamp(testDateTime);

        // Assert
        expect(result, equals(expectedMilliseconds));
      });

      test('should handle current DateTime', () {
        // Arrange
        final testDateTime = DateTime.now();
        final expectedMilliseconds = testDateTime.millisecondsSinceEpoch;

        // Act
        final result = DateUtils.toFirebaseTimestamp(testDateTime);

        // Assert
        expect(result, equals(expectedMilliseconds));
      });

      test('should handle DateTime with microseconds', () {
        // Arrange
        final testDateTime = DateTime(2024, 1, 15, 10, 30, 45, 123, 456);
        final expectedMilliseconds = testDateTime.millisecondsSinceEpoch;

        // Act
        final result = DateUtils.toFirebaseTimestamp(testDateTime);

        // Assert
        expect(result, equals(expectedMilliseconds));
      });
    });
  });
}
