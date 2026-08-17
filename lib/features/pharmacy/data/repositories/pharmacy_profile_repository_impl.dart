import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/pharmacy_profile.dart';
import '../../domain/repositories/pharmacy_profile_repository.dart';
import '../datasources/pharmacy_profile_remote_data_source.dart';
import '../models/pharmacy_profile_model.dart';

class PharmacyProfileRepositoryImpl implements PharmacyProfileRepository {
  final PharmacyProfileRemoteDataSource _remoteDataSource;

  const PharmacyProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<PharmacyProfile>> getProfile({required String token}) async {
    try {
      final response = await _remoteDataSource.getProfile(token: token);
      final model = PharmacyProfileModel.fromJson(response.data as Map<String, dynamic>);
      return Success(model.toEntity());
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> updateProfile({
    required String token,
    required PharmacyProfile profile,
  }) async {
    try {
      await _remoteDataSource.updateProfile(
        token: token,
        body: {
          'name': profile.name,
          'phone': profile.phone,
          if (profile.logoUrl != null) 'logo_url': profile.logoUrl,
          if (profile.latitude != null) 'latitude': profile.latitude,
          if (profile.longitude != null) 'longitude': profile.longitude,
          if (profile.address != null) 'address': profile.address,
          'working_hours': {
            for (final entry in profile.workingHours)
              entry.day.name: entry.isOpen ? {'open': entry.open, 'close': entry.close} : null,
          },
        },
      );
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
