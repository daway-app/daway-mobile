import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/get_category_medicines_usecase.dart';
import '../../domain/usecases/get_dosage_forms_usecase.dart';
import 'category_medicines_state.dart';

class CategoryMedicinesCubit extends Cubit<CategoryMedicinesState> {
  final Category category;
  final GetCategoryMedicinesUseCase _getCategoryMedicinesUseCase;
  final GetDosageFormsUseCase _getDosageFormsUseCase;

  static const int _perPage = 20;

  /// Fetched once in [_init] and reused across every [load] call instead of
  /// being re-fetched on each search/filter change.
  List<String> _dosageForms = const [];

  CategoryMedicinesCubit(
    this.category,
    this._getCategoryMedicinesUseCase,
    this._getDosageFormsUseCase,
  ) : super(const CategoryMedicinesLoading()) {
    _init();
  }

  Future<void> _init() async {
    final dosageFormsResult = await _getDosageFormsUseCase();
    switch (dosageFormsResult) {
      case Success(:final data):
        _dosageForms = data;
      case ApiError():
        _dosageForms = const [];
    }
    await load();
  }

  Future<void> load({String? subcategorySlug, String? dosageForm, String query = ''}) async {
    emit(const CategoryMedicinesLoading());
    final result = await _getCategoryMedicinesUseCase(
      categorySlug: category.slug,
      subcategorySlug: subcategorySlug,
      dosageForm: dosageForm,
      query: query,
      page: 1,
      perPage: _perPage,
    );
    switch (result) {
      case Success(:final data):
        emit(CategoryMedicinesLoaded(
          medicines: data.medicines,
          total: data.total,
          currentPage: data.currentPage,
          lastPage: data.lastPage,
          query: query,
          subcategorySlug: subcategorySlug,
          dosageForm: dosageForm,
          dosageForms: _dosageForms,
        ));
      case ApiError(:final failure):
        emit(CategoryMedicinesLoadFailure(failure.message));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! CategoryMedicinesLoaded) return;
    if (current.isLoadingMore || !current.hasMorePages) return;

    emit(current.copyWith(isLoadingMore: true));
    final result = await _getCategoryMedicinesUseCase(
      categorySlug: category.slug,
      subcategorySlug: current.subcategorySlug,
      dosageForm: current.dosageForm,
      query: current.query,
      page: current.currentPage + 1,
      perPage: _perPage,
    );
    switch (result) {
      case Success(:final data):
        emit(current.copyWith(
          medicines: [...current.medicines, ...data.medicines],
          currentPage: data.currentPage,
          lastPage: data.lastPage,
          total: data.total,
          isLoadingMore: false,
        ));
      case ApiError():
        // Keep the already-loaded page; just stop the loading-more spinner.
        emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> search(String query) {
    final current = state;
    return load(
      subcategorySlug: current is CategoryMedicinesLoaded ? current.subcategorySlug : null,
      dosageForm: current is CategoryMedicinesLoaded ? current.dosageForm : null,
      query: query,
    );
  }

  Future<void> applyFilters({String? subcategorySlug, String? dosageForm}) {
    final current = state;
    return load(
      subcategorySlug: subcategorySlug,
      dosageForm: dosageForm,
      query: current is CategoryMedicinesLoaded ? current.query : '',
    );
  }

  /// Cheap preview count for the filter sheet's "عرض النتائج (N)" button.
  /// Doesn't touch the cubit's emitted state — the sheet holds its own
  /// pending selection until "عرض النتائج" is pressed.
  Future<int?> previewResultCount({String? subcategorySlug, String? dosageForm}) async {
    final current = state;
    final result = await _getCategoryMedicinesUseCase(
      categorySlug: category.slug,
      subcategorySlug: subcategorySlug,
      dosageForm: dosageForm,
      query: current is CategoryMedicinesLoaded ? current.query : '',
      page: 1,
      perPage: 1,
    );
    return switch (result) {
      Success(:final data) => data.total,
      ApiError() => null,
    };
  }
}
