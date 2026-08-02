import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

/// Semantic colors not covered by Flutter's [ColorScheme] (success/warning/
/// info, plus a couple of cross-cutting neutrals), exposed as a
/// [ThemeExtension] so every component reads them via `Theme.of(context)`
/// rather than importing [AppColors] directly - see
/// docs/08_COMPONENT_LIBRARY.md §18 ("every component is theme-aware, not
/// tenant-aware") and docs/05_ARCHITECTURE_GUIDELINES.md §15.
///
/// Registered on both [AppTheme.light] and [AppTheme.dark]
/// (`theme/app_theme.dart`); read it as:
///
/// ```dart
/// final semantic = Theme.of(context).extension<AppSemanticColors>()!;
/// Container(color: semantic.successContainer);
/// ```
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.border,
    required this.disabled,
    required this.disabledForeground,
    required this.overlay,
  });

  /// The light-theme instance, registered by [AppTheme.light].
  factory AppSemanticColors.light() {
    return const AppSemanticColors(
      success: AppColors.success,
      onSuccess: AppColors.onSuccess,
      successContainer: AppColors.successContainer,
      onSuccessContainer: AppColors.onSuccessContainer,
      warning: AppColors.warning,
      onWarning: AppColors.onWarning,
      warningContainer: AppColors.warningContainer,
      onWarningContainer: AppColors.onWarningContainer,
      info: AppColors.info,
      onInfo: AppColors.onInfo,
      infoContainer: AppColors.infoContainer,
      onInfoContainer: AppColors.onInfoContainer,
      border: AppColors.neutral300,
      disabled: AppColors.neutral200,
      disabledForeground: AppColors.neutral400,
      overlay: Color(0x1F000000),
    );
  }

  /// The dark-theme instance, registered by [AppTheme.dark].
  factory AppSemanticColors.dark() {
    return const AppSemanticColors(
      success: AppColors.success,
      onSuccess: AppColors.onSuccess,
      successContainer: Color(0xFF14532D),
      onSuccessContainer: AppColors.successContainer,
      warning: AppColors.warning,
      onWarning: AppColors.onWarning,
      warningContainer: Color(0xFF78350F),
      onWarningContainer: AppColors.warningContainer,
      info: AppColors.info,
      onInfo: AppColors.onInfo,
      infoContainer: Color(0xFF0C4A6E),
      onInfoContainer: AppColors.infoContainer,
      border: AppColors.neutral700,
      disabled: AppColors.neutral800,
      disabledForeground: AppColors.neutral600,
      overlay: Color(0x3DFFFFFF),
    );
  }

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;

  /// Default hairline border color for outlined surfaces (cards, inputs).
  final Color border;

  /// Background fill for disabled interactive controls.
  final Color disabled;

  /// Foreground (text/icon) color for disabled interactive controls.
  final Color disabledForeground;

  /// Scrim/overlay tint for pressed states and modal backdrops.
  final Color overlay;

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? border,
    Color? disabled,
    Color? disabledForeground,
    Color? overlay,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      border: border ?? this.border,
      disabled: disabled ?? this.disabled,
      disabledForeground: disabledForeground ?? this.disabledForeground,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) {
      return this;
    }
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      border: Color.lerp(border, other.border, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      disabledForeground: Color.lerp(
        disabledForeground,
        other.disabledForeground,
        t,
      )!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
    );
  }
}

/// Convenience accessor so call sites can write `context.semanticColors`
/// instead of the more verbose `Theme.of(context).extension<...>()`.
extension AppSemanticColorsContext on BuildContext {
  /// The active [AppSemanticColors], registered by every theme this package
  /// builds (`AppTheme.light`/`AppTheme.dark`). Falls back to
  /// [AppSemanticColors.light] if a theme without this extension is in
  /// scope (e.g. a widget test using a bare [ThemeData]), so components
  /// never crash for lack of the extension - see
  /// docs/08_COMPONENT_LIBRARY.md §18.
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>() ??
      AppSemanticColors.light();
}
