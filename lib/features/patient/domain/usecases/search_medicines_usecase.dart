import '../../../../core/helpers/api_result.dart';
import '../entities/searched_medicine.dart';
import '../repositories/medicine_search_repository.dart';

/// Public endpoint — no session/token needed.
class SearchMedicinesUseCase {
  final MedicineSearchRepository _repository;

  const SearchMedicinesUseCase(this._repository);

  Future<ApiResult<List<SearchedMedicine>>> call(String query) =>
      _repository.search(query);
}
