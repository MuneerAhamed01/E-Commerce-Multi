import 'package:equatable/equatable.dart';

import 'category.dart';

/// A category with its ancestor chain for breadcrumb navigation.
///
/// [ancestors] is ordered root-first and excludes [category] itself.
final class CategoryDetail extends Equatable {
  const CategoryDetail({required this.category, this.ancestors = const []});

  final Category category;
  final List<Category> ancestors;

  /// Root-first path including the current category (for breadcrumbs).
  List<Category> get path => [...ancestors, category];

  @override
  List<Object?> get props => [category, ancestors];
}
