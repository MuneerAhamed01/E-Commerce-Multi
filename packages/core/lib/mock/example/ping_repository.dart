import '../../error/failure.dart';
import '../../error/result.dart';
import 'ping_message.dart';

/// Domain repository contract for the reference ping feature.
abstract interface class PingRepository {
  Future<Result<Failure, PingMessage>> ping();
}
