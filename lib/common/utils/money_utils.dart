import 'package:intl/intl.dart';

import 'package:budget/common/utils/locale_utils.dart';

class MoneyUtils {
  static String formatMoney(double amount) {
    final locale = LocaleUtils.getLocale();
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '\$',
      decimalDigits: 2,
    );

    String formatted = formatter.format(amount);

    if (formatted.endsWith('.00')) {
      formatted = formatted.substring(0, formatted.length - 3);
    }

    return formatted;
  }
}
