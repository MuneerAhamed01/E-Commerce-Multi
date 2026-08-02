import 'ping_message.dart';

/// Remote-shaped contract for the reference ping feature.
///
/// A future Firebase/REST implementation would satisfy the same interface
/// without changing the repository or use case above it
/// (docs/10_DATA_FLOW.md §1).
abstract interface class PingRemoteDataSource {
  Future<PingMessage> fetchPing();
}
