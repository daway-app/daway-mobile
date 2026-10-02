import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/usecases/subscribe_availability_alert_usecase.dart';
import 'availability_alert_state.dart';

/// "نبّهني عند التوفر" on a medicine no pharmacy stocks right now.
class AvailabilityAlertCubit extends Cubit<AvailabilityAlertState> {
  final int medicineId;
  final SubscribeAvailabilityAlertUseCase _subscribeUseCase;

  AvailabilityAlertCubit(this.medicineId, this._subscribeUseCase)
      : super(const AvailabilityAlertIdle());

  /// Returns null on success, or a user-facing error message.
  Future<String?> subscribe() async {
    if (state is! AvailabilityAlertIdle) return null;
    emit(const AvailabilityAlertSubscribing());
    final result = await _subscribeUseCase(medicineId);
    if (isClosed) return null;

    switch (result) {
      case Success():
        emit(const AvailabilityAlertSubscribed());
        return null;
      case ApiError(:final failure):
        emit(const AvailabilityAlertIdle());
        return failure.message;
    }
  }
}
