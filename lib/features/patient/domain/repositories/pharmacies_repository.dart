import '../../../../core/helpers/api_result.dart';
import '../entities/nearby_pharmacy.dart';

abstract class PharmaciesRepository {
  /// `GET /pharmacies` — called WITHOUT `latitude`/`longitude` (that
  /// combination 500s on the live backend, probed 2026-09-27; see
  /// reference-backend-quirks memory). [userLatitude]/[userLongitude], when
  /// given, are used to compute and attach each row's [NearbyPharmacy.distanceKm]
  /// client-side instead, and the list comes back sorted nearest-first.
  Future<ApiResult<List<NearbyPharmacy>>> getNearbyPharmacies({
    double? userLatitude,
    double? userLongitude,
  });

  /// `GET /pharmacies/{id}` — a working-hours label for today, or null when
  /// the backend has none set or the shape can't be read (see
  /// PharmaciesRepositoryImpl's doc comment on `hours`).
  Future<ApiResult<String?>> getWorkingHoursLabel(int pharmacyId);
}
