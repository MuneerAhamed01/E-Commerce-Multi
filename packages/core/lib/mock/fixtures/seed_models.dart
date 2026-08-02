import 'package:equatable/equatable.dart';

import '../../shared_entities/address.dart';
import '../../shared_entities/money.dart';

/// Shared seed models for Phase 6 fixtures.
///
/// These are **not** feature-owned domain entities — they are a canonical
/// cross-feature seed set that future feature mock stores import and map
/// into their own DTOs/entities. When ownership splits (e.g. products own
/// product fixtures), migrate the relevant lists into
/// `packages/features/*/lib/src/data/mock/` and keep this package as a
/// thin re-export or delete it. See the README comment in this folder.

/// Catalog category fixture.
final class SeedCategory extends Equatable {
  const SeedCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.parentId,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String slug;
  final String description;
  final String? parentId;
  final int sortOrder;

  @override
  List<Object?> get props => [id, name, slug, description, parentId, sortOrder];
}

/// Catalog product fixture sized for pagination demos.
final class SeedProduct extends Equatable {
  const SeedProduct({
    required this.id,
    required this.name,
    required this.slug,
    required this.categoryId,
    required this.description,
    required this.price,
    required this.stock,
    required this.sku,
    this.imageUrl = '',
    this.isFeatured = false,
    this.rating = 4.5,
    this.reviewCount = 0,
  });

  final String id;
  final String name;
  final String slug;
  final String categoryId;
  final String description;
  final Money price;
  final int stock;
  final String sku;
  final String imageUrl;
  final bool isFeatured;
  final double rating;
  final int reviewCount;

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    categoryId,
    description,
    price,
    stock,
    sku,
    imageUrl,
    isFeatured,
    rating,
    reviewCount,
  ];
}

/// Customer / admin user fixture.
final class SeedUser extends Equatable {
  const SeedUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.phone = '',
    this.isActive = true,
  });

  final String id;
  final String email;
  final String displayName;

  /// `'customer'`, `'admin'`, or `'support'`.
  final String role;
  final String phone;
  final bool isActive;

  @override
  List<Object?> get props => [id, email, displayName, role, phone, isActive];
}

/// Order line fixture.
final class SeedOrderItem extends Equatable {
  const SeedOrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final String productName;
  final int quantity;
  final Money unitPrice;

  Money get lineTotal => unitPrice * quantity;

  @override
  List<Object?> get props => [productId, productName, quantity, unitPrice];
}

/// Sample order fixture for list/pagination demos.
final class SeedOrder extends Equatable {
  const SeedOrder({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.status,
    required this.createdAtIso,
    required this.items,
    required this.shippingAddress,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
  });

  final String id;
  final String orderNumber;
  final String customerId;

  /// `'pending'`, `'paid'`, `'shipped'`, `'delivered'`, `'cancelled'`.
  final String status;
  final String createdAtIso;
  final List<SeedOrderItem> items;
  final Address shippingAddress;
  final Money subtotal;
  final Money shipping;
  final Money tax;
  final Money total;

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    customerId,
    status,
    createdAtIso,
    items,
    shippingAddress,
    subtotal,
    shipping,
    tax,
    total,
  ];
}
