import '../../domain/entities/patient_profile.dart';

sealed class PatientProfileState {
  const PatientProfileState();
}

class PatientProfileLoading extends PatientProfileState {
  const PatientProfileLoading();
}

class PatientProfileLoadFailure extends PatientProfileState {
  final String message;

  const PatientProfileLoadFailure(this.message);
}

/// The profile as last fetched/saved, plus the in-progress edits — kept
/// separate from [profile] so cancelling an edit can just discard them.
class PatientProfileLoaded extends PatientProfileState {
  final PatientProfile profile;
  final bool isEditing;
  final String name;
  final String? birthDate;
  final String? avatarLocalPath;
  final String? avatarUrl;
  final bool isUploadingAvatar;
  final String? avatarError;
  final double? latitude;
  final double? longitude;
  final String? address;
  final bool isSaving;
  final String? saveError;

  const PatientProfileLoaded({
    required this.profile,
    this.isEditing = false,
    required this.name,
    this.birthDate,
    this.avatarLocalPath,
    this.avatarUrl,
    this.isUploadingAvatar = false,
    this.avatarError,
    this.latitude,
    this.longitude,
    this.address,
    this.isSaving = false,
    this.saveError,
  });

  factory PatientProfileLoaded.fromProfile(PatientProfile profile) {
    return PatientProfileLoaded(
      profile: profile,
      name: profile.name,
      birthDate: profile.birthDate,
      avatarUrl: profile.avatarUrl,
      latitude: profile.latitude,
      longitude: profile.longitude,
      address: profile.address,
    );
  }

  bool get hasLocation => latitude != null && longitude != null;

  /// True until the patient has picked a location at least once — used to
  /// prompt them to finish setting up their profile.
  bool get isIncomplete => !hasLocation;

  bool get canSave => name.trim().isNotEmpty && hasLocation && !isUploadingAvatar;

  PatientProfileLoaded copyWith({
    bool? isEditing,
    String? name,
    String? birthDate,
    String? avatarLocalPath,
    String? avatarUrl,
    bool? isUploadingAvatar,
    String? avatarError,
    bool clearAvatarError = false,
    double? latitude,
    double? longitude,
    String? address,
    bool? isSaving,
    String? saveError,
    bool clearSaveError = false,
  }) {
    return PatientProfileLoaded(
      profile: profile,
      isEditing: isEditing ?? this.isEditing,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      avatarError: clearAvatarError ? null : (avatarError ?? this.avatarError),
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      isSaving: isSaving ?? this.isSaving,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
    );
  }
}
