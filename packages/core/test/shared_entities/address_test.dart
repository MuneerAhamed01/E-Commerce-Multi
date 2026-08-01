import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('Address', () {
    const address = Address(
      line1: '123 Main St',
      line2: 'Apt 4B',
      city: 'Springfield',
      state: 'IL',
      postalCode: '62704',
      countryCode: 'US',
      label: 'Home',
    );

    test('singleLine joins non-empty parts with a comma', () {
      expect(
        address.singleLine,
        '123 Main St, Apt 4B, Springfield, IL, 62704, US',
      );
    });

    test('singleLine omits a null/empty line2', () {
      const noLine2 = Address(
        line1: '1 Infinite Loop',
        city: 'Cupertino',
        state: 'CA',
        postalCode: '95014',
        countryCode: 'US',
      );

      expect(noLine2.singleLine, '1 Infinite Loop, Cupertino, CA, 95014, US');
    });

    test('label is optional and does not affect singleLine', () {
      const withoutLabel = Address(
        line1: '123 Main St',
        line2: 'Apt 4B',
        city: 'Springfield',
        state: 'IL',
        postalCode: '62704',
        countryCode: 'US',
      );

      expect(withoutLabel.singleLine, address.singleLine);
      expect(withoutLabel, isNot(equals(address)));
    });

    test('supports value equality', () {
      const copy = Address(
        line1: '123 Main St',
        line2: 'Apt 4B',
        city: 'Springfield',
        state: 'IL',
        postalCode: '62704',
        countryCode: 'US',
        label: 'Home',
      );

      expect(address, equals(copy));
    });
  });
}
