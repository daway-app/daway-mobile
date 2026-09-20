import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

/// `GET /categories`, `GET /categories/{slug}/medicines` and
/// `GET /dosage-forms` are public endpoints (no auth token, per the
/// backend's Categories API collection) — unlike most other patient data
/// sources.
class CategoryRemoteDataSource {
  final Dio _dio;

  const CategoryRemoteDataSource(this._dio);

  Future<Response<dynamic>> getCategories() {
    return _dio.get(ApiConstants.categories);
  }

  Future<Response<dynamic>> getCategoryMedicines({
    required String categorySlug,
    String? subcategorySlug,
    String? dosageForm,
    String? query,
    required int page,
    required int perPage,
  }) {
    return _dio.get(
      '${ApiConstants.categories}/$categorySlug/medicines',
      queryParameters: {
        'subcategory': ?subcategorySlug,
        'dosage_form': ?dosageForm,
        if (query != null && query.isNotEmpty) 'q': query,
        'page': page,
        'per_page': perPage,
      },
    );
  }

  Future<Response<dynamic>> getDosageForms() {
    return _dio.get(ApiConstants.dosageForms);
  }
}
