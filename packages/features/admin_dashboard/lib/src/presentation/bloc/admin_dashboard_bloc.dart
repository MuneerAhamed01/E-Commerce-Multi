import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/dashboard_kpi_set.dart';
import '../../domain/usecases/get_dashboard_kpis.dart';

part 'admin_dashboard_event.dart';
part 'admin_dashboard_state.dart';

/// Loads admin KPI aggregate for the dashboard shell.
final class AdminDashboardBloc
    extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  AdminDashboardBloc({required this.getDashboardKpis})
    : super(const AdminDashboardInitial()) {
    on<AdminDashboardStarted>(_onLoad);
    on<AdminDashboardRetried>(_onLoad);
  }

  final GetDashboardKpis getDashboardKpis;

  Future<void> _onLoad(
    AdminDashboardEvent event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(const AdminDashboardLoading());
    final result = await getDashboardKpis(const NoParams());
    result.fold(
      onFailure: (failure) => emit(AdminDashboardError(_mapFailure(failure))),
      onSuccess: (kpis) => emit(AdminDashboardLoaded(kpis)),
    );
  }

  String _mapFailure(Failure failure) {
    return failure.message ??
        'Unable to load dashboard metrics. Please try again.';
  }
}
