part of 'category_detail_cubit.dart';

sealed class CategoryDetailState extends Equatable {
  const CategoryDetailState();

  @override
  List<Object?> get props => [];
}

final class CategoryDetailInitial extends CategoryDetailState {
  const CategoryDetailInitial();
}

final class CategoryDetailLoading extends CategoryDetailState {
  const CategoryDetailLoading();
}

final class CategoryDetailError extends CategoryDetailState {
  const CategoryDetailError(this.message, {this.isNotFound = false});

  final String message;
  final bool isNotFound;

  @override
  List<Object?> get props => [message, isNotFound];
}

final class CategoryDetailLoaded extends CategoryDetailState {
  const CategoryDetailLoaded(this.detail);

  final CategoryDetail detail;

  @override
  List<Object?> get props => [detail];
}
