import '../../../../core/helpers/api_result.dart';
import '../repositories/location_repository.dart';

class ReverseGeocodeUseCase {
  final LocationRepository _repository;

  const ReverseGeocodeUseCase(this._repository);

  Future<ApiResult<String>> call({
    required double latitude,
    required double longitude,
  }) {
    return _repository.reverseGeocode(latitude: latitude, longitude: longitude);
  }
}
