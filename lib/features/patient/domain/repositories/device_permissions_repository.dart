import '../../../../core/helpers/api_result.dart';
import '../entities/device_setting.dart';

abstract class DevicePermissionsRepository {
  /// Whether the OS currently allows this app to show notifications.
  Future<ApiResult<bool>> isNotificationsEnabled();

  /// Whether the device's location service is on AND this app may use it.
  Future<ApiResult<bool>> isLocationEnabled();

  /// Opens the system screen where the user can change [setting] — the app's
  /// own settings page, or the device's location settings when the location
  /// service itself is switched off.
  Future<ApiResult<void>> openSettings(DeviceSetting setting);
}
