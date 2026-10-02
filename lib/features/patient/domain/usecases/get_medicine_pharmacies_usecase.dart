import '../../../../core/helpers/api_result.dart';
import '../entities/medicine_pharmacy_offer.dart';
import '../repositories/medicine_detail_repository.dart';

/// `GET /medicines/{id}/pharmacies` is public (no auth token) — it carries
/// the per-pharmacy price this screen needs, unlike the auth-scoped
/// `GET /patient/medicines/{id}/availability`.
class GetMedicinePharmaciesUseCase {
  final MedicineDetailRepository _repository;

  const GetMedicinePharmaciesUseCase(this._repository);

  Future<ApiResult<List<MedicinePharmacyOffer>>> call({
    required int medicineId,
    double? latitude,
    double? longitude,
  }) {
    return _repository.getMedicinePharmacies(
      medicineId: medicineId,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
