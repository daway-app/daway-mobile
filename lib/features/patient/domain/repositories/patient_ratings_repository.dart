import '../../../../core/helpers/api_result.dart';

abstract class PatientRatingsRepository {
  /// `POST /ratings` — [stars] is 1–5, [comment] optional.
  Future<ApiResult<void>> submitPharmacyRating({
    required String token,
    required int pharmacyId,
    required int stars,
    String? comment,
  });
}
