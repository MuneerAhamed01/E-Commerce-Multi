import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders against the default tenant and toggles to Acme', (
    tester,
  ) async {
    // Use pump() (not pumpAndSettle) - AppShimmerPlaceholder runs a
    // looping animation that never settles.
    await tester.pumpWidget(const DesignSystemGallery());
    await tester.pump();

    expect(find.textContaining('White Label Commerce Platform'), findsWidgets);
    expect(find.text('Buttons'), findsOneWidget);

    await tester.tap(find.byTooltip('Switch tenant'));
    await tester.pump();

    expect(find.textContaining('Acme Commerce'), findsWidgets);
  });

  testWidgets('toggles between light and dark themes', (tester) async {
    await tester.pumpWidget(const DesignSystemGallery());
    await tester.pump();

    expect(find.byIcon(Icons.dark_mode), findsOneWidget);

    await tester.tap(find.byTooltip('Switch to dark'));
    await tester.pump();

    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });
}
