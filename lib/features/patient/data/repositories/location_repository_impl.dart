import 'package:flutter/widgets.dart' show Locale;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/erroring/error_handler.dart';
import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../../core/models/picked_location.dart';
import '../../domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final Geocoding _geocoding = Geocoding();

  // Geocoders default to the device's locale; the app is Arabic-only, so
  // every place name/address it returns should be too.
  static const _arabic = Locale('ar');

  LocationRepositoryImpl();

  @override
  Future<ApiResult<PickedLocation>> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const ApiError(
        PermissionFailure('خدمة تحديد الموقع غير مفعّلة على جهازك، يرجى تفعيلها'),
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return const ApiError(
        PermissionFailure('يرجى السماح بالوصول لموقعك لتحديد عنوانك، أو اختر الموقع يدوياً'),
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final addressResult = await reverseGeocode(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      final address = switch (addressResult) {
        Success(:final data) => data,
        ApiError() => '',
      };
      return Success(PickedLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      ));
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<String>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
        locale: _arabic,
      );
      if (placemarks.isEmpty) return const Success('');

      final placemark = placemarks.first;
      final parts = <String?>[
        placemark.locality,
        placemark.administrativeArea,
        placemark.country,
      ].whereType<String>().where((part) => part.trim().isNotEmpty).toList();
      return Success(parts.isNotEmpty ? parts.join('، ') : (placemark.name ?? ''));
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<PickedLocation>> searchAddress(String query) async {
    try {
      final locations = await _geocoding.locationFromAddress(query, locale: _arabic);
      if (locations.isEmpty) {
        return const ApiError(ValidationFailure('لم يتم العثور على هذا العنوان'));
      }

      final location = locations.first;
      final addressResult = await reverseGeocode(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      final address = switch (addressResult) {
        Success(:final data) => data.isNotEmpty ? data : query,
        ApiError() => query,
      };
      return Success(PickedLocation(
        latitude: location.latitude,
        longitude: location.longitude,
        address: address,
      ));
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
