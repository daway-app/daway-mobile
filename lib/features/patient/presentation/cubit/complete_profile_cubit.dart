import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/patient_profile.dart';
import '../../../../core/models/picked_location.dart';
import '../../domain/usecases/update_patient_profile_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';
import 'complete_profile_state.dart';

class CompleteProfileCubit extends Cubit<CompleteProfileState> {
  final UpdatePatientProfileUseCase _updatePatientProfileUseCase;
  final UploadAvatarUseCase _uploadAvatarUseCase;
  final String _defaultAvatarUrl;

  CompleteProfileCubit(
    this._updatePatientProfileUseCase,
    this._uploadAvatarUseCase, {
    required String phone,
    required String defaultAvatarUrl,
  })  : _defaultAvatarUrl = defaultAvatarUrl,
        super(CompleteProfileInitial(CompleteProfileFormData(phone: phone)));

  void nameChanged(String value) {
    emit(CompleteProfileInitial(state.formData.copyWith(name: value)));
  }

  void birthDateChanged(String value) {
    emit(CompleteProfileInitial(state.formData.copyWith(birthDate: value)));
  }

  void locationSelected(PickedLocation location) {
    emit(CompleteProfileInitial(state.formData.copyWith(
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
    )));
  }

  Future<void> avatarSelected(File imageFile) async {
    emit(CompleteProfileInitial(state.formData.copyWith(
      avatarLocalPath: imageFile.path,
      isUploadingAvatar: true,
      clearAvatarError: true,
    )));

    final result = await _uploadAvatarUseCase(imageFile);
    switch (result) {
      case Success(:final data):
        emit(CompleteProfileInitial(state.formData.copyWith(
          avatarUrl: data,
          isUploadingAvatar: false,
        )));
      case ApiError(:final failure):
        emit(CompleteProfileInitial(state.formData.copyWith(
          isUploadingAvatar: false,
          avatarError: failure.message,
        )));
    }
  }

  Future<void> submit() async {
    final formData = state.formData;
    if (!formData.canSubmit) return;

    emit(CompleteProfileLoading(formData));

    final result = await _updatePatientProfileUseCase(PatientProfile(
      name: formData.name.trim(),
      phone: formData.phone,
      avatarUrl: formData.avatarUrl ?? _defaultAvatarUrl,
      birthDate: formData.birthDate,
      latitude: formData.latitude!,
      longitude: formData.longitude!,
      address: formData.address ?? '',
    ));

    switch (result) {
      case Success():
        emit(CompleteProfileSuccess(formData));
      case ApiError(:final failure):
        emit(CompleteProfileFailure(formData, failure.message));
    }
  }
}
