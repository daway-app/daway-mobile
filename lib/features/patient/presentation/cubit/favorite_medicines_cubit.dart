import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/usecases/get_favorite_medicines_usecase.dart';
import 'favorite_medicines_state.dart';

class FavoriteMedicinesCubit extends Cubit<FavoriteMedicinesState> {
  final GetFavoriteMedicinesUseCase _getFavoriteMedicinesUseCase;

  FavoriteMedicinesCubit(this._getFavoriteMedicinesUseCase)
      : super(const FavoriteMedicinesLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const FavoriteMedicinesLoading());
    final result = await _getFavoriteMedicinesUseCase();
    // The screen may have been popped while the request was in flight.
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(FavoriteMedicinesLoaded(data));
      case ApiError(:final failure):
        emit(FavoriteMedicinesLoadFailure(failure.message));
    }
  }
}
