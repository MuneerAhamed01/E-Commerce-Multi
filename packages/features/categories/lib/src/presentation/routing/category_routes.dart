/// Named path helpers for categories screens (docs/09_ROUTING_PLAN.md).
abstract final class CategoryRoutes {
  static const String browsePath = '/categories';
  static const String browseName = 'CategoryBrowseRoute';

  static const String detailName = 'CategoryDetailRoute';

  static String detailPath(String categoryId) =>
      '$browsePath/${Uri.encodeComponent(categoryId)}';
}
