import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/category_detail.dart';
import '../../domain/usecases/get_category_detail.dart';

part 'category_detail_state.dart';

/// Loads a single category (with children + ancestors) for Detail.
final class CategoryDetailCubit extends Cubit<CategoryDetailState> {
  CategoryDetailCubit({required this.getCategoryDetail})
    : super(const CategoryDetailInitial());

  final GetCategoryDetail getCategoryDetail;

  String? _categoryId;

  Future<void> load(String categoryId) async {
    _categoryId = categoryId;
    emit(const CategoryDetailLoading());
    final result = await getCategoryDetail(GetCategoryDetailParams(categoryId));
    result.fold(
      onFailure: (failure) => emit(
        CategoryDetailError(
          _mapFailure(failure),
          isNotFound: failure is NotFoundFailure,
        ),
      ),
      onSuccess: (detail) => emit(CategoryDetailLoaded(detail)),
    );
  }

  Future<void> retry() async {
    final id = _categoryId;
    if (id == null) {
      return;
    }
    await load(id);
  }

  String _mapFailure(Failure failure) {
    return failure.message ?? 'Something went wrong. Please try again.';
  }
}
