import 'package:equatable/equatable.dart';

/// A customer product review.
final class Review extends Equatable {
  const Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userDisplayName,
    required this.rating,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String productId;
  final String userId;
  final String userDisplayName;

  /// Integer stars 1–5.
  final int rating;
  final String title;
  final String body;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    productId,
    userId,
    userDisplayName,
    rating,
    title,
    body,
    createdAt,
  ];
}
