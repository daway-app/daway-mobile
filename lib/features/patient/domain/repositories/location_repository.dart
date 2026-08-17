import '../../../../core/helpers/api_result.dart';
import '../entities/picked_location.dart';

abstract class LocationRepository {
  /// Requests GPS permission if needed, then resolves the device's current
  /// coordinates and their reverse-geocoded address.
  Future<ApiResult<PickedLocation>> getCurrentLocation();

  /// Converts coordinates (e.g. from a dragged map pin) into a display address.
  Future<ApiResult<String>> reverseGeocode({
    required double latitude,
    required double longitude,
  });

  /// Forward-geocodes a free-text search query into coordinates + address.
  Future<ApiResult<PickedLocation>> searchAddress(String query);
}
