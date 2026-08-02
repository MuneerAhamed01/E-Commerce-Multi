import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_elevation.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_typography.dart';
import 'theme_extensions.dart';

/// Builds a Flutter [ThemeData] from a [TenantConfig], the white-label
/// theming seam described in docs/05_ARCHITECTURE_GUIDELINES.md §15: this is
/// the *only* place `BrandingTokens`' hex-string colors are parsed into
/// `Color` objects (`core` stays Flutter-free - see
/// `packages/core/lib/config/tenant_config.dart`).
///
/// Every screen/widget reads the result via `Theme.of(context)` (or
/// [AppSemanticColors]) - never `TenantConfig` directly - so components stay
/// theme-aware, not tenant-aware, and are testable with any arbitrary theme
/// (docs/08_COMPONENT_LIBRARY.md §18).
///
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light(tenantConfig),
///   darkTheme: AppTheme.dark(tenantConfig),
/// );
/// ```
abstract final class AppTheme {
  /// Builds the light-mode [ThemeData] for [tenant].
  static ThemeData light(TenantConfig tenant) =>
      _build(tenant, Brightness.light);

  /// Builds the dark-mode [ThemeData] for [tenant].
  static ThemeData dark(TenantConfig tenant) => _build(tenant, Brightness.dark);

  /// Parses a `#RRGGBB` or `#AARRGGBB` hex color string (the format
  /// [BrandingTokens] stores) into a Flutter [Color].
  ///
  /// The leading `#` is optional. Throws a [FormatException] if [hexString]
  /// isn't a valid 6- or 8-digit hex value, so a malformed tenant JSON fails
  /// fast at theme-build time rather than silently rendering the wrong
  /// color.
  static Color parseHexColor(String hexString) {
    var hex = hexString.trim();
    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    }
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    if (hex.length != 8) {
      throw FormatException('Invalid hex color: "$hexString"', hexString);
    }
    final value = int.tryParse(hex, radix: 16);
    if (value == null) {
      throw FormatException('Invalid hex color: "$hexString"', hexString);
    }
    return Color(value);
  }

  static ThemeData _build(TenantConfig tenant, Brightness brightness) {
    final primary = parseHexColor(tenant.branding.primaryColorHex);
    final secondary = parseHexColor(tenant.branding.secondaryColorHex);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      secondary: secondary,
      error: AppColors.error,
      onError: AppColors.onError,
    );

    final semanticColors = brightness == Brightness.light
        ? AppSemanticColors.light()
        : AppSemanticColors.dark();

    final textTheme = _textTheme(
      fontFamily: tenant.branding.fontFamily,
      color: colorScheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: tenant.branding.fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: [semanticColors],
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surface,
        elevation: AppElevation.none,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: AppElevation.low,
        color: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.borderRadiusMd,
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: semanticColors.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.borderRadiusSm,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderRadiusSm,
          borderSide: BorderSide(color: semanticColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderRadiusSm,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderRadiusSm,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.borderRadiusSm,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.borderRadiusMd,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.lg),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: textTheme.labelLarge,
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),
    );
  }

  static TextTheme _textTheme({
    required String fontFamily,
    required Color color,
  }) {
    TextStyle apply(TextStyle base) =>
        base.copyWith(fontFamily: fontFamily, color: color);

    return TextTheme(
      displayLarge: apply(AppTypography.displayLarge),
      displayMedium: apply(AppTypography.displayMedium),
      displaySmall: apply(AppTypography.displaySmall),
      headlineLarge: apply(AppTypography.headlineLarge),
      headlineMedium: apply(AppTypography.headlineMedium),
      headlineSmall: apply(AppTypography.headlineSmall),
      titleLarge: apply(AppTypography.titleLarge),
      titleMedium: apply(AppTypography.titleMedium),
      titleSmall: apply(AppTypography.titleSmall),
      bodyLarge: apply(AppTypography.bodyLarge),
      bodyMedium: apply(AppTypography.bodyMedium),
      bodySmall: apply(AppTypography.bodySmall),
      labelLarge: apply(AppTypography.labelLarge),
      labelMedium: apply(AppTypography.labelMedium),
      labelSmall: apply(AppTypography.labelSmall),
    );
  }
}
