import '../../../../core/helpers/api_result.dart';
import '../entities/inquiry.dart';

abstract class PharmacyInquiriesRepository {
  Future<ApiResult<InquiriesOverview>> getInquiries({required String token});

  Future<ApiResult<void>> updateInquiryStatus({
    required String token,
    required int inquiryId,
    required InquiryStatus status,
  });
}
