import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('FeatureFlagSet.allEnabled', () {
    test('every flag is enabled', () {
      final flags = FeatureFlagSet.allEnabled();

      for (final flag in FeatureFlag.values) {
        expect(
          flags.isEnabled(flag),
          isTrue,
          reason: '$flag should be enabled',
        );
      }
    });
  });

  group('FeatureFlagSet.fromJson', () {
    test('reads explicit true/false values per flag', () {
      final flags = FeatureFlagSet.fromJson(const {
        'wishlist': false,
        'reviews': true,
      });

      expect(flags.isEnabled(FeatureFlag.wishlist), isFalse);
      expect(flags.isEnabled(FeatureFlag.reviews), isTrue);
    });

    test('defaults an omitted flag to enabled (additive-only)', () {
      final flags = FeatureFlagSet.fromJson(const {'wishlist': false});

      expect(flags.isEnabled(FeatureFlag.promotions), isTrue);
    });

    test('ignores unrecognized keys', () {
      final flags = FeatureFlagSet.fromJson(const {
        'someFutureFlag': false,
        'wishlist': false,
      });

      expect(flags.isEnabled(FeatureFlag.wishlist), isFalse);
    });

    test('round-trips through toJson', () {
      final flags = FeatureFlagSet.fromJson(const {'wishlist': false});

      final json = flags.toJson();

      expect(json['wishlist'], isFalse);
      expect(json['reviews'], isTrue);
    });

    test('supports value equality', () {
      final a = FeatureFlagSet.fromJson(const {'wishlist': false});
      final b = FeatureFlagSet.fromJson(const {'wishlist': false});
      final c = FeatureFlagSet.fromJson(const {'wishlist': true});

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('FeatureFlagService', () {
    test('isEnabled delegates to the underlying FeatureFlagSet', () {
      final service = FeatureFlagService(
        flags: FeatureFlagSet.fromJson(const {'wishlist': false}),
      );

      expect(service.isEnabled(FeatureFlag.wishlist), isFalse);
      expect(service.isEnabled(FeatureFlag.reviews), isTrue);
    });
  });
}
