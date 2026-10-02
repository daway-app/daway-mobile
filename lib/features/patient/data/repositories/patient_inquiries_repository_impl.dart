import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../../core/helpers/paginated_fetch.dart';
import '../../domain/entities/pharmacy_inquiry.dart';
import '../../domain/repositories/patient_inquiries_repository.dart';
import '../datasources/patient_inquiries_remote_data_source.dart';
import '../models/pharmacy_inquiry_model.dart';

class PatientInquiriesRepositoryImpl implements PatientInquiriesRepository {
  final PatientInquiriesRemoteDataSource _remoteDataSource;

  const PatientInquiriesRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<List<PharmacyInquiry>>> getInquiries({required String token}) async {
    try {
      final inquiriesJson = await fetchAllPages(
        source: 'GET /patient/inquiries',
        fetchPage: (page) async =>
            (await _remoteDataSource.getInquiries(token: token, page: page)).data,
      );
      final inquiries = inquiriesJson
          .map((json) => PharmacyInquiryModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
      return Success(inquiries);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<PharmacyInquiry>> createInquiry({
    required String token,
    required int pharmacyId,
    int? medicineId,
    required String message,
  }) async {
    try {
      final response = await _remoteDataSource.createInquiry(
        token: token,
        pharmacyId: pharmacyId,
        medicineId: medicineId,
        message: message,
      );
      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      return Success(PharmacyInquiryModel.fromJson(data).toEntity());
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
