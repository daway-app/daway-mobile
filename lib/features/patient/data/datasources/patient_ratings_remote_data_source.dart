import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

class PatientRatingsRemoteDataSource {
  final Dio _dio;

  const PatientRatingsRemoteDataSource(this._dio);

  Future<Response<dynamic>> submitRating({
    required String token,
    required int pharmacyId,
    required int stars,
    String? comment,
  }) {
    return _dio.post(
      ApiConstants.ratings,
      data: {
        'pharmacy_id': pharmacyId,
        'stars_rating': stars,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
