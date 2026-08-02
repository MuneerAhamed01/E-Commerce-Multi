import '../../domain/entities/auth_session.dart';
import 'user_model.dart';

/// DTO for a persisted auth session (local prefs + mock remote).
///
/// Anticipated Firestore path once backend lands: `sessions/{sessionId}`
/// (or custom token claims); Phase 7 stores JSON in SharedPreferences.
final class AuthSessionModel {
  const AuthSessionModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAtIso,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAtIso: json['expiresAtIso'] as String,
    );
  }

  factory AuthSessionModel.fromEntity(AuthSession session) {
    return AuthSessionModel(
      user: UserModel(
        id: session.user.id,
        email: session.user.email,
        displayName: session.user.displayName,
        role: session.user.role.name,
        phone: session.user.phone,
        isActive: session.user.isActive,
      ),
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      expiresAtIso: session.expiresAt.toUtc().toIso8601String(),
    );
  }

  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final String expiresAtIso;

  AuthSession toEntity() {
    return AuthSession(
      user: user.toEntity(),
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.parse(expiresAtIso).toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAtIso': expiresAtIso,
    };
  }
}
