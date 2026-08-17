import '../../../../core/helpers/api_result.dart';
import '../entities/picked_location.dart';
import '../repositories/location_repository.dart';

class SearchAddressUseCase {
  final LocationRepository _repository;

  const SearchAddressUseCase(this._repository);

  Future<ApiResult<PickedLocation>> call(String query) => _repository.searchAddress(query);
}
