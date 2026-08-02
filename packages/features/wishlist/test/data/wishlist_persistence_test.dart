import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wishlist/src/data/datasources/mock_wishlist_remote_data_source.dart';
import 'package:wishlist/src/data/repositories/mock_wishlist_repository_impl.dart';
import 'package:wishlist/wishlist.dart';

void main() {
  test(
    'SharedPreferences persistence survives a new data-source instance',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final controls = MockDeveloperControls()..latencyDisabled = true;
      final simulator = MockNetworkSimulator(
        appConfig: const AppConfig(
          environment: Environment.dev,
          dataSourceMode: DataSourceMode.mock,
          logLevel: LogLevel.debug,
          mockLatencyMin: Duration.zero,
          mockLatencyMax: Duration.zero,
          isDeveloperModeAvailable: true,
        ),
        controls: controls,
        random: Random(0),
      );
      final first = MockWishlistRemoteDataSource(
        simulator: simulator,
        preferences: prefs,
        controls: controls,
        clock: () => DateTime.utc(2026, 8, 2, 12),
      );
      final repo = MockWishlistRepositoryImpl(remote: first);
      await AddToWishlist(repo)(
        const AddToWishlistParams(
          userId: 'user_persist',
          productId: 'prod_003',
        ),
      );
      first.dispose();

      final second = MockWishlistRemoteDataSource(
        simulator: simulator,
        preferences: prefs,
        controls: controls,
      );
      final items = await second.fetchWishlist('user_persist');
      expect(items.map((e) => e.productId), contains('prod_003'));
      second.dispose();
    },
  );
}
