import '../../error/exception.dart';
import '../../error/failure.dart';
import '../../error/result.dart';
import 'ping_message.dart';
import 'ping_remote_data_source.dart';
import 'ping_repository.dart';

/// Repository impl that maps data-layer exceptions → [Failure]
/// (docs/10_DATA_FLOW.md §1 — the only place exceptions are caught).
final class MockPingRepository implements PingRepository {
  const MockPingRepository(this._remote);

  final PingRemoteDataSource _remote;

  @override
  Future<Result<Failure, PingMessage>> ping() async {
    try {
      final message = await _remote.fetchPing();
      return Result.success(message);
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Result.failure(UnauthorizedFailure(message: e.message));
    } on ValidationException catch (e) {
      return Result.failure(
        ValidationFailure(e.fieldErrors, message: e.message),
      );
    } on AppException catch (e) {
      return Result.failure(UnknownFailure(message: e.message));
    } on Object catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}
