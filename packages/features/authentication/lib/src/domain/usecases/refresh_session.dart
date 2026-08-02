import 'package:core/core.dart';

import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

final class RefreshSession extends UseCase<AuthSession?, NoParams> {
  const RefreshSession(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<Failure, AuthSession?>> call(NoParams params) {
    return _repository.refreshSession();
  }
}
