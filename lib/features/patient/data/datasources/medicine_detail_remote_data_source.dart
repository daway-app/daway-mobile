import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

/// `GET /medicines/{id}` and `GET /medicines/{id}/pharmacies` are public
/// endpoints (no auth token) — same as [CategoryRemoteDataSource] and
/// [MedicineSearchRemoteDataSource].
class MedicineDetailRemoteDataSource {
  final Dio _dio;

  const MedicineDetailRemoteDataSource(this._dio);

  Future<Response<dynamic>> getMedicine({
    required int medicineId,
    double? latitude,
    double? longitude,
  }) {
    return _dio.get(
      '${ApiConstants.medicines}/$medicineId',
      queryParameters: {'latitude': ?latitude, 'longitude': ?longitude},
    );
  }

  Future<Response<dynamic>> getMedicinePharmacies({
    required int medicineId,
    double? latitude,
    double? longitude,
  }) {
    return _dio.get(
      '${ApiConstants.medicines}/$medicineId/pharmacies',
      queryParameters: {'latitude': ?latitude, 'longitude': ?longitude},
    );
  }
}
