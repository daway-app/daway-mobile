import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../../../core/models/picked_location.dart';
import '../../../patient/domain/usecases/upload_avatar_usecase.dart';
import '../../domain/entities/pharmacy_profile.dart';
import '../../domain/entities/working_hours_entry.dart';
import '../../domain/usecases/get_pharmacy_profile_usecase.dart';
import '../../domain/usecases/update_pharmacy_profile_usecase.dart';
import 'pharmacy_profile_state.dart';

class PharmacyProfileCubit extends Cubit<PharmacyProfileState> {
  final GetPharmacyProfileUseCase _getPharmacyProfileUseCase;
  final UpdatePharmacyProfileUseCase _updatePharmacyProfileUseCase;
  final UploadAvatarUseCase _uploadLogoUseCase;

  PharmacyProfileCubit(
    this._getPharmacyProfileUseCase,
    this._updatePharmacyProfileUseCase,
    this._uploadLogoUseCase,
  ) : super(const PharmacyProfileLoading()) {
    load();
  }

  // Bumped by toggleEdit() so an in-flight save()/logoSelected() that
  // finishes after the user has already cancelled or re-entered edit mode
  // can tell its result is stale and discard it instead of resurrecting a
  // discarded edit.
  int _editSession = 0;

  Future<void> load() async {
    emit(const PharmacyProfileLoading());
    final result = await _getPharmacyProfileUseCase();
    switch (result) {
      case Success(:final data):
        emit(PharmacyProfileLoaded.fromProfile(data));
      case ApiError(:final failure):
        emit(PharmacyProfileLoadFailure(failure.message));
    }
  }

  /// Enters edit mode, or — if already editing — discards the in-progress
  /// edits and reverts to the last saved profile.
  void toggleEdit() {
    final current = state;
    if (current is! PharmacyProfileLoaded) return;
    _editSession++;
    emit(
      current.isEditing
          ? PharmacyProfileLoaded.fromProfile(current.profile)
          : current.copyWith(isEditing: true),
    );
  }

  void nameChanged(String value) {
    final current = state;
    if (current is! PharmacyProfileLoaded) return;
    emit(current.copyWith(name: value, clearSaveError: true));
  }

  void locationSelected(PickedLocation location) {
    final current = state;
    if (current is! PharmacyProfileLoaded) return;
    emit(current.copyWith(
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
      clearSaveError: true,
    ));
  }

  void workingHoursChanged(WeekDay day, {String? open, String? close}) {
    final current = state;
    if (current is! PharmacyProfileLoaded) return;
    final updated = [
      for (final entry in current.workingHours)
        if (entry.day == day) WorkingHoursEntry(day: day, open: open, close: close) else entry,
    ];
    emit(current.copyWith(workingHours: updated, clearSaveError: true));
  }

  Future<void> logoSelected(File imageFile) async {
    final current = state;
    if (current is! PharmacyProfileLoaded) return;
    final session = _editSession;

    emit(current.copyWith(
      logoLocalPath: imageFile.path,
      isUploadingLogo: true,
      clearLogoError: true,
      clearSaveError: true,
    ));

    final result = await _uploadLogoUseCase(imageFile);
    if (session != _editSession) return;
    final latest = state;
    if (latest is! PharmacyProfileLoaded) return;

    switch (result) {
      case Success(:final data):
        emit(latest.copyWith(logoUrl: data, isUploadingLogo: false));
      case ApiError(:final failure):
        emit(latest.copyWith(isUploadingLogo: false, logoError: failure.message));
    }
  }

  Future<void> save() async {
    final current = state;
    if (current is! PharmacyProfileLoaded || !current.canSave) return;
    final session = _editSession;

    emit(current.copyWith(isSaving: true, clearSaveError: true));

    final updated = PharmacyProfile(
      pharmacyId: current.profile.pharmacyId,
      name: current.name.trim(),
      phone: current.profile.phone,
      logoUrl: current.logoUrl,
      latitude: current.latitude,
      longitude: current.longitude,
      address: current.address,
      workingHours: current.workingHours,
    );

    final result = await _updatePharmacyProfileUseCase(updated);
    if (session != _editSession) return;

    switch (result) {
      case Success():
        emit(PharmacyProfileLoaded.fromProfile(updated));
      case ApiError(:final failure):
        emit(current.copyWith(isSaving: false, saveError: failure.message));
    }
  }
}
