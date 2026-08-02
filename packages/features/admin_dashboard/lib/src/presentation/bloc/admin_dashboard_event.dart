part of 'admin_dashboard_bloc.dart';

sealed class AdminDashboardEvent extends Equatable {
  const AdminDashboardEvent();

  @override
  List<Object?> get props => [];
}

final class AdminDashboardStarted extends AdminDashboardEvent {
  const AdminDashboardStarted();
}

final class AdminDashboardRetried extends AdminDashboardEvent {
  const AdminDashboardRetried();
}
