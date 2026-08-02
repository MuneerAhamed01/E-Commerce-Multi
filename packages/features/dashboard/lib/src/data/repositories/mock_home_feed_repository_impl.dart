import 'package:core/core.dart';

import '../../domain/entities/home_feed.dart';
import '../../domain/repositories/home_feed_repository.dart';
import '../datasources/banner_source.dart';
import '../datasources/home_catalog_gateway.dart';
import '../mock/dashboard_call_types.dart';

/// Composes banner + catalog gateways into [HomeFeed].
final class MockHomeFeedRepositoryImpl implements HomeFeedRepository {
  MockHomeFeedRepositoryImpl({
    required BannerSource bannerSource,
    required HomeCatalogGateway catalogGateway,
    required MockNetworkSimulator simulator,
  }) : _bannerSource = bannerSource, // ignore: prefer_initializing_formals
       _catalogGateway = catalogGateway, // ignore: prefer_initializing_formals
       _simulator = simulator; // ignore: prefer_initializing_formals

  final BannerSource _bannerSource;
  final HomeCatalogGateway _catalogGateway;
  final MockNetworkSimulator _simulator;

  @override
  Future<Result<Failure, HomeFeed>> getHomeFeed() {
    return _guard(() async {
      // One outer call for the aggregate so the Developer Panel can fail the
      // whole home load; inner sources still honor their own latency.
      await _simulator.run(DashboardCallTypes.homeFeed, () {});
      final banners = await _bannerSource.fetchBanners();
      final categories = await _catalogGateway.fetchFeaturedCategories();
      final products = await _catalogGateway.fetchFeaturedProducts();
      return HomeFeed(
        banners: banners,
        featuredCategories: categories,
        featuredProducts: products,
      );
    });
  }

  Future<Result<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Result.failure(UnauthorizedFailure(message: e.message));
    } on ValidationException catch (e) {
      return Result.failure(
        ValidationFailure(e.fieldErrors, message: e.message),
      );
    } on AppException catch (e) {
      return Result.failure(UnknownFailure(message: e.message));
    } on Object catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}
