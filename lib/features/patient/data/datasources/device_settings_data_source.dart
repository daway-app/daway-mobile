import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Thin wrapper over the platform plugins (`permission_handler`,
/// `geolocator`), so [DevicePermissionsRepositoryImpl]'s logic can be tested
/// against a fake instead of a method channel.
class DeviceSettingsDataSource {
  const DeviceSettingsDataSource();

  Future<bool> isNotificationPermissionGranted() => Permission.notification.isGranted;

  Future<bool> isLocationServiceEnabled() => Geolocator.isLocationServiceEnabled();

  Future<bool> isLocationPermissionGranted() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
