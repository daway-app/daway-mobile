import '../../../../core/helpers/api_result.dart';
import '../entities/pharmacy_profile.dart';

abstract class PharmacyProfileRepository {
  Future<ApiResult<PharmacyProfile>> getProfile({required String token});

  Future<ApiResult<void>> updateProfile({
    required String token,
    required PharmacyProfile profile,
  });
}
