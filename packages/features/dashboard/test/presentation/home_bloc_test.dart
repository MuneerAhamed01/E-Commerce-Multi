import 'package:bloc_test/bloc_test.dart';
import 'package:dashboard/dashboard.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/dashboard_test_harness.dart';

void main() {
  late DashboardTestHarness harness;

  setUp(() {
    harness = DashboardTestHarness.create();
  });

  blocTest<HomeBloc, HomeState>(
    'HomeStarted emits loading then loaded',
    build: () => harness.createHomeBloc(),
    act: (bloc) => bloc.add(const HomeStarted()),
    expect: () => [
      const HomeLoading(),
      isA<HomeLoaded>().having(
        (s) => s.feed.featuredProducts,
        'featuredProducts',
        isNotEmpty,
      ),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'HomeRetried after failure recovers to loaded',
    build: () => harness.createHomeBloc(),
    setUp: () {
      harness.controls.forceFailure('dashboard.homeFeed');
    },
    act: (bloc) async {
      bloc.add(const HomeStarted());
      await bloc.stream.firstWhere((s) => s is HomeError);
      harness.controls.clearAllFailures();
      bloc.add(const HomeRetried());
    },
    expect: () => [
      const HomeLoading(),
      isA<HomeError>(),
      const HomeLoading(),
      isA<HomeLoaded>(),
    ],
  );
}
