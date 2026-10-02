import '../../../../core/helpers/api_result.dart';

abstract class AvailabilityAlertsRepository {
  /// `POST /patient/availability-alerts` — asks to be notified when
  /// [medicineId] becomes available at any pharmacy. Idempotent.
  Future<ApiResult<void>> subscribe({required String token, required int medicineId});
}
