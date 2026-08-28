import '../../../../core/helpers/api_result.dart';
import '../entities/inventory_item_update.dart';
import '../entities/medicine.dart';

abstract class PharmacyInventoryRepository {
  /// `GET /pharmacy/inventory` — the same `pharmacy_medicine` records as
  /// [Medicine], scoped to the dedicated stock-taking endpoint (which also
  /// backs the bulk update below) rather than the medicines-management one.
  Future<ApiResult<List<Medicine>>> getInventory({required String token});

  /// `POST /pharmacy/inventory/bulk` — updates quantity/availability for
  /// several items in one request.
  Future<ApiResult<void>> updateInventory({
    required String token,
    required List<InventoryItemUpdate> items,
  });
}
