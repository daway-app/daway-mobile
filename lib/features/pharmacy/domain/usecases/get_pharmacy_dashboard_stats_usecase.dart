import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../entities/pharmacy_dashboard_stats.dart';
import '../repositories/pharmacy_dashboard_repository.dart';

class GetPharmacyDashboardStatsUseCase {
  final PharmacyDashboardRepository _repository;
  final SessionRepository _sessionRepository;

  const GetPharmacyDashboardStatsUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<PharmacyDashboardStats>> call() async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.getDashboardStats(token: session.token);
  }
}
