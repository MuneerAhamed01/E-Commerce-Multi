import 'package:core/core.dart';

import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Cold-start session restore from local persistence.
final class RestoreSession extends UseCase<AuthSession?, NoParams> {
  const RestoreSession(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<Failure, AuthSession?>> call(NoParams params) {
    return _repository.restoreSession();
  }
}
