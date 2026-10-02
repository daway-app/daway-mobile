import '../../../../core/helpers/api_result.dart';
import '../entities/medicine_detail.dart';
import '../repositories/medicine_detail_repository.dart';

/// `GET /medicines/{id}` is public (no auth token), same as
/// [GetMedicinePharmaciesUseCase].
class GetMedicineDetailUseCase {
  final MedicineDetailRepository _repository;

  const GetMedicineDetailUseCase(this._repository);

  Future<ApiResult<MedicineDetail>> call({
    required int medicineId,
    double? latitude,
    double? longitude,
  }) {
    return _repository.getMedicineDetail(
      medicineId: medicineId,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
