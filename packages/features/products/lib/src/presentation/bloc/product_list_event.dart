part of 'product_list_bloc.dart';

sealed class ProductListEvent extends Equatable {
  const ProductListEvent();

  @override
  List<Object?> get props => [];
}

final class ProductListStarted extends ProductListEvent {
  const ProductListStarted({this.categoryId});

  final String? categoryId;

  @override
  List<Object?> get props => [categoryId];
}

final class ProductListRetried extends ProductListEvent {
  const ProductListRetried();
}

final class ProductListLoadMore extends ProductListEvent {
  const ProductListLoadMore();
}

final class ProductListCategoryChanged extends ProductListEvent {
  const ProductListCategoryChanged(this.categoryId);

  final String? categoryId;

  @override
  List<Object?> get props => [categoryId];
}
