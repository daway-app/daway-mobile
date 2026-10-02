import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

class OrdersRemoteDataSource {
  final Dio _dio;

  const OrdersRemoteDataSource(this._dio);

  Future<Response<dynamic>> getOrders({required String token, int page = 1}) {
    return _dio.get(
      ApiConstants.patientOrders,
      queryParameters: {'page': page},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response<dynamic>> cancelOrder({required String token, required int orderId}) {
    return _dio.post(
      '${ApiConstants.patientOrders}/$orderId/cancel',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response<dynamic>> checkout({
    required String token,
    required int addressId,
    String? couponCode,
    String? notes,
  }) {
    return _dio.post(
      ApiConstants.patientCheckout,
      data: {
        'address_id': addressId,
        if (couponCode != null) 'coupon_code': couponCode,
        if (notes != null) 'notes': notes,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
