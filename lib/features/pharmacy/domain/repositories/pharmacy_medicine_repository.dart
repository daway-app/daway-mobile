import '../../../../core/helpers/api_result.dart';
import '../entities/medicine.dart';
import '../entities/medicine_catalog_item.dart';

abstract class PharmacyMedicineRepository {
  Future<ApiResult<List<Medicine>>> getMedicines({required String token});

  Future<ApiResult<List<MedicineCatalogItem>>> searchCatalog({
    required String token,
    required String query,
  });

  /// Exactly one of [medicineId] (the pharmacy's own general catalog) or
  /// [mohMedicineId] (a Ministry of Health entry) is required — confirmed
  /// against a live 422 response naming both as the only valid options.
  /// There is no `min_stock` parameter: the backend fixed the low-stock
  /// threshold internally at 10 for every pharmacy.
  Future<ApiResult<void>> addMedicine({
    required String token,
    int? medicineId,
    int? mohMedicineId,
    required double price,
    required int quantity,
    required bool isAvailable,
    String? imageUrl,
  });

  /// Adds a medicine that isn't in either catalog yet, by name — the
  /// backend matches or creates a catalog entry server-side. [tradeName]
  /// must be English only (the backend rejects Arabic with a 422);
  /// [tradeNameAr] is the optional Arabic name.
  Future<ApiResult<void>> addMedicineByName({
    required String token,
    required String tradeName,
    String? tradeNameAr,
    String? activeIngredient,
    required double price,
    required int quantity,
    required bool isAvailable,
    String? imageUrl,
  });

  Future<ApiResult<void>> deleteMedicine({
    required String token,
    required int pharmacyMedicineId,
  });

  /// Updates an existing `pharmacy_medicine` record's stock fields plus the
  /// shared catalog entry's trade name / active ingredient (confirmed
  /// against a live `PUT /pharmacy/medicines/{id}` response — the catalog
  /// fields are included in the same request). [medicineId] is the catalog
  /// medicine's id (`Medicine.medicineId`, distinct from
  /// [pharmacyMedicineId]) — the backend requires it in the body even
  /// though the record being updated is already identified by the path.
  /// [tradeName] must be English only, same as `addMedicineByName`.
  /// [tradeNameAr] isn't user-editable here — pass the medicine's existing
  /// value through unchanged so the update doesn't clear it.
  Future<ApiResult<void>> updateMedicine({
    required String token,
    required int pharmacyMedicineId,
    required int medicineId,
    required String tradeName,
    String? tradeNameAr,
    String? activeIngredient,
    required double price,
    required int quantity,
    required bool isAvailable,
  });
}
