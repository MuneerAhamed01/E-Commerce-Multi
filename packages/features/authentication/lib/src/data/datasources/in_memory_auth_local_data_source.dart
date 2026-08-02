import '../models/auth_session_model.dart';
import 'auth_local_data_source.dart';

/// Process-local auth persistence for unit tests (no SharedPreferences).
final class InMemoryAuthLocalDataSource implements AuthLocalDataSource {
  AuthSessionModel? _session;
  bool _onboardingSeen = false;

  @override
  Future<AuthSessionModel?> readSession() async => _session;

  @override
  Future<void> writeSession(AuthSessionModel session) async {
    _session = session;
  }

  @override
  Future<void> clearSession() async {
    _session = null;
  }

  @override
  Future<bool> readOnboardingSeen() async => _onboardingSeen;

  @override
  Future<void> writeOnboardingSeen(bool seen) async {
    _onboardingSeen = seen;
  }
}
