import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../../core/helpers/json_list_extractor.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/entities/medicine_catalog_item.dart';
import '../../domain/repositories/pharmacy_medicine_repository.dart';
import '../datasources/pharmacy_medicine_remote_data_source.dart';
import '../models/medicine_catalog_item_model.dart';
import '../models/medicine_model.dart';

class PharmacyMedicineRepositoryImpl implements PharmacyMedicineRepository {
  final PharmacyMedicineRemoteDataSource _remoteDataSource;

  const PharmacyMedicineRepositoryImpl(this._remoteDataSource);

  /// `GET /pharmacy/medicines/search` splits its results across two arrays
  /// (confirmed against a live response) instead of the generic
  /// `data`/`data.data` shapes [extractJsonList] handles: `data.medicines`
  /// is the pharmacy's own general catalog, `data.moh_catalog` is the
  /// Ministry of Health database — both are shown together as one
  /// suggestion list.
  List<dynamic> _extractSearchResults(Object? data) {
    if (data is Map<String, dynamic>) {
      final payload = data['data'];
      if (payload is Map<String, dynamic> &&
          (payload['medicines'] is List || payload['moh_catalog'] is List)) {
        return [
          ...?(payload['medicines'] as List?),
          ...?(payload['moh_catalog'] as List?),
        ];
      }
    }
    return extractJsonList(data);
  }

  @override
  Future<ApiResult<List<Medicine>>> getMedicines({required String token}) async {
    try {
      final response = await _remoteDataSource.getMedicines(token: token);
      final medicines = extractJsonList(response.data, source: 'GET /pharmacy/medicines')
          .map((json) => MedicineModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
      return Success(medicines);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<List<MedicineCatalogItem>>> searchCatalog({
    required String token,
    required String query,
  }) async {
    try {
      final response = await _remoteDataSource.searchCatalog(token: token, query: query);
      final items = _extractSearchResults(response.data)
          .map((json) =>
              MedicineCatalogItemModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
      return Success(items);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> addMedicine({
    required String token,
    int? medicineId,
    int? mohMedicineId,
    required double price,
    required int quantity,
    required bool isAvailable,
    String? imageUrl,
  }) async {
    try {
      await _remoteDataSource.addMedicine(
        token: token,
        body: {
          'medicine_id': ?medicineId,
          'moh_medicine_id': ?mohMedicineId,
          'price': price,
          'quantity': quantity,
          'is_available': isAvailable,
          'image_url': ?imageUrl,
        },
      );
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> addMedicineByName({
    required String token,
    required String tradeName,
    String? tradeNameAr,
    String? activeIngredient,
    required double price,
    required int quantity,
    required bool isAvailable,
    String? imageUrl,
  }) async {
    try {
      await _remoteDataSource.addMedicineByName(
        token: token,
        body: {
          'trade_name': tradeName,
          'trade_name_ar': ?tradeNameAr,
          'active_ingredient': ?activeIngredient,
          'price': price,
          'quantity': quantity,
          'is_available': isAvailable,
          'image_url': ?imageUrl,
        },
      );
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> deleteMedicine({
    required String token,
    required int pharmacyMedicineId,
  }) async {
    try {
      await _remoteDataSource.deleteMedicine(token: token, pharmacyMedicineId: pharmacyMedicineId);
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> updateMedicine({
    required String token,
    required int pharmacyMedicineId,
    required int medicineId,
    required double price,
    required int quantity,
    required bool isAvailable,
  }) async {
    try {
      await _remoteDataSource.updateMedicine(
        token: token,
        pharmacyMedicineId: pharmacyMedicineId,
        body: {
          'medicine_id': medicineId,
          'price': price,
          'quantity': quantity,
          'is_available': isAvailable,
        },
      );
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
