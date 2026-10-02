import '../../../../core/helpers/api_result.dart';
import '../entities/medicine_detail.dart';
import '../entities/medicine_pharmacy_offer.dart';

abstract class MedicineDetailRepository {
  Future<ApiResult<MedicineDetail>> getMedicineDetail({
    required int medicineId,
    double? latitude,
    double? longitude,
  });

  Future<ApiResult<List<MedicinePharmacyOffer>>> getMedicinePharmacies({
    required int medicineId,
    double? latitude,
    double? longitude,
  });
}
