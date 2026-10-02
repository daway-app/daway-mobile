import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/data/datasources/patient_ratings_remote_data_source.dart';
import 'package:daway_app/features/patient/data/repositories/patient_ratings_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRemoteDataSource extends PatientRatingsRemoteDataSource {
  bool throws = false;

  _StubRemoteDataSource() : super(Dio());

  @override
  Future<Response<dynamic>> submitRating({
    required String token,
    required int pharmacyId,
    required int stars,
    String? comment,
  }) async {
    if (throws) throw DioException(requestOptions: RequestOptions());
    return Response(requestOptions: RequestOptions(), statusCode: 201);
  }
}

void main() {
  test('returns success on a 201', () async {
    final repository = PatientRatingsRepositoryImpl(_StubRemoteDataSource());

    final result = await repository.submitPharmacyRating(
      token: 'tok-1',
      pharmacyId: 11,
      stars: 5,
    );

    expect(result, isA<Success<void>>());
  });

  test('surfaces a network failure instead of throwing', () async {
    final remoteDataSource = _StubRemoteDataSource()..throws = true;
    final repository = PatientRatingsRepositoryImpl(remoteDataSource);

    final result = await repository.submitPharmacyRating(
      token: 'tok-1',
      pharmacyId: 11,
      stars: 5,
    );

    expect(result, isA<ApiError<void>>());
  });
}
