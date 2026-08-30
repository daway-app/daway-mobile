import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/usecases/get_alternatives_overview_usecase.dart';
import '../../domain/usecases/remove_alternative_usecase.dart';
import '../../domain/usecases/select_alternative_usecase.dart';
import 'pharmacy_alternatives_state.dart';

class PharmacyAlternativesCubit extends Cubit<PharmacyAlternativesState> {
  final Medicine baseMedicine;
  final GetAlternativesOverviewUseCase _getAlternativesOverviewUseCase;
  final SelectAlternativeUseCase _selectAlternativeUseCase;
  final RemoveAlternativeUseCase _removeAlternativeUseCase;

  PharmacyAlternativesCubit(
    this.baseMedicine,
    this._getAlternativesOverviewUseCase,
    this._selectAlternativeUseCase,
    this._removeAlternativeUseCase,
  ) : super(const PharmacyAlternativesLoading()) {
    load();
  }

  /// Only shows the full-screen loading state on a cold start or a retry
  /// from an error — the reload after selecting/removing an alternative
  /// keeps the current list on screen (with that one candidate's spinner
  /// still showing via `updatingCandidateId`) instead of blanking everything.
  Future<void> load() async {
    final previous = state;
    if (previous is! PharmacyAlternativesLoaded) {
      emit(const PharmacyAlternativesLoading());
    }
    final result = await _getAlternativesOverviewUseCase(baseMedicine);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(
          PharmacyAlternativesLoaded(
            baseMedicine: data.baseMedicine,
            candidates: data.candidates,
            selectedAlternativeIds: data.selectedAlternativeIds,
          ),
        );
      case ApiError(:final failure):
        emit(PharmacyAlternativesLoadFailure(failure.message));
    }
  }

  /// Tapping an already-selected candidate unlinks it; tapping any other
  /// candidate makes it the (sole) selected alternative. Blocked while
  /// *any* candidate has a request in flight — not just this one — because
  /// the backend allows several alternatives to be linked at once, and a
  /// select for one candidate racing a select for another would defeat the
  /// "only one selected" rule [SelectAlternativeUseCase] is meant to
  /// enforce (both would read the same pre-tap selection as "previous").
  ///
  /// Returns null on success, or a user-facing error message on failure —
  /// lets the screen show a snackbar without the cubit owning UI feedback.
  Future<String?> toggleCandidate(Medicine candidate) async {
    final current = state;
    if (current is! PharmacyAlternativesLoaded ||
        current.updatingCandidateId != null) {
      return null;
    }

    final isCurrentlySelected = current.selectedAlternativeIds.contains(
      candidate.medicineId,
    );
    // updatingCandidateId is a UI-local "which card is spinning" key, not
    // sent to the backend — candidate.id (this candidate's own
    // pharmacy_medicine id) is fine here even though the backend calls
    // below key on candidate.medicineId (its catalog id) instead.
    emit(current.copyWith(updatingCandidateId: candidate.id));

    final result = isCurrentlySelected
        ? await _removeAlternativeUseCase(
            baseMedicineId: baseMedicine.id,
            alternativeId: candidate.medicineId,
          )
        : await _selectAlternativeUseCase(
            baseMedicineId: baseMedicine.id,
            newAlternativeId: candidate.medicineId,
            previousAlternativeIds: current.selectedAlternativeIds,
          );
    if (isClosed) return null;

    // Reload rather than patch selectedAlternativeIds locally, on success or
    // failure alike: this is the only way to pick up a server-side rejection
    // of the "only one selected" assumption instead of showing a state that
    // later turns out to be wrong. A select's remove-then-create sequence
    // can also fail *after* the remove already succeeded server-side, so an
    // unconditional reload keeps that from leaving a stale candidate shown
    // as selected when it no longer is.
    await load();
    return switch (result) {
      Success() => null,
      ApiError(:final failure) => failure.message,
    };
  }
}
