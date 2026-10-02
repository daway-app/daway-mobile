import '../../../../core/helpers/api_result.dart';
import '../entities/pharmacy_inquiry.dart';

abstract class PatientInquiriesRepository {
  Future<ApiResult<List<PharmacyInquiry>>> getInquiries({required String token});

  Future<ApiResult<PharmacyInquiry>> createInquiry({
    required String token,
    required int pharmacyId,
    int? medicineId,
    required String message,
  });
}
