part of 'reviews_cubit.dart';

sealed class ReviewsState extends Equatable {
  const ReviewsState();

  @override
  List<Object?> get props => [];
}

final class ReviewsInitial extends ReviewsState {
  const ReviewsInitial();
}

final class ReviewsLoading extends ReviewsState {
  const ReviewsLoading();
}

final class ReviewsLoaded extends ReviewsState {
  const ReviewsLoaded({
    required this.reviews,
    required this.averageRating,
    this.isSubmitting = false,
    this.submitError,
    this.submitSucceeded = false,
  });

  final List<Review> reviews;
  final double averageRating;
  final bool isSubmitting;
  final String? submitError;
  final bool submitSucceeded;

  ReviewsLoaded copyWith({
    List<Review>? reviews,
    double? averageRating,
    bool? isSubmitting,
    String? submitError,
    bool? submitSucceeded,
    bool clearSubmitError = false,
  }) {
    return ReviewsLoaded(
      reviews: reviews ?? this.reviews,
      averageRating: averageRating ?? this.averageRating,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      submitSucceeded: submitSucceeded ?? this.submitSucceeded,
    );
  }

  @override
  List<Object?> get props => [
    reviews,
    averageRating,
    isSubmitting,
    submitError,
    submitSucceeded,
  ];
}

final class ReviewsError extends ReviewsState {
  const ReviewsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
