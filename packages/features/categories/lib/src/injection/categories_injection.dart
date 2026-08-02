import 'package:core/core.dart';

import '../data/datasources/categories_remote_data_source.dart';
import '../data/datasources/mock_categories_remote_data_source.dart';
import '../data/repositories/mock_category_repository_impl.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/usecases/get_category_detail.dart';
import '../domain/usecases/get_category_tree.dart';
import '../presentation/cubit/category_detail_cubit.dart';
import '../presentation/cubit/category_tree_cubit.dart';

/// Registers categories data/domain/presentation dependencies.
///
/// Call **after** [configureMockInjection] so [MockNetworkSimulator] /
/// [MockSeedStore] exist. Safe to call once per process.
void configureCategoriesInjection() {
  if (!getIt.isRegistered<MockNetworkSimulator>() ||
      !getIt.isRegistered<MockSeedStore>() ||
      !getIt.isRegistered<MockDeveloperControls>()) {
    throw StateError(
      'configureCategoriesInjection() requires configureMockInjection() first.',
    );
  }

  if (!getIt.isRegistered<CategoriesRemoteDataSource>()) {
    getIt.registerLazySingleton<CategoriesRemoteDataSource>(
      () => MockCategoriesRemoteDataSource(
        simulator: getIt<MockNetworkSimulator>(),
        store: getIt<MockSeedStore>(),
        controls: getIt<MockDeveloperControls>(),
      ),
    );
  }

  if (!getIt.isRegistered<CategoryRepository>()) {
    getIt.registerLazySingleton<CategoryRepository>(
      () => MockCategoryRepositoryImpl(
        remote: getIt<CategoriesRemoteDataSource>(),
      ),
    );
  }

  _registerFactory<GetCategoryTree>(() => GetCategoryTree(getIt()));
  _registerFactory<GetCategoryDetail>(() => GetCategoryDetail(getIt()));

  _registerFactory<CategoryTreeCubit>(
    () => CategoryTreeCubit(getCategoryTree: getIt()),
  );
  _registerFactory<CategoryDetailCubit>(
    () => CategoryDetailCubit(getCategoryDetail: getIt()),
  );
}

void _registerFactory<T extends Object>(T Function() factory) {
  if (!getIt.isRegistered<T>()) {
    getIt.registerFactory<T>(factory);
  }
}
