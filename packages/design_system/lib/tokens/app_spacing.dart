/// The platform's spacing scale.
///
/// Every gap, padding, and margin in the app references one of these
/// constants instead of a literal number, so a future global density change
/// (or per-tenant density tweak) is a one-file edit - see
/// docs/06_DEVELOPMENT_RULES.md Rule 10.
abstract final class AppSpacing {
  /// 2px - hairline gaps (e.g. between an icon and a badge overlapping it).
  static const double xxs = 2;

  /// 4px - tightest usable gap between closely related elements.
  static const double xs = 4;

  /// 8px - default gap between related inline elements (icon + label).
  static const double sm = 8;

  /// 12px - compact section padding, list-tile internal spacing.
  static const double smMd = 12;

  /// 16px - the platform's baseline spacing unit (card padding, page gutters).
  static const double md = 16;

  /// 24px - spacing between distinct content blocks within a screen.
  static const double lg = 24;

  /// 32px - spacing between major page sections.
  static const double xl = 32;

  /// 48px - large vertical rhythm (empty states, section breaks).
  static const double xxl = 48;

  /// 64px - largest scale, reserved for hero/splash-style layouts.
  static const double xxxl = 64;
}
