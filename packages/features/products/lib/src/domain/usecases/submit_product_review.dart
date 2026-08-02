import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/review.dart';
import '../repositories/product_repository.dart';

final class SubmitProductReview
    extends UseCase<Review, SubmitProductReviewParams> {
  const SubmitProductReview(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<Failure, Review>> call(SubmitProductReviewParams params) {
    return _repository.submitReview(
      productId: params.productId,
      userId: params.userId,
      userDisplayName: params.userDisplayName,
      rating: params.rating,
      title: params.title,
      body: params.body,
    );
  }
}

final class SubmitProductReviewParams extends Equatable {
  const SubmitProductReviewParams({
    required this.productId,
    required this.userId,
    required this.userDisplayName,
    required this.rating,
    required this.title,
    required this.body,
  });

  final String productId;
  final String userId;
  final String userDisplayName;
  final int rating;
  final String title;
  final String body;

  @override
  List<Object?> get props => [
    productId,
    userId,
    userDisplayName,
    rating,
    title,
    body,
  ];
}
