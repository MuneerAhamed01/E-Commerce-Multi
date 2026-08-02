import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

TenantConfig _tenant({
  String primaryColorHex = '#2563EB',
  String secondaryColorHex = '#F97316',
  String fontFamily = 'Inter',
}) {
  return TenantConfig(
    tenantId: 'acme',
    displayName: 'Acme',
    branding: BrandingTokens(
      primaryColorHex: primaryColorHex,
      secondaryColorHex: secondaryColorHex,
      logoAssetPath: 'assets/logo.png',
      fontFamily: fontFamily,
    ),
    copy: const CopyOverrides.empty(),
    featureFlags: FeatureFlagSet.allEnabled(),
    defaultLocale: 'en_US',
    supportEmail: 'support@acme.test',
    allowGuestBrowsing: true,
    allowGuestCart: true,
  );
}

void main() {
  group('AppTheme.parseHexColor', () {
    test('parses a 6-digit hex string with a leading #', () {
      expect(AppTheme.parseHexColor('#2563EB'), const Color(0xFF2563EB));
    });

    test('parses a 6-digit hex string without a leading #', () {
      expect(AppTheme.parseHexColor('2563EB'), const Color(0xFF2563EB));
    });

    test('parses an 8-digit ARGB hex string', () {
      expect(AppTheme.parseHexColor('#802563EB'), const Color(0x802563EB));
    });

    test('throws a FormatException for an invalid hex string', () {
      expect(
        () => AppTheme.parseHexColor('not-a-color'),
        throwsFormatException,
      );
      expect(() => AppTheme.parseHexColor('#FFF'), throwsFormatException);
    });
  });

  group('AppTheme.light/dark', () {
    test('builds a Material 3 theme seeded from the tenant primary color', () {
      final theme = AppTheme.light(_tenant());

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.textTheme.bodyLarge?.fontFamily, 'Inter');
    });

    test('dark theme reports dark brightness', () {
      final theme = AppTheme.dark(_tenant());
      expect(theme.brightness, Brightness.dark);
    });

    test('registers an AppSemanticColors extension on both brightnesses', () {
      final light = AppTheme.light(_tenant());
      final dark = AppTheme.dark(_tenant());

      expect(light.extension<AppSemanticColors>(), isNotNull);
      expect(dark.extension<AppSemanticColors>(), isNotNull);
      expect(
        light.extension<AppSemanticColors>()!.border,
        AppColors.neutral300,
      );
      expect(dark.extension<AppSemanticColors>()!.border, AppColors.neutral700);
    });

    test('propagates the tenant font family into the text theme', () {
      final theme = AppTheme.light(_tenant(fontFamily: 'Poppins'));
      expect(theme.textTheme.bodyLarge?.fontFamily, 'Poppins');
      expect(theme.textTheme.displayLarge?.fontFamily, 'Poppins');
    });

    test('throws when tenant branding contains an invalid hex color', () {
      expect(
        () => AppTheme.light(_tenant(primaryColorHex: 'invalid')),
        throwsFormatException,
      );
    });
  });
}
