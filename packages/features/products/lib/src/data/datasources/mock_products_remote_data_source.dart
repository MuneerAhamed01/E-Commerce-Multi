import 'dart:convert';

import 'package:core/core.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/entities/product_page_request.dart';
import '../../domain/entities/review.dart';
import '../mock/product_catalog_builder.dart';
import '../mock/products_call_types.dart';
import 'products_remote_data_source.dart';

/// In-memory catalog backed by [MockSeedStore] + synthesized variants/reviews.
final class MockProductsRemoteDataSource
    with MockDataSourceMixin
    implements ProductsRemoteDataSource {
  MockProductsRemoteDataSource({
    required this.simulator,
    required MockSeedStore store,
    required MockDeveloperControls controls,
    // Private fields can't use initializing formals with public param names.
    // ignore: prefer_initializing_formals
  }) : _store = store,
       // ignore: prefer_initializing_formals
       _controls = controls {
    _rebuildCatalog();
    _controls.registerResetListener(_onReset);
  }

  @override
  final MockNetworkSimulator simulator;

  final MockSeedStore _store;
  final MockDeveloperControls _controls;

  late Map<String, Product> _productsById;
  late List<Product> _orderedProducts;
  late Map<String, List<Review>> _reviewsByProductId;
  var _submittedReviewSeq = 0;

  void dispose() {
    _controls.unregisterResetListener(_onReset);
  }

  void _onReset() {
    _rebuildCatalog();
  }

  void _rebuildCatalog() {
    _orderedProducts = _store.products
        .map(ProductCatalogBuilder.fromSeed)
        .toList(growable: false);
    _productsById = {for (final p in _orderedProducts) p.id: p};
    _reviewsByProductId = {
      for (final seed in _store.products)
        seed.id: List<Review>.of(ProductCatalogBuilder.seedReviewsFor(seed)),
    };
    _submittedReviewSeq = 0;
  }

  @override
  Future<PaginatedResult<Product>> fetchProducts({
    required ProductPageRequest page,
    ProductFilter? filter,
  }) {
    return guarded(ProductsCallTypes.list, () async {
      final filtered = _applyFilter(_orderedProducts, filter);
      return _paginate(filtered, page);
    });
  }

  @override
  Future<Product> fetchProductDetail(String productId) {
    return guarded(ProductsCallTypes.detail, () async {
      final product = _productsById[productId];
      if (product == null) {
        throw NotFoundException('Product $productId not found');
      }
      return _withLiveReviewCount(product);
    });
  }

  @override
  Future<PaginatedResult<Product>> fetchRelatedProducts({
    required String productId,
    required ProductPageRequest page,
  }) {
    return guarded(ProductsCallTypes.related, () async {
      final product = _productsById[productId];
      if (product == null) {
        throw NotFoundException('Product $productId not found');
      }
      final related = _orderedProducts
          .where((p) => p.categoryId == product.categoryId && p.id != productId)
          .toList(growable: false);
      return _paginate(related, page);
    });
  }

  @override
  Future<PaginatedResult<Review>> fetchProductReviews({
    required String productId,
    required ProductPageRequest page,
  }) {
    return guarded(ProductsCallTypes.reviews, () async {
      if (!_productsById.containsKey(productId)) {
        throw NotFoundException('Product $productId not found');
      }
      final reviews = List<Review>.of(
        _reviewsByProductId[productId] ?? const [],
      )..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return _paginateList(reviews, page);
    });
  }

  @override
  Future<Review> submitReview({
    required String productId,
    required String userId,
    required String userDisplayName,
    required int rating,
    required String title,
    required String body,
  }) {
    return guarded(ProductsCallTypes.submitReview, () async {
      if (!_productsById.containsKey(productId)) {
        throw NotFoundException('Product $productId not found');
      }
      if (userId.isEmpty) {
        throw const UnauthorizedException('Sign in to submit a review');
      }
      if (rating < 1 || rating > 5) {
        throw const ValidationException({
          'rating': 'Rating must be between 1 and 5',
        }, 'Invalid rating');
      }
      final trimmedTitle = title.trim();
      final trimmedBody = body.trim();
      if (trimmedTitle.isEmpty) {
        throw const ValidationException({
          'title': 'Title is required',
        }, 'Invalid review');
      }
      if (trimmedBody.isEmpty) {
        throw const ValidationException({
          'body': 'Review text is required',
        }, 'Invalid review');
      }

      _submittedReviewSeq += 1;
      final review = Review(
        id: '${productId}_submitted_$_submittedReviewSeq',
        productId: productId,
        userId: userId,
        userDisplayName: userDisplayName,
        rating: rating,
        title: trimmedTitle,
        body: trimmedBody,
        createdAt: DateTime.now().toUtc(),
      );
      final list = _reviewsByProductId.putIfAbsent(productId, () => <Review>[]);
      list.insert(0, review);
      return review;
    });
  }

  Product _withLiveReviewCount(Product product) {
    final reviews = _reviewsByProductId[product.id] ?? const [];
    if (reviews.isEmpty) {
      return product;
    }
    final avg =
        reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    return Product(
      id: product.id,
      name: product.name,
      slug: product.slug,
      description: product.description,
      categoryId: product.categoryId,
      images: product.images,
      variants: product.variants,
      rating: double.parse(avg.toStringAsFixed(1)),
      reviewCount: reviews.length,
      isFeatured: product.isFeatured,
    );
  }

  List<Product> _applyFilter(List<Product> source, ProductFilter? filter) {
    if (filter == null || filter.isEmpty) {
      return source;
    }
    return source
        .where((p) => p.categoryId == filter.categoryId)
        .toList(growable: false);
  }

  PaginatedResult<Product> _paginate(
    List<Product> items,
    ProductPageRequest page,
  ) {
    return _paginateList(items, page);
  }

  PaginatedResult<T> _paginateList<T>(List<T> items, ProductPageRequest page) {
    final start = _decodeCursor(page.cursor);
    if (start < 0 || start > items.length) {
      throw const ValidationException({
        'cursor': 'Invalid page cursor',
      }, 'Invalid cursor');
    }
    final end = (start + page.pageSize).clamp(0, items.length);
    final slice = items.sublist(start, end);
    final next = end < items.length ? _encodeCursor(end) : null;
    return PaginatedResult<T>(
      items: slice,
      nextPageCursor: next,
      totalCount: items.length,
    );
  }

  static String _encodeCursor(int nextIndex) {
    final payload = jsonEncode({'i': nextIndex});
    return base64Url.encode(utf8.encode(payload));
  }

  static int _decodeCursor(String? cursor) {
    if (cursor == null || cursor.isEmpty) {
      return 0;
    }
    try {
      final decoded = utf8.decode(base64Url.decode(cursor));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      return (map['i'] as num).toInt();
    } on Object {
      throw const ValidationException({
        'cursor': 'Invalid page cursor',
      }, 'Invalid cursor');
    }
  }
}
