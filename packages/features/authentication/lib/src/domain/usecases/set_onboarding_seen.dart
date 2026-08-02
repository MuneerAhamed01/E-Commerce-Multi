import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../repositories/auth_repository.dart';

final class SetOnboardingSeen extends UseCase<void, SetOnboardingSeenParams> {
  const SetOnboardingSeen(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<Failure, void>> call(SetOnboardingSeenParams params) {
    return _repository.setOnboardingSeen(seen: params.seen);
  }
}

final class SetOnboardingSeenParams extends Equatable {
  const SetOnboardingSeenParams({required this.seen});

  final bool seen;

  @override
  List<Object?> get props => [seen];
}
