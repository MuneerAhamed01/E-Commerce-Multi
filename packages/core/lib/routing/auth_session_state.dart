import 'package:equatable/equatable.dart';

import 'admin_permission.dart';

/// Snapshot of the current auth session used by [RouteGuard].
///
/// Phase 5 ships an always-guest default ([AuthSessionState.guest]). Phase 7
/// (Authentication) / Phase 21 (Admin Foundation) replace the producer of
/// this snapshot — the guard API does not change.
final class AuthSessionState extends Equatable {
  const AuthSessionState({
    required this.isAuthenticated,
    this.adminPermissions = const {},
  });

  /// Unauthenticated visitor — the Phase 5 default until auth lands.
  const AuthSessionState.guest()
    : isAuthenticated = false,
      adminPermissions = const {};

  final bool isAuthenticated;

  /// Empty for customer sessions; admin sessions carry the permission tags
  /// their role grants (docs/09_ROUTING_PLAN.md §3.2).
  final Set<AdminPermission> adminPermissions;

  bool hasPermission(AdminPermission permission) {
    if (permission == AdminPermission.anyAdmin) {
      return isAuthenticated && adminPermissions.isNotEmpty;
    }
    return adminPermissions.contains(permission);
  }

  @override
  List<Object?> get props => [isAuthenticated, adminPermissions];
}
