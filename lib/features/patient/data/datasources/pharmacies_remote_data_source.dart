import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

/// `GET /pharmacies` and `GET /pharmacies/{id}` are public endpoints (no
/// auth token).
class PharmaciesRemoteDataSource {
  final Dio _dio;

  const PharmaciesRemoteDataSource(this._dio);

  /// Never called with `latitude`/`longitude` — see
  /// [PharmaciesRepository.getNearbyPharmacies]'s doc comment.
  Future<Response<dynamic>> getPharmacies() {
    return _dio.get(ApiConstants.pharmacies);
  }

  Future<Response<dynamic>> getPharmacyDetail(int pharmacyId) {
    return _dio.get('${ApiConstants.pharmacies}/$pharmacyId');
  }
}
