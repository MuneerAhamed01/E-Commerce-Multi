import 'package:core/core.dart';

import '../data/datasources/mock_products_remote_data_source.dart';
import '../data/datasources/products_remote_data_source.dart';
import '../data/repositories/mock_product_repository_impl.dart';
import '../domain/repositories/product_repository.dart';
import '../domain/usecases/get_product_detail.dart';
import '../domain/usecases/get_product_reviews.dart';
import '../domain/usecases/get_products.dart';
import '../domain/usecases/get_related_products.dart';
import '../domain/usecases/submit_product_review.dart';
import '../presentation/bloc/product_detail_bloc.dart';
import '../presentation/bloc/product_list_bloc.dart';
import '../presentation/cubit/reviews_cubit.dart';

/// Registers products data/domain/presentation dependencies.
///
/// Call **after** [configureMockInjection] so [MockNetworkSimulator] /
/// [MockSeedStore] exist. Safe to call once per process.
void configureProductsInjection() {
  if (!getIt.isRegistered<MockNetworkSimulator>() ||
      !getIt.isRegistered<MockSeedStore>() ||
      !getIt.isRegistered<MockDeveloperControls>()) {
    throw StateError(
      'configureProductsInjection() requires configureMockInjection() first.',
    );
  }

  if (!getIt.isRegistered<ProductsRemoteDataSource>()) {
    getIt.registerLazySingleton<ProductsRemoteDataSource>(
      () => MockProductsRemoteDataSource(
        simulator: getIt<MockNetworkSimulator>(),
        store: getIt<MockSeedStore>(),
        controls: getIt<MockDeveloperControls>(),
      ),
    );
  }

  if (!getIt.isRegistered<ProductRepository>()) {
    getIt.registerLazySingleton<ProductRepository>(
      () =>
          MockProductRepositoryImpl(remote: getIt<ProductsRemoteDataSource>()),
    );
  }

  _registerFactory<GetProducts>(() => GetProducts(getIt()));
  _registerFactory<GetProductDetail>(() => GetProductDetail(getIt()));
  _registerFactory<GetRelatedProducts>(() => GetRelatedProducts(getIt()));
  _registerFactory<GetProductReviews>(() => GetProductReviews(getIt()));
  _registerFactory<SubmitProductReview>(() => SubmitProductReview(getIt()));

  _registerFactory<ProductListBloc>(
    () => ProductListBloc(getProducts: getIt()),
  );
  _registerFactory<ProductDetailBloc>(
    () => ProductDetailBloc(
      getProductDetail: getIt(),
      getRelatedProducts: getIt(),
    ),
  );
  _registerFactory<ReviewsCubit>(
    () =>
        ReviewsCubit(getProductReviews: getIt(), submitProductReview: getIt()),
  );
}

void _registerFactory<T extends Object>(T Function() factory) {
  if (!getIt.isRegistered<T>()) {
    getIt.registerFactory<T>(factory);
  }
}
