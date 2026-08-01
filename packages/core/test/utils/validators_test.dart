import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty/null input', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('   '), isNotNull);
    });

    test('rejects malformed addresses', () {
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('missing@tld'), isNotNull);
      expect(Validators.email('@no-local-part.com'), isNotNull);
    });

    test('accepts plausible addresses', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('  user.name+tag@example.co.uk  '), isNull);
    });
  });

  group('Validators.phone', () {
    test('rejects empty input', () {
      expect(Validators.phone(null), isNotNull);
      expect(Validators.phone(''), isNotNull);
    });

    test('rejects too-short or malformed numbers', () {
      expect(Validators.phone('123'), isNotNull);
      expect(Validators.phone('abc-defg-hijk'), isNotNull);
    });

    test('accepts plausible numbers, ignoring formatting characters', () {
      expect(Validators.phone('+1 (555) 123-4567'), isNull);
      expect(Validators.phone('5551234567'), isNull);
    });
  });

  group('Validators.passwordStrength', () {
    test('rejects empty, short, or letter/digit-only passwords', () {
      expect(Validators.passwordStrength(null), isNotNull);
      expect(Validators.passwordStrength(''), isNotNull);
      expect(Validators.passwordStrength('short1'), isNotNull);
      expect(Validators.passwordStrength('alllettersnodigits'), isNotNull);
      expect(Validators.passwordStrength('12345678'), isNotNull);
    });

    test('accepts a password with letters and digits at minimum length', () {
      expect(Validators.passwordStrength('abcd1234'), isNull);
    });
  });

  group('Validators.required', () {
    test(
      'rejects empty/whitespace-only input with a field-specific message',
      () {
        expect(
          Validators.required(null, fieldName: 'First name'),
          'First name is required',
        );
        expect(Validators.required('   '), 'This field is required');
      },
    );

    test('accepts non-empty input', () {
      expect(Validators.required('Jane'), isNull);
    });
  });
}
