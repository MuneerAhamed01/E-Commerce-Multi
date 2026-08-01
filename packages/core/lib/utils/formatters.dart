import 'package:intl/intl.dart';

import '../shared_entities/money.dart';

/// Shared currency/date/number formatting.
///
/// Centralizing formatting here means a future "always show tenant's
/// locale" or "always show 24h time" policy is a one-file change, not a
/// hunt across every feature's presentation layer.
abstract final class Formatters {
  /// Formats [money] as a localized currency string, e.g. `'$12.50'`.
  ///
  /// Uses `simpleCurrency` (not `currency`) so the currency *symbol*
  /// (`'$'`) is resolved from [money]'s ISO code, rather than the ISO code
  /// itself being printed literally.
  static String currency(Money money, {String locale = 'en_US'}) {
    final format = NumberFormat.simpleCurrency(
      locale: locale,
      name: money.currencyCode,
    );
    return format.format(money.majorUnits);
  }

  /// Formats [date] using [pattern] (an `intl` `DateFormat` skeleton),
  /// defaulting to a medium-length date, e.g. `'Jan 5, 2026'`.
  static String date(
    DateTime date, {
    String pattern = 'MMM d, yyyy',
    String? locale,
  }) {
    return DateFormat(pattern, locale).format(date);
  }

  /// Formats [dateTime] as a date plus a 12-hour time, e.g.
  /// `'Jan 5, 2026, 3:45 PM'`.
  static String dateTime(
    DateTime dateTime, {
    String pattern = 'MMM d, yyyy, h:mm a',
    String? locale,
  }) {
    return DateFormat(pattern, locale).format(dateTime);
  }

  /// Formats [value] compactly, e.g. `12000` -> `'12K'` - suited to admin
  /// dashboard KPI tiles.
  static String compactNumber(num value, {String locale = 'en_US'}) {
    return NumberFormat.compact(locale: locale).format(value);
  }

  /// Formats [ratio] (`0.0`-`1.0`) as a percentage string, e.g.
  /// `0.075` -> `'7.5%'`.
  static String percentage(double ratio, {int decimalDigits = 1}) {
    final format = NumberFormat.decimalPercentPattern(
      decimalDigits: decimalDigits,
    );
    return format.format(ratio);
  }
}
