import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../../core/helpers/json_list_extractor.dart';
import '../../domain/entities/inventory_item_update.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/repositories/pharmacy_inventory_repository.dart';
import '../datasources/pharmacy_inventory_remote_data_source.dart';
import '../models/medicine_model.dart';

class PharmacyInventoryRepositoryImpl implements PharmacyInventoryRepository {
  final PharmacyInventoryRemoteDataSource _remoteDataSource;

  const PharmacyInventoryRepositoryImpl(this._remoteDataSource);

  /// `GET /pharmacy/inventory` returns `pharmacy_medicine` records shaped
  /// the same as `GET /pharmacy/medicines` (same [MedicineModel] parses
  /// both), but the exact envelope for this particular endpoint hasn't been
  /// confirmed against a live response — [extractJsonList] tolerates the
  /// common shapes instead of assuming one. Any `stats`/summary object the
  /// response may also include is intentionally ignored: the header counts
  /// are tallied from these same items client-side (via [Medicine.status]),
  /// so they can't drift from what the list itself shows.
  @override
  Future<ApiResult<List<Medicine>>> getInventory({required String token}) async {
    try {
      final response = await _remoteDataSource.getInventory(token: token);
      final medicines = extractJsonList(response.data, source: 'GET /pharmacy/inventory')
          .map((json) => MedicineModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
      return Success(medicines);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> updateInventory({
    required String token,
    required List<InventoryItemUpdate> items,
  }) async {
    try {
      await _remoteDataSource.bulkUpdate(
        token: token,
        body: {
          'items': items
              .map((item) => {
                    'id': item.pharmacyMedicineId,
                    'quantity': item.quantity,
                    'is_available': item.isAvailable,
                  })
              .toList(),
        },
      );
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
