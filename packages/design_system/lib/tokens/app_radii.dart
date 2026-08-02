import 'package:flutter/widgets.dart';

/// The platform's corner-radius scale.
///
/// Every rounded corner in the app references one of these constants (or
/// the [BorderRadius] convenience getters below) instead of a literal
/// `Radius.circular(...)` value - see docs/06_DEVELOPMENT_RULES.md Rule 10.
abstract final class AppRadii {
  /// 0px - square corners (dense admin tables, full-bleed images).
  static const double none = 0;

  /// 4px - subtle rounding (chips, small badges).
  static const double xs = 4;

  /// 8px - default control rounding (buttons, text fields, small cards).
  static const double sm = 8;

  /// 12px - standard card/dialog rounding.
  static const double md = 12;

  /// 16px - prominent surfaces (bottom sheets, large cards).
  static const double lg = 16;

  /// 24px - hero surfaces, large modals.
  static const double xl = 24;

  /// A large-enough value to fully round any pill-shaped control regardless
  /// of its height (avatars, fully-rounded buttons/badges).
  static const double full = 999;

  static const BorderRadius borderRadiusXs = BorderRadius.all(
    Radius.circular(xs),
  );
  static const BorderRadius borderRadiusSm = BorderRadius.all(
    Radius.circular(sm),
  );
  static const BorderRadius borderRadiusMd = BorderRadius.all(
    Radius.circular(md),
  );
  static const BorderRadius borderRadiusLg = BorderRadius.all(
    Radius.circular(lg),
  );
  static const BorderRadius borderRadiusXl = BorderRadius.all(
    Radius.circular(xl),
  );
  static const BorderRadius borderRadiusFull = BorderRadius.all(
    Radius.circular(full),
  );
}
