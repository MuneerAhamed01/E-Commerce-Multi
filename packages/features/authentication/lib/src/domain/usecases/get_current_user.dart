import 'package:core/core.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

final class GetCurrentUser extends UseCase<User?, NoParams> {
  const GetCurrentUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<Failure, User?>> call(NoParams params) {
    return _repository.getCurrentUser();
  }
}
