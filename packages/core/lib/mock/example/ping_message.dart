import 'package:equatable/equatable.dart';

/// Domain entity returned by the Phase 6 reference "ping" feature.
///
/// Documents the canonical stack end-to-end without inventing a business
/// feature package (docs/03_DEVELOPMENT_PHASES.md Phase 6 completion
/// criteria).
final class PingMessage extends Equatable {
  const PingMessage({
    required this.message,
    required this.productCount,
    required this.servedAtIso,
  });

  final String message;
  final int productCount;
  final String servedAtIso;

  @override
  List<Object?> get props => [message, productCount, servedAtIso];
}
