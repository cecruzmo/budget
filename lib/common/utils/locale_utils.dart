import 'dart:io';
import 'package:intl/intl.dart';

class LocaleUtils {
  static String getLocale() {
    try {
      final locale = Platform.localeName;
      // Try to create a DateFormat to test if locale is available
      DateFormat('d.M', locale);
      return locale;
    } catch (e) {
      return 'en_US';
    }
  }
}
