import 'package:core/core.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart';
import '../bloc/auth_bloc.dart';

/// Maps feature [AuthSession] / [AuthState] → core [AuthSessionState]
/// for [RouteGuard].
abstract final class AuthSessionMapper {
  static AuthSessionState fromAuthState(AuthState state) {
    return switch (state) {
      AuthAuthenticated(:final session) => fromSession(session),
      _ => const AuthSessionState.guest(),
    };
  }

  static AuthSessionState fromSession(AuthSession session) {
    return AuthSessionState(
      isAuthenticated: true,
      adminPermissions: permissionsForRole(session.user.role),
    );
  }

  /// Pragmatic Phase 7 mapping; Phase 21 replaces with full AdminRole matrix.
  static Set<AdminPermission> permissionsForRole(UserRole role) {
    return switch (role) {
      UserRole.admin => {
        AdminPermission.anyAdmin,
        AdminPermission.catalogManager,
        AdminPermission.orderManager,
        AdminPermission.marketingManager,
        AdminPermission.superAdmin,
      },
      UserRole.support => {
        AdminPermission.anyAdmin,
        AdminPermission.orderManager,
      },
      UserRole.customer => const {},
    };
  }
}
