import 'package:equatable/equatable.dart';

/// Optional filters for [GetProducts].
final class ProductFilter extends Equatable {
  const ProductFilter({this.categoryId});

  final String? categoryId;

  bool get isEmpty => categoryId == null || categoryId!.isEmpty;

  @override
  List<Object?> get props => [categoryId];
}
