import 'dart:math';

import 'package:core/core.dart';
import 'package:products/src/data/datasources/mock_products_remote_data_source.dart';
import 'package:products/src/data/repositories/mock_product_repository_impl.dart';
import 'package:products/src/domain/repositories/product_repository.dart';
import 'package:products/src/domain/usecases/get_product_detail.dart';
import 'package:products/src/domain/usecases/get_product_reviews.dart';
import 'package:products/src/domain/usecases/get_products.dart';
import 'package:products/src/domain/usecases/get_related_products.dart';
import 'package:products/src/domain/usecases/submit_product_review.dart';
import 'package:products/src/presentation/bloc/product_detail_bloc.dart';
import 'package:products/src/presentation/bloc/product_list_bloc.dart';
import 'package:products/src/presentation/cubit/reviews_cubit.dart';

final class ProductsTestHarness {
  ProductsTestHarness._({
    required this.controls,
    required this.store,
    required this.repository,
    required this.getProducts,
    required this.getProductDetail,
    required this.getRelatedProducts,
    required this.getProductReviews,
    required this.submitProductReview,
  });

  final MockDeveloperControls controls;
  final MockSeedStore store;
  final ProductRepository repository;
  final GetProducts getProducts;
  final GetProductDetail getProductDetail;
  final GetRelatedProducts getRelatedProducts;
  final GetProductReviews getProductReviews;
  final SubmitProductReview submitProductReview;

  static ProductsTestHarness create() {
    final controls = MockDeveloperControls()..latencyDisabled = true;
    final store = MockSeedStore(controls: controls);
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
    final remote = MockProductsRemoteDataSource(
      simulator: simulator,
      store: store,
      controls: controls,
    );
    final repository = MockProductRepositoryImpl(remote: remote);

    return ProductsTestHarness._(
      controls: controls,
      store: store,
      repository: repository,
      getProducts: GetProducts(repository),
      getProductDetail: GetProductDetail(repository),
      getRelatedProducts: GetRelatedProducts(repository),
      getProductReviews: GetProductReviews(repository),
      submitProductReview: SubmitProductReview(repository),
    );
  }

  ProductListBloc createListBloc() => ProductListBloc(getProducts: getProducts);

  ProductDetailBloc createDetailBloc() => ProductDetailBloc(
    getProductDetail: getProductDetail,
    getRelatedProducts: getRelatedProducts,
  );

  ReviewsCubit createReviewsCubit() => ReviewsCubit(
    getProductReviews: getProductReviews,
    submitProductReview: submitProductReview,
  );
}
