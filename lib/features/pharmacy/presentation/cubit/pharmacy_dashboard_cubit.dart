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
}
