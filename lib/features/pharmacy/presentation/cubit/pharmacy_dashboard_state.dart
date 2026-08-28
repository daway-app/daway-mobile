import '../../domain/entities/pharmacy_dashboard_stats.dart';

sealed class PharmacyDashboardState {
  const PharmacyDashboardState();
}

class PharmacyDashboardLoading extends PharmacyDashboardState {
  const PharmacyDashboardLoading();
}

class PharmacyDashboardLoadFailure extends PharmacyDashboardState {
  final String message;

  const PharmacyDashboardLoadFailure(this.message);
}

class PharmacyDashboardLoaded extends PharmacyDashboardState {
  final PharmacyDashboardStats stats;

  const PharmacyDashboardLoaded(this.stats);
}
