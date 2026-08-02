import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('BrandingTokens', () {
    test('fromJson/toJson round-trip, defaulting fontFamily when absent', () {
      final tokens = BrandingTokens.fromJson(const {
        'primaryColorHex': '#2563EB',
        'secondaryColorHex': '#F97316',
        'logoAssetPath': 'assets/logo.png',
      });

      expect(tokens.fontFamily, 'Inter');
      expect(tokens.logoUrl, isNull);
      expect(tokens.toJson(), const {
        'primaryColorHex': '#2563EB',
        'secondaryColorHex': '#F97316',
        'logoAssetPath': 'assets/logo.png',
        'fontFamily': 'Inter',
      });
    });

    test('logoUrl is included in toJson only when present', () {
      final tokens = BrandingTokens.fromJson(const {
        'primaryColorHex': '#2563EB',
        'secondaryColorHex': '#F97316',
        'logoAssetPath': 'assets/logo.png',
        'logoUrl': 'https://cdn.example.com/logo.png',
      });

      expect(tokens.toJson()['logoUrl'], 'https://cdn.example.com/logo.png');
    });
  });

  group('CopyOverrides', () {
    test('resolve falls back to the caller-supplied default when unset', () {
      const overrides = CopyOverrides.empty();

      expect(overrides.resolve('checkout.title', 'Checkout'), 'Checkout');
    });

    test('resolve returns the tenant override when present', () {
      final overrides = CopyOverrides.fromJson(const {
        'checkout.title': 'Secure Checkout',
      });

      expect(
        overrides.resolve('checkout.title', 'Checkout'),
        'Secure Checkout',
      );
    });
  });

  group('TenantConfig.fromJson', () {
    const json = {
      'tenantId': 'acme',
      'displayName': 'Acme Co.',
      'branding': {
        'primaryColorHex': '#000000',
        'secondaryColorHex': '#FFFFFF',
        'logoAssetPath': 'assets/acme_logo.png',
      },
      'supportEmail': 'help@acme.example',
    };

    test(
      'parses required fields and applies documented defaults for the rest',
      () {
        final config = TenantConfig.fromJson(json);

        expect(config.tenantId, 'acme');
        expect(config.displayName, 'Acme Co.');
        expect(config.branding.primaryColorHex, '#000000');
        expect(config.copy, const CopyOverrides.empty());
        expect(config.featureFlags, equals(FeatureFlagSet.allEnabled()));
        expect(config.defaultLocale, 'en_US');
        expect(config.allowGuestBrowsing, isTrue);
        expect(config.allowGuestCart, isTrue);
      },
    );

    test(
      'honors explicit copy, featureFlags, locale, and guest-access overrides',
      () {
        final config = TenantConfig.fromJson(const {
          ...json,
          'copy': {'checkout.title': 'Secure Checkout'},
          'featureFlags': {'wishlist': false},
          'defaultLocale': 'fr_FR',
          'allowGuestBrowsing': false,
          'allowGuestCart': false,
        });

        expect(
          config.copy.resolve('checkout.title', 'Checkout'),
          'Secure Checkout',
        );
        expect(config.featureFlags.isEnabled(FeatureFlag.wishlist), isFalse);
        expect(config.defaultLocale, 'fr_FR');
        expect(config.allowGuestBrowsing, isFalse);
        expect(config.allowGuestCart, isFalse);
      },
    );

    test('round-trips through toJson and back to an equal TenantConfig', () {
      final original = TenantConfig.fromJson(json);

      final roundTripped = TenantConfig.fromJson(original.toJson());

      expect(roundTripped, equals(original));
    });
  });

  group('default_tenant.json contract', () {
    test(
      'the shipped default tenant JSON parses into a valid TenantConfig',
      () {
        // Mirrors config/tenants/default_tenant.json exactly - a change to
        // that file that breaks this test is a signal the schema drifted
        // from what TenantConfig.fromJson expects.
        final config = TenantConfig.fromJson(const {
          'tenantId': 'default',
          'displayName': 'White Label Commerce Platform',
          'branding': {
            'primaryColorHex': '#2563EB',
            'secondaryColorHex': '#F97316',
            'logoAssetPath': 'assets/branding/default_logo.png',
            'logoUrl': null,
            'fontFamily': 'Inter',
          },
          'copy': <String, dynamic>{},
          'featureFlags': {
            'wishlist': true,
            'reviews': true,
            'promotions': true,
            'guestCheckout': true,
            'notifications': true,
            'support': true,
            'multiplePaymentMethods': true,
            'productVariants': true,
          },
          'defaultLocale': 'en_US',
          'supportEmail': 'support@example.com',
          'allowGuestBrowsing': true,
          'allowGuestCart': true,
        });

        expect(config.tenantId, 'default');
        expect(config.featureFlags, equals(FeatureFlagSet.allEnabled()));
      },
    );
  });
}
