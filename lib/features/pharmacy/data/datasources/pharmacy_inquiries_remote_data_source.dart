import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

class PharmacyInquiriesRemoteDataSource {
  final Dio _dio;

  const PharmacyInquiriesRemoteDataSource(this._dio);

  /// `per_page: 100` caps the list itself (client-side filtering, same
  /// pattern as PharmacyInventoryRemoteDataSource) — the stat cards don't
  /// depend on this cap since they read the backend's own `counts` object
  /// instead of tallying this list, so they stay correct even for a
  /// pharmacy with more than 100 inquiries. Only the filtered *list* would
  /// stop showing older entries past that count.
  Future<Response<dynamic>> getInquiries({required String token}) {
    return _dio.get(
      ApiConstants.pharmacyInquiries,
      queryParameters: {'per_page': 100},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response<dynamic>> updateStatus({
    required String token,
    required int inquiryId,
    required String status,
  }) {
    return _dio.put(
      '${ApiConstants.pharmacyInquiries}/$inquiryId',
      data: {'status': status},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
