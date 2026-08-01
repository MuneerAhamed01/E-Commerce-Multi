import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('Formatters.currency', () {
    test('formats USD with a dollar sign and two decimal places', () {
      const money = Money(minorUnits: 1050, currencyCode: 'USD');

      expect(Formatters.currency(money), r'$10.50');
    });

    test('formats a zero amount', () {
      expect(Formatters.currency(Money.zero('USD')), r'$0.00');
    });
  });

  group('Formatters.date', () {
    test('formats using the default medium-date pattern', () {
      final date = DateTime(2026, 1, 5);

      expect(Formatters.date(date), 'Jan 5, 2026');
    });

    test('honors a custom pattern', () {
      final date = DateTime(2026, 1, 5);

      expect(Formatters.date(date, pattern: 'yyyy-MM-dd'), '2026-01-05');
    });
  });

  group('Formatters.dateTime', () {
    test('formats a date plus a 12-hour time', () {
      final dateTime = DateTime(2026, 1, 5, 15, 45);

      expect(Formatters.dateTime(dateTime), 'Jan 5, 2026, 3:45 PM');
    });
  });

  group('Formatters.compactNumber', () {
    test('abbreviates large numbers', () {
      expect(Formatters.compactNumber(12000), '12K');
      expect(Formatters.compactNumber(1500000), '1.5M');
    });
  });

  group('Formatters.percentage', () {
    test('formats a 0-1 ratio as a percentage with one decimal by default', () {
      expect(Formatters.percentage(0.075), '7.5%');
    });

    test('honors a custom decimal digit count', () {
      expect(Formatters.percentage(0.5, decimalDigits: 0), '50%');
    });
  });
}
