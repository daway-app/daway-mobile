import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/usecases/get_patient_notifications_usecase.dart';
import 'patient_notifications_state.dart';

class PatientNotificationsCubit extends Cubit<PatientNotificationsState> {
  final GetPatientNotificationsUseCase _getPatientNotificationsUseCase;

  PatientNotificationsCubit(this._getPatientNotificationsUseCase)
      : super(const PatientNotificationsLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const PatientNotificationsLoading());
    final result = await _getPatientNotificationsUseCase();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(PatientNotificationsLoaded(data));
      case ApiError(:final failure):
        emit(PatientNotificationsLoadFailure(failure.message));
    }
  }
}
