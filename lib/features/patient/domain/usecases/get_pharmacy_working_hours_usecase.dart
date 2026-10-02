import '../../../../core/helpers/api_result.dart';
import '../repositories/pharmacies_repository.dart';

class GetPharmacyWorkingHoursUseCase {
  final PharmaciesRepository _repository;

  const GetPharmacyWorkingHoursUseCase(this._repository);

  Future<ApiResult<String?>> call(int pharmacyId) =>
      _repository.getWorkingHoursLabel(pharmacyId);
}
