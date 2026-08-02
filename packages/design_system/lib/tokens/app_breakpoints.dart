import 'package:flutter/widgets.dart';

/// The three responsive tiers every screen in the platform must account for
/// (see docs/06_DEVELOPMENT_RULES.md Rule 21 and docs/07_SCREEN_CATALOG.md).
enum AppScreenSize {
  /// Narrow viewports: phones in portrait, most phones in landscape.
  mobile,

  /// Medium viewports: tablets, foldables, small browser windows.
  tablet,

  /// Wide viewports: desktop browsers, large tablets in landscape,
  /// admin-panel-typical screens.
  desktop,
}

/// The platform's responsive breakpoint scale, expressed as the minimum
/// logical-pixel width at which each [AppScreenSize] tier begins.
///
/// Values follow common Material/Flutter-web breakpoint conventions and are
/// shared by both apps so a component behaves identically regardless of
/// which app renders it - see docs/02_PROJECT_STRUCTURE.md §5.
abstract final class AppBreakpoints {
  /// Below this width is [AppScreenSize.mobile].
  static const double tablet = 600;

  /// Below this width (and at/above [tablet]) is [AppScreenSize.tablet].
  static const double desktop = 1024;

  /// At/above this width, layouts may use a wider max-content-width cap
  /// (large desktop monitors, admin panel on ultra-wide displays).
  static const double wide = 1440;

  /// Classifies [width] into an [AppScreenSize] tier.
  static AppScreenSize screenSizeFor(double width) {
    if (width >= desktop) {
      return AppScreenSize.desktop;
    }
    if (width >= tablet) {
      return AppScreenSize.tablet;
    }
    return AppScreenSize.mobile;
  }

  /// Classifies the current [context]'s width into an [AppScreenSize] tier.
  static AppScreenSize screenSizeOf(BuildContext context) {
    return screenSizeFor(MediaQuery.sizeOf(context).width);
  }

  /// Whether [context]'s width falls in the [AppScreenSize.mobile] tier.
  static bool isMobile(BuildContext context) =>
      screenSizeOf(context) == AppScreenSize.mobile;

  /// Whether [context]'s width falls in the [AppScreenSize.tablet] tier.
  static bool isTablet(BuildContext context) =>
      screenSizeOf(context) == AppScreenSize.tablet;

  /// Whether [context]'s width falls in the [AppScreenSize.desktop] tier.
  static bool isDesktop(BuildContext context) =>
      screenSizeOf(context) == AppScreenSize.desktop;
}
