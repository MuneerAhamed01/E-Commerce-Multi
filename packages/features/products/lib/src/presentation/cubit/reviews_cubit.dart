import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product_page_request.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/get_product_reviews.dart';
import '../../domain/usecases/submit_product_review.dart';

part 'reviews_state.dart';

/// Loads and submits reviews for a single product.
final class ReviewsCubit extends Cubit<ReviewsState> {
  ReviewsCubit({
    required this.getProductReviews,
    required this.submitProductReview,
  }) : super(const ReviewsInitial());

  final GetProductReviews getProductReviews;
  final SubmitProductReview submitProductReview;

  String? _productId;

  Future<void> load(String productId) async {
    _productId = productId;
    emit(const ReviewsLoading());
    final result = await getProductReviews(
      GetProductReviewsParams(
        productId: productId,
        page: const ProductPageRequest(pageSize: 50),
      ),
    );
    result.fold(
      onFailure: (failure) => emit(ReviewsError(_mapFailure(failure))),
      onSuccess: (page) => emit(
        ReviewsLoaded(reviews: page.items, averageRating: _average(page.items)),
      ),
    );
  }

  Future<void> submit({
    required String userId,
    required String userDisplayName,
    required int rating,
    required String title,
    required String body,
  }) async {
    final productId = _productId;
    final current = state;
    if (productId == null) {
      return;
    }
    if (current is! ReviewsLoaded) {
      return;
    }

    emit(current.copyWith(isSubmitting: true, clearSubmitError: true));
    final result = await submitProductReview(
      SubmitProductReviewParams(
        productId: productId,
        userId: userId,
        userDisplayName: userDisplayName,
        rating: rating,
        title: title,
        body: body,
      ),
    );
    result.fold(
      onFailure: (failure) => emit(
        current.copyWith(
          isSubmitting: false,
          submitError: _mapFailure(failure),
        ),
      ),
      onSuccess: (review) {
        final updated = [review, ...current.reviews];
        emit(
          ReviewsLoaded(
            reviews: updated,
            averageRating: _average(updated),
            submitSucceeded: true,
          ),
        );
      },
    );
  }

  void clearSubmitSucceeded() {
    final current = state;
    if (current is ReviewsLoaded && current.submitSucceeded) {
      emit(current.copyWith(submitSucceeded: false));
    }
  }

  double _average(List<Review> reviews) {
    if (reviews.isEmpty) {
      return 0;
    }
    final sum = reviews.fold<int>(0, (acc, r) => acc + r.rating);
    return double.parse((sum / reviews.length).toStringAsFixed(1));
  }

  String _mapFailure(Failure failure) {
    return failure.message ?? 'Unable to load reviews. Please try again.';
  }
}
