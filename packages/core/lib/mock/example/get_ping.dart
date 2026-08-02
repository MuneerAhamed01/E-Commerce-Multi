import '../../error/failure.dart';
import '../../error/result.dart';
import '../../usecase/usecase.dart';
import 'ping_message.dart';
import 'ping_repository.dart';

/// Reference use case: domain → repository only (no data-source access).
final class GetPing extends UseCase<PingMessage, NoParams> {
  const GetPing(this._repository);

  final PingRepository _repository;

  @override
  Future<Result<Failure, PingMessage>> call(NoParams params) =>
      _repository.ping();
}
