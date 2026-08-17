import '../../../../core/helpers/api_result.dart';
import '../entities/patient_profile.dart';

abstract class PatientProfileRepository {
  Future<ApiResult<void>> updateProfile({
    required String token,
    required PatientProfile profile,
  });
}
