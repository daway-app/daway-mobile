import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/usecases/get_pharmacy_dashboard_stats_usecase.dart';
import 'pharmacy_dashboard_state.dart';

class PharmacyDashboardCubit extends Cubit<PharmacyDashboardState> {
  final GetPharmacyDashboardStatsUseCase _getPharmacyDashboardStatsUseCase;

  PharmacyDashboardCubit(this._getPharmacyDashboardStatsUseCase)
      : super(const PharmacyDashboardLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const PharmacyDashboardLoading());
    final result = await _getPharmacyDashboardStatsUseCase();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(PharmacyDashboardLoaded(data));
      case ApiError(:final failure):
        emit(PharmacyDashboardLoadFailure(failure.message));
    }
  }

  /// Fetches the figures again without going back to the loading state: what
  /// is on screen stays until the new figures arrive, and stays if the fetch
  /// fails. With nothing on screen yet, a load already on its way is left to
  /// finish, and a failed one is retried.
  Future<void> refresh() async {
    final current = state;
    if (current is PharmacyDashboardLoading) return;
    if (current is PharmacyDashboardLoadFailure) return load();

    final result = await _getPharmacyDashboardStatsUseCase();
    if (isClosed) return;
    if (result case Success(:final data)) emit(PharmacyDashboardLoaded(data));
  }
}
