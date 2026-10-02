class RateExperienceState {
  final int appRating;
  final int pharmacyRating;
  final String notes;
  final bool isSubmitting;
  final String? errorMessage;
  final bool submitted;

  const RateExperienceState({
    this.appRating = 0,
    this.pharmacyRating = 0,
    this.notes = '',
    this.isSubmitting = false,
    this.errorMessage,
    this.submitted = false,
  });

  RateExperienceState copyWith({
    int? appRating,
    int? pharmacyRating,
    String? notes,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    bool? submitted,
  }) {
    return RateExperienceState(
      appRating: appRating ?? this.appRating,
      pharmacyRating: pharmacyRating ?? this.pharmacyRating,
      notes: notes ?? this.notes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      submitted: submitted ?? this.submitted,
    );
  }
}
