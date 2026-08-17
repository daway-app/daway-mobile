import '../../domain/entities/pharmacy_profile.dart';
import '../../domain/entities/working_hours_entry.dart';

sealed class PharmacyProfileState {
  const PharmacyProfileState();
}

class PharmacyProfileLoading extends PharmacyProfileState {
  const PharmacyProfileLoading();
}

class PharmacyProfileLoadFailure extends PharmacyProfileState {
  final String message;

  const PharmacyProfileLoadFailure(this.message);
}

/// The profile as last fetched/saved, plus the in-progress edits — kept
/// separate from [profile] so cancelling an edit can just discard them.
class PharmacyProfileLoaded extends PharmacyProfileState {
  final PharmacyProfile profile;
  final bool isEditing;
  final String name;
  final String? logoLocalPath;
  final String? logoUrl;
  final bool isUploadingLogo;
  final String? logoError;
  final double? latitude;
  final double? longitude;
  final String? address;
  final List<WorkingHoursEntry> workingHours;
  final bool isSaving;
  final String? saveError;

  const PharmacyProfileLoaded({
    required this.profile,
    this.isEditing = false,
    required this.name,
    this.logoLocalPath,
    this.logoUrl,
    this.isUploadingLogo = false,
    this.logoError,
    this.latitude,
    this.longitude,
    this.address,
    required this.workingHours,
    this.isSaving = false,
    this.saveError,
  });

  factory PharmacyProfileLoaded.fromProfile(PharmacyProfile profile) {
    return PharmacyProfileLoaded(
      profile: profile,
      name: profile.name,
      logoUrl: profile.logoUrl,
      latitude: profile.latitude,
      longitude: profile.longitude,
      address: profile.address,
      workingHours: profile.workingHours,
    );
  }

  bool get hasLocation => latitude != null && longitude != null;

  /// True until the pharmacy has a location set — used to prompt them to
  /// finish setting up their profile.
  bool get isIncomplete => !hasLocation;

  bool get canSave => name.trim().isNotEmpty && hasLocation && !isUploadingLogo;

  PharmacyProfileLoaded copyWith({
    bool? isEditing,
    String? name,
    String? logoLocalPath,
    String? logoUrl,
    bool? isUploadingLogo,
    String? logoError,
    bool clearLogoError = false,
    double? latitude,
    double? longitude,
    String? address,
    List<WorkingHoursEntry>? workingHours,
    bool? isSaving,
    String? saveError,
    bool clearSaveError = false,
  }) {
    return PharmacyProfileLoaded(
      profile: profile,
      isEditing: isEditing ?? this.isEditing,
      name: name ?? this.name,
      logoLocalPath: logoLocalPath ?? this.logoLocalPath,
      logoUrl: logoUrl ?? this.logoUrl,
      isUploadingLogo: isUploadingLogo ?? this.isUploadingLogo,
      logoError: clearLogoError ? null : (logoError ?? this.logoError),
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      workingHours: workingHours ?? this.workingHours,
      isSaving: isSaving ?? this.isSaving,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
    );
  }
}
