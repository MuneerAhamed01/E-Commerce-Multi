import 'package:flutter/painting.dart';

/// The platform's type scale.
///
/// Every text style used in the app derives from one of these instead of an
/// ad hoc `TextStyle(fontSize: ...)` literal - see
/// docs/06_DEVELOPMENT_RULES.md Rule 10. Styles here carry size/weight/
/// letter-spacing only; color and font family are applied by `AppTheme`
/// (`theme/app_theme.dart`), since both are tenant-driven
/// (`TenantConfig.branding.fontFamily`) and theme-mode-driven (light/dark
/// text color) - keeping these tokens portable regardless of tenant/theme.
abstract final class AppTypography {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  static const TextStyle displayLarge = TextStyle(
    fontSize: 40,
    height: 1.2,
    fontWeight: bold,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 32,
    height: 1.2,
    fontWeight: bold,
    letterSpacing: -0.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 28,
    height: 1.25,
    fontWeight: bold,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    height: 1.25,
    fontWeight: semiBold,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    height: 1.3,
    fontWeight: semiBold,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    height: 1.3,
    fontWeight: semiBold,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    height: 1.35,
    fontWeight: semiBold,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    height: 1.4,
    fontWeight: medium,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    height: 1.4,
    fontWeight: medium,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: regular,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    height: 1.5,
    fontWeight: regular,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    height: 1.45,
    fontWeight: regular,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    height: 1.3,
    fontWeight: medium,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    height: 1.3,
    fontWeight: medium,
    letterSpacing: 0.15,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    height: 1.3,
    fontWeight: medium,
    letterSpacing: 0.2,
  );
}
