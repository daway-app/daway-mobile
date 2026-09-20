import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../../core/helpers/json_list_extractor.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_medicines_result.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';
import '../models/category_medicine_model.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  const CategoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<List<Category>>> getCategories() async {
    try {
      final response = await _remoteDataSource.getCategories();
      final categories = extractJsonList(response.data, source: 'GET /categories')
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
      return Success(categories);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<CategoryMedicinesResult>> getCategoryMedicines({
    required String categorySlug,
    String? subcategorySlug,
    String? dosageForm,
    String? query,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _remoteDataSource.getCategoryMedicines(
        categorySlug: categorySlug,
        subcategorySlug: subcategorySlug,
        dosageForm: dosageForm,
        query: query,
        page: page,
        perPage: perPage,
      );
      const source = 'GET /categories/{slug}/medicines';
      final medicines = extractJsonList(response.data, source: source)
          .map((json) => CategoryMedicineModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      final body = response.data;
      final pagination = body is Map<String, dynamic> ? body['pagination'] : null;
      if (pagination is! Map<String, dynamic>) {
        throw FormatException('Unexpected $source pagination shape: $body');
      }

      return Success(CategoryMedicinesResult(
        medicines: medicines,
        total: pagination['total'] as int? ?? medicines.length,
        currentPage: pagination['current_page'] as int? ?? page,
        lastPage: pagination['last_page'] as int? ?? page,
      ));
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<List<String>>> getDosageForms() async {
    try {
      final response = await _remoteDataSource.getDosageForms();
      final dosageForms = extractJsonList(response.data, source: 'GET /dosage-forms')
          .map((form) => form as String)
          .toList();
      return Success(dosageForms);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
