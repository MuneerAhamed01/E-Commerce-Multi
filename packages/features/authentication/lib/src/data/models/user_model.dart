import 'package:core/core.dart';

import '../../domain/entities/user.dart';

/// DTO mirroring the planned Firestore `users/{userId}` document.
///
/// Anticipated fields: `email`, `displayName`, `phone`, `role`, `isActive`.
final class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.phone = '',
    this.isActive = true,
  });

  factory UserModel.fromSeed(SeedUser seed) {
    return UserModel(
      id: seed.id,
      email: seed.email,
      displayName: seed.displayName,
      role: seed.role,
      phone: seed.phone,
      isActive: seed.isActive,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  final String id;
  final String email;
  final String displayName;
  final String role;
  final String phone;
  final bool isActive;

  User toEntity() {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      role: UserRole.fromSeed(role),
      phone: phone,
      isActive: isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role,
      'phone': phone,
      'isActive': isActive,
    };
  }
}
