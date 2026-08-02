part of 'admin_dashboard_bloc.dart';

sealed class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object?> get props => [];
}

final class AdminDashboardInitial extends AdminDashboardState {
  const AdminDashboardInitial();
}

final class AdminDashboardLoading extends AdminDashboardState {
  const AdminDashboardLoading();
}

final class AdminDashboardLoaded extends AdminDashboardState {
  const AdminDashboardLoaded(this.kpis);

  final DashboardKpiSet kpis;

  @override
  List<Object?> get props => [kpis];
}

final class AdminDashboardError extends AdminDashboardState {
  const AdminDashboardError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
