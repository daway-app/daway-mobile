import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

class PharmacyRatingsRemoteDataSource {
  final Dio _dio;

  const PharmacyRatingsRemoteDataSource(this._dio);

  /// `per_page: 100` caps the page fetched — same tradeoff as
  /// PharmacyInquiriesRemoteDataSource.getInquiries: fine for the
  /// screen's list and for a pharmacy with under 100 ratings, but the
  /// average/star-breakdown derived from this page (see
  /// PharmacyRatingsRepositoryImpl) would drift for a pharmacy with more.
  Future<Response<dynamic>> getRatings({required String token}) {
    return _dio.get(
      ApiConstants.pharmacyRatings,
      queryParameters: {'per_page': 100},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
