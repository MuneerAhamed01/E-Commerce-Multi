import 'package:equatable/equatable.dart';

/// Platform role carried on an authenticated [User].
///
/// Full admin role/permission matrix lands in Phase 21; Phase 7 keeps a
/// pragmatic three-value model mapped from seed `role` strings.
enum UserRole {
  customer,
  admin,
  support;

  /// Parses seed / API role strings (`customer`, `admin`, `support`).
  static UserRole fromSeed(String value) {
    return switch (value.toLowerCase()) {
      'admin' => UserRole.admin,
      'support' => UserRole.support,
      _ => UserRole.customer,
    };
  }

  bool get isAdminLike => this == UserRole.admin || this == UserRole.support;
}

/// Authenticated account identity (docs/04_FEATURE_IMPLEMENTATION_ORDER.md §1).
final class User extends Equatable {
  const User({
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
  final UserRole role;
  final String phone;
  final bool isActive;

  @override
  List<Object?> get props => [id, email, displayName, role, phone, isActive];
}
