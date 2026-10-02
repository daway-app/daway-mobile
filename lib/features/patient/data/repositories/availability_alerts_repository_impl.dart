import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../domain/repositories/availability_alerts_repository.dart';
import '../datasources/availability_alerts_remote_data_source.dart';

class AvailabilityAlertsRepositoryImpl implements AvailabilityAlertsRepository {
  final AvailabilityAlertsRemoteDataSource _remoteDataSource;

  const AvailabilityAlertsRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<void>> subscribe({required String token, required int medicineId}) async {
    try {
      await _remoteDataSource.create(token: token, medicineId: medicineId);
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
