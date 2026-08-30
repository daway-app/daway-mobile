import '../../domain/entities/medicine.dart';

sealed class PharmacyAlternativesState {
  const PharmacyAlternativesState();
}

class PharmacyAlternativesLoading extends PharmacyAlternativesState {
  const PharmacyAlternativesLoading();
}

class PharmacyAlternativesLoadFailure extends PharmacyAlternativesState {
  final String message;

  const PharmacyAlternativesLoadFailure(this.message);
}

class PharmacyAlternativesLoaded extends PharmacyAlternativesState {
  final Medicine baseMedicine;
  final List<Medicine> candidates;

  /// At most one id at a time — selecting a new alternative unlinks the
  /// previous one first (see SelectAlternativeUseCase).
  final Set<int> selectedAlternativeIds;

  /// The one candidate id with a select/remove request in flight (at most
  /// one, since [PharmacyAlternativesCubit.toggleCandidate] blocks further
  /// taps while this is set) — disables that card's button and shows a
  /// spinner instead of letting a second tap fire a duplicate request.
  final int? updatingCandidateId;

  const PharmacyAlternativesLoaded({
    required this.baseMedicine,
    required this.candidates,
    required this.selectedAlternativeIds,
    this.updatingCandidateId,
  });

  PharmacyAlternativesLoaded copyWith({int? updatingCandidateId}) {
    return PharmacyAlternativesLoaded(
      baseMedicine: baseMedicine,
      candidates: candidates,
      selectedAlternativeIds: selectedAlternativeIds,
      updatingCandidateId: updatingCandidateId,
    );
  }
}
