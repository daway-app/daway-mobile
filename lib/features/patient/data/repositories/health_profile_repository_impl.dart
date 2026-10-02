import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/patient_health_profile.dart';
import '../../domain/repositories/health_profile_repository.dart';
import '../datasources/health_profile_remote_data_source.dart';
import '../models/patient_health_profile_model.dart';

class HealthProfileRepositoryImpl implements HealthProfileRepository {
  final HealthProfileRemoteDataSource _remoteDataSource;

  const HealthProfileRepositoryImpl(this._remoteDataSource);

  PatientHealthProfile _parse(Object? body, String source) {
    final data = body is Map<String, dynamic> ? body['data'] : null;
    if (data is! Map<String, dynamic>) {
      throw FormatException('Unexpected $source response shape: $body');
    }
    return PatientHealthProfileModel.fromJson(data).toEntity();
  }

  @override
  Future<ApiResult<PatientHealthProfile>> getHealthProfile({required String token}) async {
    try {
      final response = await _remoteDataSource.getHealthProfile(token: token);
      return Success(_parse(response.data, 'GET /patient/health-profile'));
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<PatientHealthProfile>> updateHealthProfile({
    required String token,
    required PatientHealthProfile profile,
  }) async {
    try {
      final response = await _remoteDataSource.updateHealthProfile(
        token: token,
        allergies: profile.allergies,
        chronicDiseases: profile.chronicDiseases,
        bloodType: profile.bloodType,
        notes: profile.notes,
      );
      return Success(_parse(response.data, 'PUT /patient/health-profile'));
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
