import 'package:core/core.dart';

import '../repositories/auth_repository.dart';

final class GetOnboardingSeen extends UseCase<bool, NoParams> {
  const GetOnboardingSeen(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<Failure, bool>> call(NoParams params) {
    return _repository.getOnboardingSeen();
  }
}
