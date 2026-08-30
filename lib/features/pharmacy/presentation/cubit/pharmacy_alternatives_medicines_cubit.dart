import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/usecases/get_medicines_with_alternative_status_usecase.dart';
import 'pharmacy_alternatives_medicines_state.dart';

/// Backs the "البدائل" entry screen: every medicine, plus which ones already
/// have an alternative and which still need one. Reloads every time a
/// pharmacist returns from picking an alternative, so — unlike
/// `PharmacyMedicinesCubit`, which always shows a full-screen spinner on
/// reload — this keeps the current list on screen instead of blanking it on
/// every return trip.
class PharmacyAlternativesMedicinesCubit
    extends Cubit<PharmacyAlternativesMedicinesState> {
  final GetMedicinesWithAlternativeStatusUseCase
  _getMedicinesWithAlternativeStatusUseCase;

  PharmacyAlternativesMedicinesCubit(
    this._getMedicinesWithAlternativeStatusUseCase,
  ) : super(const PharmacyAlternativesMedicinesLoading()) {
    load();
  }

  Future<void> load() async {
    final previous = state;
    if (previous is! PharmacyAlternativesMedicinesLoaded) {
      emit(const PharmacyAlternativesMedicinesLoading());
    }

    final result = await _getMedicinesWithAlternativeStatusUseCase();
    if (isClosed) return;
    // Read query from state now, not a pre-await snapshot — queryChanged
    // isn't blocked while this reload is in flight (the list stays visible
    // the whole time), so a search typed during the fetch must survive it
    // instead of being reverted back to whatever the query was when load()
    // started.
    final currentQuery = switch (state) {
      PharmacyAlternativesMedicinesLoaded(:final query) => query,
      _ => '',
    };
    switch (result) {
      case Success(:final data):
        emit(
          PharmacyAlternativesMedicinesLoaded(
            medicines: data.medicines,
            alreadyHandledIds: data.alreadyHandledIds,
            needingAlternativeIds: data.needingAlternativeIds,
            query: currentQuery,
          ),
        );
      case ApiError(:final failure):
        emit(PharmacyAlternativesMedicinesLoadFailure(failure.message));
    }
  }

  void queryChanged(String value) {
    final current = state;
    if (current is! PharmacyAlternativesMedicinesLoaded) return;
    emit(current.copyWith(query: value));
  }
}
