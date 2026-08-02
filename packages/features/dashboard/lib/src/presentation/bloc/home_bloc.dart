import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/home_feed.dart';
import '../../domain/usecases/get_home_feed.dart';

part 'home_event.dart';
part 'home_state.dart';

/// Loads and refreshes the storefront [HomeFeed].
final class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required this.getHomeFeed}) : super(const HomeInitial()) {
    on<HomeStarted>(_onLoad);
    on<HomeRetried>(_onLoad);
  }

  final GetHomeFeed getHomeFeed;

  Future<void> _onLoad(HomeEvent event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    final result = await getHomeFeed(const NoParams());
    result.fold(
      onFailure: (failure) => emit(HomeError(_mapFailure(failure))),
      onSuccess: (feed) => emit(HomeLoaded(feed)),
    );
  }

  String _mapFailure(Failure failure) {
    return failure.message ??
        'Unable to load home right now. Please try again.';
  }
}
