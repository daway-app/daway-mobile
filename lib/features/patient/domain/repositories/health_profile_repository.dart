import '../../../../core/helpers/api_result.dart';
import '../entities/patient_health_profile.dart';

abstract class HealthProfileRepository {
  /// `GET /patient/health-profile`.
  Future<ApiResult<PatientHealthProfile>> getHealthProfile({required String token});

  /// `PUT /patient/health-profile` — returns the profile as the server saved it.
  Future<ApiResult<PatientHealthProfile>> updateHealthProfile({
    required String token,
    required PatientHealthProfile profile,
  });
}
