import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

/// Presentation states for the Phase 6 reference ping demo.
sealed class PingState extends Equatable {
  const PingState();

  @override
  List<Object?> get props => [];
}

final class PingInitial extends PingState {
  const PingInitial();
}

final class PingLoading extends PingState {
  const PingLoading();
}

final class PingLoaded extends PingState {
  const PingLoaded(this.message);

  final PingMessage message;

  @override
  List<Object?> get props => [message];
}

final class PingError extends PingState {
  const PingError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Cubit that exercises domain → mock → repository → use case → UI
/// (docs/03_DEVELOPMENT_PHASES.md Phase 6 completion criteria).
final class PingCubit extends Cubit<PingState> {
  PingCubit(this._getPing) : super(const PingInitial());

  final GetPing _getPing;

  Future<void> ping() async {
    emit(const PingLoading());
    final result = await _getPing(const NoParams());
    result.fold(
      onFailure: (failure) => emit(PingError(failure)),
      onSuccess: (message) => emit(PingLoaded(message)),
    );
  }
}
