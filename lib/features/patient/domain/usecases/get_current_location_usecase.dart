import '../../../../core/helpers/api_result.dart';
import '../../../../core/models/picked_location.dart';
import '../repositories/location_repository.dart';

class GetCurrentLocationUseCase {
  final LocationRepository _repository;

  const GetCurrentLocationUseCase(this._repository);

  Future<ApiResult<PickedLocation>> call() => _repository.getCurrentLocation();
}
