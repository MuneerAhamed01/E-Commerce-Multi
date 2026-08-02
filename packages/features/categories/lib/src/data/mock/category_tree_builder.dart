import 'package:core/core.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/category_detail.dart';

/// Maps flat [SeedCategory] rows into a nested [Category] forest.
abstract final class CategoryTreeBuilder {
  static String imageUrlFor(SeedCategory seed) =>
      'https://cdn.example.com/categories/${seed.slug}.jpg';

  static Category fromSeed(
    SeedCategory seed, {
    List<Category> children = const [],
  }) {
    return Category(
      id: seed.id,
      name: seed.name,
      slug: seed.slug,
      description: seed.description,
      parentId: seed.parentId,
      sortOrder: seed.sortOrder,
      imageUrl: imageUrlFor(seed),
      children: children,
    );
  }

  /// Builds root categories with nested children, sorted by [Category.sortOrder].
  static List<Category> buildTree(Iterable<SeedCategory> seeds) {
    final byParent = <String?, List<SeedCategory>>{};
    for (final seed in seeds) {
      byParent.putIfAbsent(seed.parentId, () => []).add(seed);
    }
    for (final list in byParent.values) {
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    List<Category> buildChildren(String? parentId) {
      final rows = byParent[parentId] ?? const <SeedCategory>[];
      return [
        for (final seed in rows)
          fromSeed(seed, children: buildChildren(seed.id)),
      ];
    }

    return buildChildren(null);
  }

  /// Locates [categoryId] in [roots] and returns detail with ancestors.
  static CategoryDetail? detailFor(List<Category> roots, String categoryId) {
    for (final root in roots) {
      final found = _detailInSubtree(root, categoryId, const []);
      if (found != null) {
        return found;
      }
    }
    return null;
  }

  static CategoryDetail? _detailInSubtree(
    Category node,
    String categoryId,
    List<Category> ancestors,
  ) {
    if (node.id == categoryId) {
      return CategoryDetail(category: node, ancestors: ancestors);
    }
    final nextAncestors = [...ancestors, node.copyWith(children: const [])];
    for (final child in node.children) {
      final found = _detailInSubtree(child, categoryId, nextAncestors);
      if (found != null) {
        return found;
      }
    }
    return null;
  }

  /// Maximum depth of the forest (root depth = 1).
  static int maxDepth(List<Category> roots) {
    var max = 0;
    void walk(Category node, int depth) {
      if (depth > max) {
        max = depth;
      }
      for (final child in node.children) {
        walk(child, depth + 1);
      }
    }

    for (final root in roots) {
      walk(root, 1);
    }
    return max;
  }

  /// Flattens the forest depth-first.
  static List<Category> flatten(List<Category> roots) {
    final out = <Category>[];
    void walk(Category node) {
      out.add(node);
      for (final child in node.children) {
        walk(child);
      }
    }

    for (final root in roots) {
      walk(root);
    }
    return out;
  }
}
