import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

/// `GET /medicines/search` is a public endpoint (no auth token) — same as
/// [CategoryRemoteDataSource].
class MedicineSearchRemoteDataSource {
  final Dio _dio;

  const MedicineSearchRemoteDataSource(this._dio);

  Future<Response<dynamic>> search(String query) {
    return _dio.get(
      ApiConstants.medicinesSearch,
      queryParameters: {'q': query},
    );
  }
}
