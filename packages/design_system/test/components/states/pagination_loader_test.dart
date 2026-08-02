import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('renders a small centered spinner', (tester) async {
    await pumpApp(tester, const AppPaginationLoader());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final sizedBox = tester.widget<SizedBox>(
      find
          .ancestor(
            of: find.byType(CircularProgressIndicator),
            matching: find.byType(SizedBox),
          )
          .first,
    );
    expect(sizedBox.width, 24);
    expect(sizedBox.height, 24);
  });
}
