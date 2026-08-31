import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/usecases/get_pharmacy_ratings_usecase.dart';
import 'pharmacy_ratings_state.dart';

class PharmacyRatingsCubit extends Cubit<PharmacyRatingsState> {
  final GetPharmacyRatingsUseCase _getPharmacyRatingsUseCase;

  PharmacyRatingsCubit(this._getPharmacyRatingsUseCase)
    : super(const PharmacyRatingsLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const PharmacyRatingsLoading());
    final result = await _getPharmacyRatingsUseCase();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(
          PharmacyRatingsLoaded(
            ratings: data.ratings,
            totalCount: data.totalCount,
            averageRating: data.averageRating,
            starCounts: data.starCounts,
          ),
        );
      case ApiError(:final failure):
        emit(PharmacyRatingsLoadFailure(failure.message));
    }
  }
}
