import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('shows the current and total page count', (tester) async {
    await pumpApp(
      tester,
      AppPaginationControl(currentPage: 2, totalPages: 5, onPageChange: (_) {}),
    );

    expect(find.text('Page 2 of 5'), findsOneWidget);
  });

  testWidgets('disables the previous button on the first page', (tester) async {
    await pumpApp(
      tester,
      AppPaginationControl(currentPage: 1, totalPages: 5, onPageChange: (_) {}),
    );

    final prevButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_left),
    );
    expect(prevButton.onPressed, isNull);
  });

  testWidgets('disables the next button on the last page', (tester) async {
    await pumpApp(
      tester,
      AppPaginationControl(currentPage: 5, totalPages: 5, onPageChange: (_) {}),
    );

    final nextButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_right),
    );
    expect(nextButton.onPressed, isNull);
  });

  testWidgets('tapping next/previous reports the adjacent page', (
    tester,
  ) async {
    int? reportedPage;
    await pumpApp(
      tester,
      AppPaginationControl(
        currentPage: 2,
        totalPages: 5,
        onPageChange: (page) => reportedPage = page,
      ),
    );

    await tester.tap(find.byIcon(Icons.chevron_right));
    expect(reportedPage, 3);

    await tester.tap(find.byIcon(Icons.chevron_left));
    expect(reportedPage, 1);
  });

  test('asserts currentPage and totalPages are >= 1', () {
    expect(
      () => AppPaginationControl(
        currentPage: 0,
        totalPages: 5,
        onPageChange: (_) {},
      ),
      throwsAssertionError,
    );
    expect(
      () => AppPaginationControl(
        currentPage: 1,
        totalPages: 0,
        onPageChange: (_) {},
      ),
      throwsAssertionError,
    );
  });
}
