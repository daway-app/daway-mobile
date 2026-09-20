import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final GetCategoriesUseCase _getCategoriesUseCase;

  CategoriesCubit(this._getCategoriesUseCase) : super(const CategoriesLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const CategoriesLoading());
    final result = await _getCategoriesUseCase();
    switch (result) {
      case Success(:final data):
        emit(CategoriesLoaded(data));
      case ApiError(:final failure):
        emit(CategoriesLoadFailure(failure.message));
    }
  }
}
