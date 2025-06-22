import 'package:cloud_firestore/cloud_firestore.dart';

class DateUtils {
  static DateTime parseFirebaseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is int) {
      if (value <= 0) throw ArgumentError('Value must be positive, got $value');
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value == null) throw ArgumentError('Value cannot be null');
    throw ArgumentError(
      'Value must be either Timestamp or int, got ${value.runtimeType}',
    );
  }

  static int toFirebaseTimestamp(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }
}
