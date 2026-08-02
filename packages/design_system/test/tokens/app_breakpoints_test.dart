import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppBreakpoints.screenSizeFor', () {
    test('classifies widths below the tablet breakpoint as mobile', () {
      expect(AppBreakpoints.screenSizeFor(0), AppScreenSize.mobile);
      expect(
        AppBreakpoints.screenSizeFor(AppBreakpoints.tablet - 1),
        AppScreenSize.mobile,
      );
    });

    test('classifies widths in [tablet, desktop) as tablet', () {
      expect(
        AppBreakpoints.screenSizeFor(AppBreakpoints.tablet),
        AppScreenSize.tablet,
      );
      expect(
        AppBreakpoints.screenSizeFor(AppBreakpoints.desktop - 1),
        AppScreenSize.tablet,
      );
    });

    test('classifies widths at/above desktop as desktop', () {
      expect(
        AppBreakpoints.screenSizeFor(AppBreakpoints.desktop),
        AppScreenSize.desktop,
      );
      expect(
        AppBreakpoints.screenSizeFor(AppBreakpoints.wide + 1),
        AppScreenSize.desktop,
      );
    });
  });

  group('AppBreakpoints context helpers', () {
    testWidgets('isMobile/isTablet/isDesktop match the current width', (
      tester,
    ) async {
      AppScreenSize? observed;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: Builder(
            builder: (context) {
              observed = AppBreakpoints.screenSizeOf(context);
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  children: [
                    Text('mobile:${AppBreakpoints.isMobile(context)}'),
                    Text('tablet:${AppBreakpoints.isTablet(context)}'),
                    Text('desktop:${AppBreakpoints.isDesktop(context)}'),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(observed, AppScreenSize.desktop);
      expect(find.text('mobile:false'), findsOneWidget);
      expect(find.text('tablet:false'), findsOneWidget);
      expect(find.text('desktop:true'), findsOneWidget);
    });
  });
}
