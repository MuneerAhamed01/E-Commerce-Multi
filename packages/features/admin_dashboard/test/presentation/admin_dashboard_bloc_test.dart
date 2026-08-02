import 'package:admin_dashboard/admin_dashboard.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/admin_dashboard_test_harness.dart';

void main() {
  late AdminDashboardTestHarness harness;

  setUp(() {
    harness = AdminDashboardTestHarness.create();
  });

  blocTest<AdminDashboardBloc, AdminDashboardState>(
    'AdminDashboardStarted emits loading then loaded',
    build: () => harness.createBloc(),
    act: (bloc) => bloc.add(const AdminDashboardStarted()),
    expect: () => [
      const AdminDashboardLoading(),
      isA<AdminDashboardLoaded>().having(
        (s) => s.kpis.orderCount,
        'orderCount',
        greaterThan(0),
      ),
    ],
  );

  blocTest<AdminDashboardBloc, AdminDashboardState>(
    'forced failure emits error; retry recovers',
    build: () => harness.createBloc(),
    setUp: () {
      harness.controls.forceFailure('admin_dashboard.kpis');
    },
    act: (bloc) async {
      bloc.add(const AdminDashboardStarted());
      await bloc.stream.firstWhere((s) => s is AdminDashboardError);
      harness.controls.clearAllFailures();
      bloc.add(const AdminDashboardRetried());
    },
    expect: () => [
      const AdminDashboardLoading(),
      isA<AdminDashboardError>(),
      const AdminDashboardLoading(),
      isA<AdminDashboardLoaded>(),
    ],
  );
}
