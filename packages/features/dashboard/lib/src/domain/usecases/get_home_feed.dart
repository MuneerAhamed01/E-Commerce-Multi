import 'package:core/core.dart';

import '../entities/home_feed.dart';
import '../repositories/home_feed_repository.dart';

/// Loads the storefront home aggregate (banners, categories, products).
final class GetHomeFeed extends UseCase<HomeFeed, NoParams> {
  const GetHomeFeed(this._repository);

  final HomeFeedRepository _repository;

  @override
  Future<Result<Failure, HomeFeed>> call(NoParams params) {
    return _repository.getHomeFeed();
  }
}
