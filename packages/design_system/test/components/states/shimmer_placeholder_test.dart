import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('exposes a "Loading" semantic label', (tester) async {
    await pumpApp(
      tester,
      const SizedBox(width: 200, child: AppShimmerPlaceholder()),
    );

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'Loading',
      ),
      findsOneWidget,
    );
  });

  testWidgets('honors explicit width and height overrides', (tester) async {
    await pumpApp(tester, const AppShimmerPlaceholder(width: 96, height: 12));

    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
    expect(sizedBox.width, 96);
    expect(sizedBox.height, 12);
  });

  testWidgets('animates its gradient over time', (tester) async {
    await pumpApp(
      tester,
      const SizedBox(width: 200, child: AppShimmerPlaceholder()),
    );

    final decoratedBoxBefore = tester.widget<DecoratedBox>(
      find.byType(DecoratedBox),
    );
    final gradientBefore =
        (decoratedBoxBefore.decoration as BoxDecoration).gradient
            as LinearGradient;

    await tester.pump(const Duration(milliseconds: 600));

    final decoratedBoxAfter = tester.widget<DecoratedBox>(
      find.byType(DecoratedBox),
    );
    final gradientAfter =
        (decoratedBoxAfter.decoration as BoxDecoration).gradient
            as LinearGradient;

    expect(gradientAfter.begin, isNot(gradientBefore.begin));
  });
}
