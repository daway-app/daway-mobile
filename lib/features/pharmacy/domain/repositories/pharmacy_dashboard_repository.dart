import '../../../../core/helpers/api_result.dart';
import '../entities/pharmacy_dashboard_stats.dart';

abstract class PharmacyDashboardRepository {
  Future<ApiResult<PharmacyDashboardStats>> getDashboardStats({required String token});
}
