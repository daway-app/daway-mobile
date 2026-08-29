import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../../core/helpers/json_list_extractor.dart';
import '../../domain/entities/inquiry.dart';
import '../../domain/repositories/pharmacy_inquiries_repository.dart';
import '../datasources/pharmacy_inquiries_remote_data_source.dart';
import '../models/inquiry_model.dart';

class PharmacyInquiriesRepositoryImpl implements PharmacyInquiriesRepository {
  final PharmacyInquiriesRemoteDataSource _remoteDataSource;

  const PharmacyInquiriesRepositoryImpl(this._remoteDataSource);

  /// `GET /pharmacy/inquiries` returns the page of inquiries alongside a
  /// `counts` object with the true new/answered/closed totals — those are
  /// used as-is rather than tallied from the page, since the page can be a
  /// partial (paginated) view. One malformed inquiry record is skipped
  /// rather than failing the whole list, same reasoning as
  /// PharmacyDashboardRepositoryImpl's recent-inquiries preview.
  @override
  Future<ApiResult<InquiriesOverview>> getInquiries({
    required String token,
  }) async {
    try {
      final response = await _remoteDataSource.getInquiries(token: token);
      final body = response.data as Map<String, dynamic>;
      final inquiriesJson = extractJsonList(
        body,
        source: 'GET /pharmacy/inquiries',
      );

      final inquiries = <Inquiry>[];
      for (final json in inquiriesJson) {
        try {
          inquiries.add(
            InquiryModel.fromJson(json as Map<String, dynamic>).toEntity(),
          );
        } catch (_) {
          // Skip just this record.
        }
      }

      final counts = body['counts'] as Map<String, dynamic>? ?? const {};
      return Success(
        InquiriesOverview(
          inquiries: inquiries,
          newCount: (counts['new'] as num?)?.toInt() ?? 0,
          answeredCount: (counts['answered'] as num?)?.toInt() ?? 0,
          closedCount: (counts['closed'] as num?)?.toInt() ?? 0,
        ),
      );
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> updateInquiryStatus({
    required String token,
    required int inquiryId,
    required InquiryStatus status,
  }) async {
    try {
      await _remoteDataSource.updateStatus(
        token: token,
        inquiryId: inquiryId,
        status: inquiryStatusToWire(status),
      );
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
