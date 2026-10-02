import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

class CartRemoteDataSource {
  final Dio _dio;

  const CartRemoteDataSource(this._dio);

  Future<Response<dynamic>> getCart({required String token}) {
    return _dio.get(
      ApiConstants.patientCart,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  /// The documented body is `pharmacy_medicine_id` + `quantity`. No public
  /// endpoint returns that id, so when it is unknown the pharmacy and the
  /// medicine are sent instead and the server decides (a 422 message is
  /// shown as-is if it doesn't accept that).
  Future<Response<dynamic>> addItem({
    required String token,
    int? pharmacyMedicineId,
    required int pharmacyId,
    required int medicineId,
    required int quantity,
  }) {
    return _dio.post(
      ApiConstants.patientCartItems,
      data: {
        if (pharmacyMedicineId != null)
          'pharmacy_medicine_id': pharmacyMedicineId
        else ...{'pharmacy_id': pharmacyId, 'medicine_id': medicineId},
        'quantity': quantity,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response<dynamic>> deleteItem({required String token, required int itemId}) {
    return _dio.delete(
      '${ApiConstants.patientCartItems}/$itemId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response<dynamic>> clearCart({required String token}) {
    return _dio.delete(
      ApiConstants.patientCart,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response<dynamic>> updateItemQuantity({
    required String token,
    required int itemId,
    required int quantity,
  }) {
    return _dio.put(
      '${ApiConstants.patientCartItems}/$itemId',
      data: {'quantity': quantity},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
