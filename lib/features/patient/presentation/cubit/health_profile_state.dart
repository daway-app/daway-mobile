sealed class HealthProfileState {
  const HealthProfileState();
}

class HealthProfileLoading extends HealthProfileState {
  const HealthProfileLoading();
}

class HealthProfileLoadFailure extends HealthProfileState {
  final String message;

  const HealthProfileLoadFailure(this.message);
}

/// The profile being edited: the lists and blood type live here (so chips
/// rebuild on change); the free-text notes stay in the screen's controller
/// and are passed to [HealthProfileCubit.save].
class HealthProfileLoaded extends HealthProfileState {
  final List<String> allergies;
  final List<String> chronicDiseases;
  final String? bloodType;
  final String notes;
  final bool isSaving;

  const HealthProfileLoaded({
    this.allergies = const [],
    this.chronicDiseases = const [],
    this.bloodType,
    this.notes = '',
    this.isSaving = false,
  });

  HealthProfileLoaded copyWith({
    List<String>? allergies,
    List<String>? chronicDiseases,
    String? bloodType,
    bool clearBloodType = false,
    bool? isSaving,
  }) {
    return HealthProfileLoaded(
      allergies: allergies ?? this.allergies,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      bloodType: clearBloodType ? null : (bloodType ?? this.bloodType),
      notes: notes,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
