import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('Money', () {
    test('zero() creates a zero amount in the given currency', () {
      final zero = Money.zero('USD');

      expect(zero.minorUnits, 0);
      expect(zero.isZero, isTrue);
      expect(zero.currencyCode, 'USD');
    });

    test('majorUnits divides minorUnits by 100', () {
      const money = Money(minorUnits: 1050, currencyCode: 'USD');

      expect(money.majorUnits, 10.5);
    });

    test('addition and subtraction combine same-currency amounts', () {
      const a = Money(minorUnits: 1000, currencyCode: 'USD');
      const b = Money(minorUnits: 250, currencyCode: 'USD');

      expect((a + b).minorUnits, 1250);
      expect((a - b).minorUnits, 750);
    });

    test('multiplication scales and rounds to the nearest minor unit', () {
      const price = Money(minorUnits: 999, currencyCode: 'USD');

      expect((price * 3).minorUnits, 2997);
      expect((price * 0.5).minorUnits, 500);
    });

    test('combining different currencies throws', () {
      const usd = Money(minorUnits: 100, currencyCode: 'USD');
      const eur = Money(minorUnits: 100, currencyCode: 'EUR');

      expect(() => usd + eur, throwsArgumentError);
      expect(() => usd.compareTo(eur), throwsArgumentError);
    });

    test('comparison operators order same-currency amounts by minorUnits', () {
      const cheap = Money(minorUnits: 100, currencyCode: 'USD');
      const expensive = Money(minorUnits: 500, currencyCode: 'USD');

      expect(cheap < expensive, isTrue);
      expect(expensive > cheap, isTrue);
      expect(cheap <= cheap, isTrue);
      expect(expensive >= expensive, isTrue);
    });

    test('isNegative reflects a negative amount (e.g. a refund)', () {
      const refund = Money(minorUnits: -500, currencyCode: 'USD');

      expect(refund.isNegative, isTrue);
    });

    test('supports value equality', () {
      const a = Money(minorUnits: 100, currencyCode: 'USD');
      const b = Money(minorUnits: 100, currencyCode: 'USD');
      const c = Money(minorUnits: 100, currencyCode: 'EUR');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
