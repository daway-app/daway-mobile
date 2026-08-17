import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/patient_profile.dart';
import '../../domain/entities/picked_location.dart';
import '../../domain/usecases/get_patient_profile_usecase.dart';
import '../../domain/usecases/update_patient_profile_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';
import 'patient_profile_state.dart';

class PatientProfileCubit extends Cubit<PatientProfileState> {
  final GetPatientProfileUseCase _getPatientProfileUseCase;
  final UpdatePatientProfileUseCase _updatePatientProfileUseCase;
  final UploadAvatarUseCase _uploadAvatarUseCase;

  PatientProfileCubit(
    this._getPatientProfileUseCase,
    this._updatePatientProfileUseCase,
    this._uploadAvatarUseCase,
  ) : super(const PatientProfileLoading()) {
    load();
  }

  // Bumped by toggleEdit() so an in-flight save()/avatarSelected() that
  // finishes after the user has already cancelled or re-entered edit mode
  // can tell its result is stale and discard it instead of resurrecting a
  // discarded edit.
  int _editSession = 0;

  Future<void> load() async {
    emit(const PatientProfileLoading());
    final result = await _getPatientProfileUseCase();
    switch (result) {
      case Success(:final data):
        emit(PatientProfileLoaded.fromProfile(data));
      case ApiError(:final failure):
        emit(PatientProfileLoadFailure(failure.message));
    }
  }

  /// Enters edit mode, or — if already editing — discards the in-progress
  /// edits and reverts to the last saved profile.
  void toggleEdit() {
    final current = state;
    if (current is! PatientProfileLoaded) return;
    _editSession++;
    emit(
      current.isEditing
          ? PatientProfileLoaded.fromProfile(current.profile)
          : current.copyWith(isEditing: true),
    );
  }

  void nameChanged(String value) {
    final current = state;
    if (current is! PatientProfileLoaded) return;
    emit(current.copyWith(name: value, clearSaveError: true));
  }

  void locationSelected(PickedLocation location) {
    final current = state;
    if (current is! PatientProfileLoaded) return;
    emit(current.copyWith(
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
      clearSaveError: true,
    ));
  }

  Future<void> avatarSelected(File imageFile) async {
    final current = state;
    if (current is! PatientProfileLoaded) return;
    final session = _editSession;

    emit(current.copyWith(
      avatarLocalPath: imageFile.path,
      isUploadingAvatar: true,
      clearAvatarError: true,
      clearSaveError: true,
    ));

    final result = await _uploadAvatarUseCase(imageFile);
    if (session != _editSession) return;
    final latest = state;
    if (latest is! PatientProfileLoaded) return;

    switch (result) {
      case Success(:final data):
        emit(latest.copyWith(avatarUrl: data, isUploadingAvatar: false));
      case ApiError(:final failure):
        emit(latest.copyWith(isUploadingAvatar: false, avatarError: failure.message));
    }
  }

  Future<void> save() async {
    final current = state;
    if (current is! PatientProfileLoaded || !current.canSave) return;
    final session = _editSession;

    emit(current.copyWith(isSaving: true, clearSaveError: true));

    final updated = PatientProfile(
      name: current.name.trim(),
      phone: current.profile.phone,
      avatarUrl: current.avatarUrl,
      birthDate: current.profile.birthDate,
      latitude: current.latitude,
      longitude: current.longitude,
      address: current.address,
    );

    final result = await _updatePatientProfileUseCase(updated);
    if (session != _editSession) return;

    switch (result) {
      case Success():
        emit(PatientProfileLoaded.fromProfile(updated));
      case ApiError(:final failure):
        emit(current.copyWith(isSaving: false, saveError: failure.message));
    }
  }
}
