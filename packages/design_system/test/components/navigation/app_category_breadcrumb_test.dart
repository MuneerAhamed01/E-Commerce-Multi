import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('shows every path segment', (tester) async {
    await pumpApp(
      tester,
      AppCategoryBreadcrumb(
        path: const ['Home', 'Electronics', 'Laptops'],
        onSegmentTap: (_) {},
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Electronics'), findsOneWidget);
    expect(find.text('Laptops'), findsOneWidget);
  });

  testWidgets(
    'tapping a non-last segment invokes onSegmentTap with its index',
    (tester) async {
      int? tappedIndex;
      await pumpApp(
        tester,
        AppCategoryBreadcrumb(
          path: const ['Home', 'Electronics', 'Laptops'],
          onSegmentTap: (i) => tappedIndex = i,
        ),
      );

      await tester.tap(find.text('Electronics'));
      expect(tappedIndex, 1);
    },
  );
}
