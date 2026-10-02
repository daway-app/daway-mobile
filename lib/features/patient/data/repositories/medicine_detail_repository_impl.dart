import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../../core/helpers/json_list_extractor.dart';
import '../../domain/entities/medicine_detail.dart';
import '../../domain/entities/medicine_pharmacy_offer.dart';
import '../../domain/repositories/medicine_detail_repository.dart';
import '../datasources/medicine_detail_remote_data_source.dart';
import '../models/medicine_detail_model.dart';
import '../models/medicine_pharmacy_offer_model.dart';

class MedicineDetailRepositoryImpl implements MedicineDetailRepository {
  final MedicineDetailRemoteDataSource _remoteDataSource;

  const MedicineDetailRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<MedicineDetail>> getMedicineDetail({
    required int medicineId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _remoteDataSource.getMedicine(
        medicineId: medicineId,
        latitude: latitude,
        longitude: longitude,
      );
      final model = MedicineDetailModel.fromJson(response.data as Map<String, dynamic>);
      return Success(model.toEntity());
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<List<MedicinePharmacyOffer>>> getMedicinePharmacies({
    required int medicineId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _remoteDataSource.getMedicinePharmacies(
        medicineId: medicineId,
        latitude: latitude,
        longitude: longitude,
      );
      final offersJson = extractJsonList(
        response.data,
        source: 'GET /medicines/{id}/pharmacies',
      );
      final offers = offersJson
          .map((json) =>
              MedicinePharmacyOfferModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
      return Success(offers);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
