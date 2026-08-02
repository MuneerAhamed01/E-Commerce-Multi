import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppChartDatum equality is based on label and value', () {
    expect(
      const AppChartDatum(label: 'Shoes', value: 12),
      const AppChartDatum(label: 'Shoes', value: 12),
    );
    expect(
      const AppChartDatum(label: 'Shoes', value: 12),
      isNot(const AppChartDatum(label: 'Shoes', value: 13)),
    );
  });

  test('AppChartSeries equality is based on label and values', () {
    expect(
      const AppChartSeries(label: 'Revenue', values: [1, 2, 3]),
      const AppChartSeries(label: 'Revenue', values: [1, 2, 3]),
    );
    expect(
      const AppChartSeries(label: 'Revenue', values: [1, 2, 3]),
      isNot(const AppChartSeries(label: 'Revenue', values: [1, 2])),
    );
  });

  test('AppChartSegment equality is based on label and value', () {
    expect(
      const AppChartSegment(label: 'Shipped', value: 60),
      const AppChartSegment(label: 'Shipped', value: 60),
    );
    expect(
      const AppChartSegment(label: 'Shipped', value: 60),
      isNot(const AppChartSegment(label: 'Processing', value: 60)),
    );
  });
}
