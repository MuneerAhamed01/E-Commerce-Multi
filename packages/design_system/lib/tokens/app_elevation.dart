/// The platform's elevation (shadow depth) scale.
///
/// Every `Material`/`Card`/`elevation`-accepting widget references one of
/// these constants instead of a literal number - see
/// docs/06_DEVELOPMENT_RULES.md Rule 10.
abstract final class AppElevation {
  /// 0 - flat surfaces (outlined cards, inline banners).
  static const double none = 0;

  /// 1 - resting elevated surfaces (default `AppCard`).
  static const double low = 1;

  /// 3 - raised surfaces (app bars, sticky panels).
  static const double medium = 3;

  /// 6 - floating surfaces (FABs, snackbars).
  static const double high = 6;

  /// 12 - overlays above the rest of the page (dialogs, bottom sheets).
  static const double highest = 12;
}
