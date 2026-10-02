import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/haversine_distance.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../../core/helpers/json_list_extractor.dart';
import '../../domain/entities/nearby_pharmacy.dart';
import '../../domain/repositories/pharmacies_repository.dart';
import '../datasources/pharmacies_remote_data_source.dart';
import '../models/nearby_pharmacy_model.dart';

class PharmaciesRepositoryImpl implements PharmaciesRepository {
  final PharmaciesRemoteDataSource _remoteDataSource;

  const PharmaciesRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<List<NearbyPharmacy>>> getNearbyPharmacies({
    double? userLatitude,
    double? userLongitude,
  }) async {
    try {
      final response = await _remoteDataSource.getPharmacies();
      final pharmaciesJson = extractJsonList(response.data, source: 'GET /pharmacies');
      var pharmacies = pharmaciesJson
          .map((json) => NearbyPharmacyModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      if (userLatitude != null && userLongitude != null) {
        pharmacies = pharmacies
            .map((pharmacy) => pharmacy.copyWith(
                  distanceKm: haversineDistanceKm(
                    startLatitude: userLatitude,
                    startLongitude: userLongitude,
                    endLatitude: pharmacy.latitude,
                    endLongitude: pharmacy.longitude,
                  ),
                ))
            .toList()
          ..sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));
      }

      return Success(pharmacies);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<String?>> getWorkingHoursLabel(int pharmacyId) async {
    try {
      final response = await _remoteDataSource.getPharmacyDetail(pharmacyId);
      final body = response.data;
      final data = body is Map<String, dynamic> ? body['data'] : null;
      final hours = data is Map<String, dynamic> ? data['hours'] : null;
      return Success(_formatTodaysHours(hours));
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  /// Best-effort: every pharmacy seeded on the live backend has an empty
  /// `hours` array (probed 2026-09-27), so the populated shape has never
  /// been observed — this tries the field-name spellings the rest of the
  /// API uses elsewhere (`open`/`close`, `day`) and simply shows nothing
  /// rather than a wrong or fabricated time when the shape doesn't match.
  /// Re-check this against a real populated pharmacy once one exists.
  String? _formatTodaysHours(Object? hours) {
    if (hours is! List || hours.isEmpty) return null;

    const englishDayKeys = [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
    ];
    final today = englishDayKeys[DateTime.now().weekday % 7];

    Map<String, dynamic>? entry;
    for (final row in hours) {
      if (row is! Map<String, dynamic>) continue;
      final day = (row['day'] ?? row['weekday'] ?? row['day_of_week']) as String?;
      if (day == null || day.toLowerCase() == today) {
        entry = row;
        break;
      }
    }
    entry ??= hours.first is Map<String, dynamic> ? hours.first as Map<String, dynamic> : null;
    if (entry == null) return null;

    final open = (entry['open'] ?? entry['from'] ?? entry['opens_at'] ?? entry['open_time'])
        as String?;
    final close = (entry['close'] ?? entry['to'] ?? entry['closes_at'] ?? entry['close_time'])
        as String?;
    if (open == null || close == null) return null;

    final formattedOpen = _formatHhMm(open);
    final formattedClose = _formatHhMm(close);
    if (formattedOpen == null || formattedClose == null) return null;
    return '$formattedOpen - $formattedClose';
  }

  /// "09:00" -> "9 ص", "22:00" -> "10 م" — null on anything else.
  String? _formatHhMm(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    if (hour == null || hour < 0 || hour > 23) return null;

    final period = hour < 12 ? 'ص' : 'م';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour $period';
  }
}
