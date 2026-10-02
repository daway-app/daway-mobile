import '../../../../core/helpers/api_result.dart';
import '../entities/nearby_pharmacy.dart';
import '../repositories/pharmacies_repository.dart';

class GetNearbyPharmaciesUseCase {
  final PharmaciesRepository _repository;

  const GetNearbyPharmaciesUseCase(this._repository);

  Future<ApiResult<List<NearbyPharmacy>>> call({
    double? userLatitude,
    double? userLongitude,
  }) {
    return _repository.getNearbyPharmacies(
      userLatitude: userLatitude,
      userLongitude: userLongitude,
    );
  }
}
