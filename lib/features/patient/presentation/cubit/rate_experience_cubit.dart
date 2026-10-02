import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/usecases/submit_pharmacy_rating_usecase.dart';
import 'rate_experience_state.dart';

/// "قيم تجربتك معنا" — collects a star rating for the app and one for
/// [pharmacyId]. Only the pharmacy rating has a real endpoint
/// (`POST /ratings` — see PatientRatingsRepository's doc comment); the app
/// rating has no backend anywhere in the API, so it's just kept in this
/// screen's state and never sent.
class RateExperienceCubit extends Cubit<RateExperienceState> {
  final int pharmacyId;
  final SubmitPharmacyRatingUseCase _submitPharmacyRatingUseCase;

  RateExperienceCubit(this.pharmacyId, this._submitPharmacyRatingUseCase)
      : super(const RateExperienceState());

  void appRatingChanged(int stars) => emit(state.copyWith(appRating: stars, clearError: true));

  void pharmacyRatingChanged(int stars) =>
      emit(state.copyWith(pharmacyRating: stars, clearError: true));

  void notesChanged(String notes) => emit(state.copyWith(notes: notes));

  Future<void> submit() async {
    if (state.isSubmitting) return;
    if (state.appRating == 0 && state.pharmacyRating == 0) {
      emit(state.copyWith(errorMessage: 'يرجى اختيار تقييم واحد على الأقل'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    if (state.pharmacyRating == 0) {
      // Only an app rating was given — nothing to send anywhere yet.
      emit(state.copyWith(isSubmitting: false, submitted: true));
      return;
    }

    final notes = state.notes.trim();
    final result = await _submitPharmacyRatingUseCase(
      pharmacyId: pharmacyId,
      stars: state.pharmacyRating,
      comment: notes.isEmpty ? null : notes,
    );
    if (isClosed) return;

    switch (result) {
      case Success():
        emit(state.copyWith(isSubmitting: false, submitted: true));
      case ApiError(:final failure):
        emit(state.copyWith(isSubmitting: false, errorMessage: failure.message));
    }
  }
}
