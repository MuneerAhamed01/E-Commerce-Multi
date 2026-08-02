import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('elevation scale is strictly increasing', () {
    const values = [
      AppElevation.none,
      AppElevation.low,
      AppElevation.medium,
      AppElevation.high,
      AppElevation.highest,
    ];

    for (var i = 1; i < values.length; i++) {
      expect(values[i], greaterThan(values[i - 1]));
    }
  });

  test('none is exactly zero', () {
    expect(AppElevation.none, 0);
  });
}
