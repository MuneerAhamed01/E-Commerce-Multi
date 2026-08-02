import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

enum _Sort { priceLowToHigh, newest }

void main() {
  testWidgets('shows every sort option label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => AppSortBottomSheet.show<_Sort>(
              context,
              options: const [
                AppSortOption(
                  value: _Sort.priceLowToHigh,
                  label: 'Price: Low to High',
                ),
                AppSortOption(value: _Sort.newest, label: 'Newest'),
              ],
              selected: _Sort.newest,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Price: Low to High'), findsOneWidget);
    expect(find.text('Newest'), findsOneWidget);
  });

  testWidgets('resolves to the tapped option\'s value', (tester) async {
    _Sort? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await AppSortBottomSheet.show<_Sort>(
                context,
                options: const [
                  AppSortOption(
                    value: _Sort.priceLowToHigh,
                    label: 'Price: Low to High',
                  ),
                  AppSortOption(value: _Sort.newest, label: 'Newest'),
                ],
                selected: _Sort.newest,
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Price: Low to High'));
    await tester.pumpAndSettle();

    expect(result, _Sort.priceLowToHigh);
  });
}
