import '../../../../core/helpers/api_result.dart';
import '../entities/rating.dart';

abstract class PharmacyRatingsRepository {
  Future<ApiResult<RatingsOverview>> getRatings({required String token});
}
