/// Contract for a future HTTP client, defined now for interface stability
/// even though nothing implements or registers it yet.
///
/// This plan's mock-data phase never calls a real backend, so no concrete
/// implementation exists in Phase 1/2. It is specified now so that a
/// `Firebase*DataSource`/REST integration later plugs in behind this exact
/// signature without any repository-implementation-facing contract change
/// - see docs/05_ARCHITECTURE_GUIDELINES.md §18.
abstract class ApiClient {
  /// Performs a `GET` request to [path] with optional [queryParameters].
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParameters,
  });

  /// Performs a `POST` request to [path] with an optional JSON-encodable
  /// [body].
  Future<Map<String, dynamic>> post(String path, {Object? body});

  /// Performs a `PUT` request to [path] with an optional JSON-encodable
  /// [body].
  Future<Map<String, dynamic>> put(String path, {Object? body});

  /// Performs a `DELETE` request to [path].
  Future<Map<String, dynamic>> delete(String path);
}
