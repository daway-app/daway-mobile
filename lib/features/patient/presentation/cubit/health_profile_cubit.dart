import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/patient_health_profile.dart';
import '../../domain/usecases/health_profile_usecases.dart';
import 'health_profile_state.dart';

class HealthProfileCubit extends Cubit<HealthProfileState> {
  final GetHealthProfileUseCase _getUseCase;
  final UpdateHealthProfileUseCase _updateUseCase;

  HealthProfileCubit(this._getUseCase, this._updateUseCase)
      : super(const HealthProfileLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const HealthProfileLoading());
    final result = await _getUseCase();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(_fromProfile(data));
      case ApiError(:final failure):
        emit(HealthProfileLoadFailure(failure.message));
    }
  }

  HealthProfileLoaded _fromProfile(PatientHealthProfile profile) => HealthProfileLoaded(
        allergies: profile.allergies,
        chronicDiseases: profile.chronicDiseases,
        bloodType: profile.bloodType,
        notes: profile.notes,
      );

  /// Adds [value] (trimmed, ignoring blanks and duplicates) to the allergies.
  void addAllergy(String value) {
    final current = state;
    if (current is! HealthProfileLoaded) return;
    final updated = _added(current.allergies, value);
    if (updated != null) emit(current.copyWith(allergies: updated));
  }

  void removeAllergy(String value) {
    final current = state;
    if (current is! HealthProfileLoaded) return;
    emit(current.copyWith(allergies: [...current.allergies]..remove(value)));
  }

  void addChronicDisease(String value) {
    final current = state;
    if (current is! HealthProfileLoaded) return;
    final updated = _added(current.chronicDiseases, value);
    if (updated != null) emit(current.copyWith(chronicDiseases: updated));
  }

  void removeChronicDisease(String value) {
    final current = state;
    if (current is! HealthProfileLoaded) return;
    emit(current.copyWith(chronicDiseases: [...current.chronicDiseases]..remove(value)));
  }

  /// Tapping the selected blood type again clears it.
  void selectBloodType(String value) {
    final current = state;
    if (current is! HealthProfileLoaded) return;
    emit(
      current.bloodType == value
          ? current.copyWith(clearBloodType: true)
          : current.copyWith(bloodType: value),
    );
  }

  static List<String>? _added(List<String> list, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || list.contains(trimmed)) return null;
    return [...list, trimmed];
  }

  /// Saves the profile. Returns null on success, or a user-facing error
  /// message (same contract as MedicineDetailCubit.toggleFavorite).
  Future<String?> save(String notes) async {
    final current = state;
    if (current is! HealthProfileLoaded || current.isSaving) return null;

    emit(current.copyWith(isSaving: true));
    final result = await _updateUseCase(
      PatientHealthProfile(
        allergies: current.allergies,
        chronicDiseases: current.chronicDiseases,
        bloodType: current.bloodType,
        notes: notes.trim(),
      ),
    );
    if (isClosed) return null;

    switch (result) {
      case Success(:final data):
        emit(_fromProfile(data));
        return null;
      case ApiError(:final failure):
        emit(current.copyWith(isSaving: false));
        return failure.message;
    }
  }
}
