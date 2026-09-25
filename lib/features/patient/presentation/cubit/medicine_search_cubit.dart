import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/usecases/search_medicines_usecase.dart';
import 'medicine_search_state.dart';

class MedicineSearchCubit extends Cubit<MedicineSearchState> {
  final SearchMedicinesUseCase _searchMedicinesUseCase;

  /// Bumped on every [search] call, so a response can tell whether it still
  /// belongs to the latest one. Without it a slow response for "pa" lands
  /// after the one for "pan" and replaces it, and a response for a query the
  /// user has since cleared brings its results back under an empty field.
  int _latestSearch = 0;

  MedicineSearchCubit(this._searchMedicinesUseCase) : super(const MedicineSearchIdle());

  /// An empty/whitespace-only [query] resets to [MedicineSearchIdle] (the
  /// "الأكثر بحثاً" landing view) instead of searching for nothing — and, like
  /// any newer search, supersedes one still in flight.
  Future<void> search(String query) async {
    final search = ++_latestSearch;
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      emit(const MedicineSearchIdle());
      return;
    }

    emit(const MedicineSearchLoading());
    final result = await _searchMedicinesUseCase(trimmed);
    if (isClosed || search != _latestSearch) return;
    switch (result) {
      case Success(:final data):
        emit(MedicineSearchLoaded(query: trimmed, results: data));
      case ApiError(:final failure):
        emit(MedicineSearchLoadFailure(failure.message));
    }
  }
}
