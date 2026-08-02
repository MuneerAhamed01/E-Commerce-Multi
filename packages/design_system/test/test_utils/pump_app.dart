import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [child] wrapped in a minimal [MaterialApp] + [Scaffold], the
/// standard harness every component test in this package uses so widgets
/// that rely on `Theme.of`/`Directionality`/`Navigator` ancestors (buttons,
/// dialogs, bottom sheets, snackbars) work without each test re-deriving
/// this boilerplate.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  ThemeData? theme,
  Size surfaceSize = const Size(800, 1200),
}) async {
  tester.view.physicalSize = surfaceSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(body: child),
    ),
  );
}
