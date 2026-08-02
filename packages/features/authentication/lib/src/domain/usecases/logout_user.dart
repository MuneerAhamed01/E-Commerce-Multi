import 'package:core/core.dart';

import '../repositories/auth_repository.dart';

final class LogoutUser extends UseCase<void, NoParams> {
  const LogoutUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<Failure, void>> call(NoParams params) => _repository.logout();
}
