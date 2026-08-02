import 'dart:math';

import 'package:categories/categories.dart';
import 'package:categories/src/data/datasources/mock_categories_remote_data_source.dart';
import 'package:categories/src/data/repositories/mock_category_repository_impl.dart';
import 'package:core/core.dart';
import 'package:products/products.dart';

final class CategoriesTestHarness {
  CategoriesTestHarness._({
    required this.controls,
    required this.store,
    required this.repository,
    required this.getCategoryTree,
    required this.getCategoryDetail,
    required this.getProducts,
  });

  final MockDeveloperControls controls;
  final MockSeedStore store;
  final CategoryRepository repository;
  final GetCategoryTree getCategoryTree;
  final GetCategoryDetail getCategoryDetail;
  final GetProducts getProducts;

  static CategoriesTestHarness create() {
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
    final remote = MockCategoriesRemoteDataSource(
      simulator: simulator,
      store: store,
      controls: controls,
    );
    final repository = MockCategoryRepositoryImpl(remote: remote);

    return CategoriesTestHarness._(
      controls: controls,
      store: store,
      repository: repository,
      getCategoryTree: GetCategoryTree(repository),
      getCategoryDetail: GetCategoryDetail(repository),
      getProducts: GetProducts(_InlineProductRepository(store: store)),
    );
  }

  CategoryTreeCubit createTreeCubit() =>
      CategoryTreeCubit(getCategoryTree: getCategoryTree);

  CategoryDetailCubit createDetailCubit() =>
      CategoryDetailCubit(getCategoryDetail: getCategoryDetail);

  ProductListBloc createListBloc() => ProductListBloc(getProducts: getProducts);
}

/// Minimal [ProductRepository] for category detail widget tests.
final class _InlineProductRepository implements ProductRepository {
  _InlineProductRepository({required this.store});

  final MockSeedStore store;

  @override
  Future<Result<Failure, PaginatedResult<Product>>> getProducts({
    required ProductPageRequest page,
    ProductFilter? filter,
  }) async {
    var items = store.products
        .map(
          (s) => Product(
            id: s.id,
            name: s.name,
            slug: s.slug,
            description: s.description,
            categoryId: s.categoryId,
            images: [
              ProductImage(
                url: s.imageUrl.isEmpty
                    ? 'https://cdn.example.com/products/${s.id}.jpg'
                    : s.imageUrl,
                alt: s.name,
              ),
            ],
            variants: [
              ProductVariant(
                id: '${s.id}_default',
                productId: s.id,
                label: 'Default',
                sku: s.sku,
                price: s.price,
                stock: s.stock,
              ),
            ],
            rating: s.rating,
            reviewCount: s.reviewCount,
            isFeatured: s.isFeatured,
          ),
        )
        .toList();

    final categoryId = filter?.categoryId;
    if (categoryId != null && categoryId.isNotEmpty) {
      items = items.where((p) => p.categoryId == categoryId).toList();
    }

    final start = page.cursor == null ? 0 : (int.tryParse(page.cursor!) ?? 0);
    final end = (start + page.pageSize).clamp(0, items.length);
    final safeStart = start.clamp(0, items.length);
    final slice = items.sublist(safeStart, end);
    final hasNext = end < items.length;

    return Result.success(
      PaginatedResult(
        items: slice,
        nextPageCursor: hasNext ? '$end' : null,
        totalCount: items.length,
      ),
    );
  }

  @override
  Future<Result<Failure, Product>> getProductDetail(String productId) async {
    return const Result.failure(NotFoundFailure(message: 'unused'));
  }

  @override
  Future<Result<Failure, PaginatedResult<Product>>> getRelatedProducts({
    required String productId,
    required ProductPageRequest page,
  }) async {
    return const Result.failure(NotFoundFailure(message: 'unused'));
  }

  @override
  Future<Result<Failure, PaginatedResult<Review>>> getProductReviews({
    required String productId,
    required ProductPageRequest page,
  }) async {
    return const Result.failure(NotFoundFailure(message: 'unused'));
  }

  @override
  Future<Result<Failure, Review>> submitReview({
    required String productId,
    required String userId,
    required String userDisplayName,
    required int rating,
    required String title,
    required String body,
  }) async {
    return const Result.failure(NotFoundFailure(message: 'unused'));
  }
}
