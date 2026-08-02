import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpAtWidth(
  WidgetTester tester,
  double width,
  Widget child,
) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    Directionality(textDirection: TextDirection.ltr, child: child),
  );
}

void main() {
  testWidgets('renders the mobile builder at narrow widths', (tester) async {
    await _pumpAtWidth(
      tester,
      400,
      AppResponsiveLayoutBuilder(
        mobile: (_, _) => const Text('mobile'),
        tablet: (_, _) => const Text('tablet'),
        desktop: (_, _) => const Text('desktop'),
      ),
    );

    expect(find.text('mobile'), findsOneWidget);
  });

  testWidgets('renders the tablet builder at tablet widths', (tester) async {
    await _pumpAtWidth(
      tester,
      800,
      AppResponsiveLayoutBuilder(
        mobile: (_, _) => const Text('mobile'),
        tablet: (_, _) => const Text('tablet'),
        desktop: (_, _) => const Text('desktop'),
      ),
    );

    expect(find.text('tablet'), findsOneWidget);
  });

  testWidgets('renders the desktop builder at wide widths', (tester) async {
    await _pumpAtWidth(
      tester,
      1200,
      AppResponsiveLayoutBuilder(
        mobile: (_, _) => const Text('mobile'),
        tablet: (_, _) => const Text('tablet'),
        desktop: (_, _) => const Text('desktop'),
      ),
    );

    expect(find.text('desktop'), findsOneWidget);
  });

  testWidgets('falls back to mobile when tablet/desktop builders are omitted', (
    tester,
  ) async {
    await _pumpAtWidth(
      tester,
      1200,
      AppResponsiveLayoutBuilder(mobile: (_, _) => const Text('mobile')),
    );

    expect(find.text('mobile'), findsOneWidget);
  });

  testWidgets(
    'falls back to tablet at desktop widths when desktop is omitted',
    (tester) async {
      await _pumpAtWidth(
        tester,
        1200,
        AppResponsiveLayoutBuilder(
          mobile: (_, _) => const Text('mobile'),
          tablet: (_, _) => const Text('tablet'),
        ),
      );

      expect(find.text('tablet'), findsOneWidget);
    },
  );
}
