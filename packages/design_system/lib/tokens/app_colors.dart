import 'package:flutter/painting.dart';

/// The platform's tenant-neutral color palette.
///
/// These are the *base* values a theme is built from - not the runtime
/// palette a screen should read. Screens/components always read colors via
/// `Theme.of(context).colorScheme` or [AppSemanticColors]
/// (`theme/theme_extensions.dart`), never these constants directly, because
/// tenant branding (`app_theme.dart`, driven by `TenantConfig.branding`)
/// overrides the brand-facing subset of this palette at runtime - see
/// docs/06_DEVELOPMENT_RULES.md Rule 38.
///
/// The neutral gray scale and semantic (success/warning/info) colors are
/// *not* tenant-overridable in this plan's scope (`TenantConfig` only
/// carries primary/secondary/logo/font - see
/// `packages/core/lib/config/tenant_config.dart`), so these constants are
/// the single source of truth for them across every tenant.
abstract final class AppColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  /// Default primary brand color, used only when no tenant branding is
  /// available yet (e.g. a widget test rendered without [AppTheme]).
  static const Color fallbackPrimary = Color(0xFF2563EB);

  /// Default secondary/accent brand color - see [fallbackPrimary].
  static const Color fallbackSecondary = Color(0xFFF97316);

  static const Color success = Color(0xFF16A34A);
  static const Color onSuccess = white;
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color onSuccessContainer = Color(0xFF14532D);

  static const Color warning = Color(0xFFD97706);
  static const Color onWarning = white;
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarningContainer = Color(0xFF78350F);

  static const Color info = Color(0xFF0284C7);
  static const Color onInfo = white;
  static const Color infoContainer = Color(0xFFE0F2FE);
  static const Color onInfoContainer = Color(0xFF0C4A6E);

  static const Color error = Color(0xFFDC2626);
  static const Color onError = white;
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF7F1D1D);
}
