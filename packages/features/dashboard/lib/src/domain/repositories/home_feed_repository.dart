import 'package:core/core.dart';

import '../entities/home_feed.dart';

/// Aggregates banners + featured catalog slices for the storefront home.
abstract interface class HomeFeedRepository {
  Future<Result<Failure, HomeFeed>> getHomeFeed();
}
