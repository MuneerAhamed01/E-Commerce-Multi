import 'package:equatable/equatable.dart';

/// Hierarchical catalog category (self-referential tree via [parentId]/[children]).
final class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.parentId,
    this.sortOrder = 0,
    this.imageUrl = '',
    this.children = const [],
  });

  final String id;
  final String name;
  final String slug;
  final String description;
  final String? parentId;
  final int sortOrder;
  final String imageUrl;
  final List<Category> children;

  bool get hasChildren => children.isNotEmpty;

  bool get isRoot => parentId == null;

  Category copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? parentId,
    int? sortOrder,
    String? imageUrl,
    List<Category>? children,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      imageUrl: imageUrl ?? this.imageUrl,
      children: children ?? this.children,
    );
  }

  /// Depth-first search for [categoryId] within this subtree (inclusive).
  Category? findById(String categoryId) {
    if (id == categoryId) {
      return this;
    }
    for (final child in children) {
      final found = child.findById(categoryId);
      if (found != null) {
        return found;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    description,
    parentId,
    sortOrder,
    imageUrl,
    children,
  ];
}
