import 'package:equatable/equatable.dart';

/// A single product gallery image.
final class ProductImage extends Equatable {
  const ProductImage({
    required this.url,
    required this.alt,
    this.sortOrder = 0,
  });

  final String url;
  final String alt;
  final int sortOrder;

  @override
  List<Object?> get props => [url, alt, sortOrder];
}
