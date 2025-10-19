import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardStats extends DashboardEvent {
  const LoadDashboardStats();
}

class RefreshDashboardStats extends DashboardEvent {
  const RefreshDashboardStats();
}
