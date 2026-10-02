import '../../../../core/helpers/api_result.dart';
import '../../../chat/domain/repositories/inquiry_thread_resolver.dart';
import 'create_patient_inquiry_usecase.dart';
import 'get_patient_inquiries_usecase.dart';

class PatientInquiryThreadResolver implements InquiryThreadResolver {
  final GetPatientInquiriesUseCase _getInquiriesUseCase;
  final CreatePatientInquiryUseCase _createInquiryUseCase;

  const PatientInquiryThreadResolver(this._getInquiriesUseCase, this._createInquiryUseCase);

  @override
  Future<ApiResult<List<InquiryRef>>> findInquiries({required int pharmacyId}) async {
    final result = await _getInquiriesUseCase();
    return switch (result) {
      ApiError(:final failure) => ApiError(failure),
      Success(:final data) => Success([
          for (final inquiry in data.where((i) => i.pharmacyId == pharmacyId).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
            InquiryRef(id: inquiry.id, medicineId: inquiry.medicineId),
        ]),
    };
  }

  @override
  Future<ApiResult<int>> startInquiry({
    required int pharmacyId,
    int? medicineId,
    required String message,
  }) async {
    final result = await _createInquiryUseCase(
      pharmacyId: pharmacyId,
      medicineId: medicineId,
      message: message,
    );
    return switch (result) {
      ApiError(:final failure) => ApiError(failure),
      Success(:final data) => Success(data.id),
    };
  }
}
