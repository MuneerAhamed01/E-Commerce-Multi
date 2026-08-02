import 'package:equatable/equatable.dart';

/// A single labeled data point, shared by [AppBarChartCard] and
/// [AppTopProductsTable].
///
/// Deliberately generic (label/value pairs, not a `Product`/`Order`
/// aggregate) - the owning feature (Analytics/Admin Dashboard, added in
/// Phase 8/22) maps its aggregation result into this shape at the
/// presentation boundary, keeping `design_system` free of feature
/// knowledge.
class AppChartDatum extends Equatable {
  const AppChartDatum({required this.label, required this.value});

  final String label;
  final double value;

  @override
  List<Object?> get props => [label, value];
}

/// A single named series of values plotted against shared x-axis labels in
/// an [AppLineChartCard].
class AppChartSeries extends Equatable {
  const AppChartSeries({required this.label, required this.values});

  final String label;
  final List<double> values;

  @override
  List<Object?> get props => [label, values];
}

/// A single proportional slice of an [AppDonutChartCard].
class AppChartSegment extends Equatable {
  const AppChartSegment({required this.label, required this.value});

  final String label;
  final double value;

  @override
  List<Object?> get props => [label, value];
}
