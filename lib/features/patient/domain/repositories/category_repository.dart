import '../../../../core/helpers/api_result.dart';
import '../entities/category.dart';
import '../entities/category_medicines_result.dart';

abstract class CategoryRepository {
  Future<ApiResult<List<Category>>> getCategories();

  Future<ApiResult<CategoryMedicinesResult>> getCategoryMedicines({
    required String categorySlug,
    String? subcategorySlug,
    String? dosageForm,
    String? query,
    int page = 1,
    int perPage = 20,
  });

  Future<ApiResult<List<String>>> getDosageForms();
}
