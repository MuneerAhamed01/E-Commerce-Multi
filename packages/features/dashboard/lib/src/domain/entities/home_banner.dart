import 'package:equatable/equatable.dart';

/// Destination kind for a home banner tap.
enum HomeBannerTargetKind { category, product, external }

/// Promotional banner shown in the storefront home carousel.
final class HomeBanner extends Equatable {
  const HomeBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.targetKind,
    required this.targetId,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final HomeBannerTargetKind targetKind;

  /// Category id, product id, or opaque deep-link token depending on
  /// [targetKind].
  final String targetId;

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    imageUrl,
    targetKind,
    targetId,
  ];
}
