import 'package:flutter/widgets.dart';

import '../tokens/app_breakpoints.dart';

/// Signature for a breakpoint-specific builder passed to
/// [AppResponsiveLayoutBuilder].
typedef AppResponsiveWidgetBuilder =
    Widget Function(BuildContext context, BoxConstraints constraints);

/// Renders a different widget subtree per [AppScreenSize] tier, using
/// [AppBreakpoints] as the single source of truth for where each tier
/// begins - see docs/06_DEVELOPMENT_RULES.md Rule 21.
///
/// [tablet] and [desktop] are optional: when omitted, the next-narrower
/// builder is reused (so a screen with only a mobile/desktop distinction
/// doesn't need to duplicate a tablet builder).
///
/// ```dart
/// AppResponsiveLayoutBuilder(
///   mobile: (context, _) => const _MobileHome(),
///   desktop: (context, _) => const _DesktopHome(),
/// );
/// ```
class AppResponsiveLayoutBuilder extends StatelessWidget {
  const AppResponsiveLayoutBuilder({
    required this.mobile,
    this.tablet,
    this.desktop,
    super.key,
  });

  /// Builder used at [AppScreenSize.mobile] and, if [tablet]/[desktop] are
  /// omitted, at every wider tier too.
  final AppResponsiveWidgetBuilder mobile;

  /// Builder used at [AppScreenSize.tablet]. Falls back to [mobile] when
  /// omitted.
  final AppResponsiveWidgetBuilder? tablet;

  /// Builder used at [AppScreenSize.desktop]. Falls back to [tablet], then
  /// [mobile], when omitted.
  final AppResponsiveWidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = AppBreakpoints.screenSizeFor(constraints.maxWidth);
        final builder = switch (screenSize) {
          AppScreenSize.mobile => mobile,
          AppScreenSize.tablet => tablet ?? mobile,
          AppScreenSize.desktop => desktop ?? tablet ?? mobile,
        };
        return builder(context, constraints);
      },
    );
  }
}
