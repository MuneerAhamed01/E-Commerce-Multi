/// Named path helpers for products screens (docs/09_ROUTING_PLAN.md).
abstract final class ProductRoutes {
  static const String listPath = '/products';
  static const String listName = 'ProductListRoute';

  static const String detailName = 'ProductDetailRoute';

  static const String categoryIdQueryKey = 'categoryId';

  static String detailPath(String productId) => '/products/$productId';

  static String listPathWithCategory(String categoryId) =>
      '$listPath?$categoryIdQueryKey=${Uri.encodeQueryComponent(categoryId)}';
}
