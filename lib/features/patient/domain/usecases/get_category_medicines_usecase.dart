import '../../../../core/helpers/api_result.dart';
import '../entities/category_medicines_result.dart';
import '../repositories/category_repository.dart';

/// Public endpoint — no session/token needed, unlike most patient use cases.
class GetCategoryMedicinesUseCase {
  final CategoryRepository _repository;

  const GetCategoryMedicinesUseCase(this._repository);

  Future<ApiResult<CategoryMedicinesResult>> call({
    required String categorySlug,
    String? subcategorySlug,
    String? dosageForm,
    String? query,
    int page = 1,
    int perPage = 20,
  }) =>
      _repository.getCategoryMedicines(
        categorySlug: categorySlug,
        subcategorySlug: subcategorySlug,
        dosageForm: dosageForm,
        query: query,
        page: page,
        perPage: perPage,
      );
}
