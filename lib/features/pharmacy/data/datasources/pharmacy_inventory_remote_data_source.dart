import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

class PharmacyInventoryRemoteDataSource {
  final Dio _dio;

  const PharmacyInventoryRemoteDataSource(this._dio);

  Future<Response<dynamic>> getInventory({required String token}) {
    return _dio.get(
      ApiConstants.pharmacyInventory,
      queryParameters: {'per_page': 100},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response<dynamic>> bulkUpdate({
    required String token,
    required Map<String, dynamic> body,
  }) {
    return _dio.post(
      ApiConstants.pharmacyInventoryBulk,
      data: body,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
