import '../../../../core/erroring/error_handler.dart';
import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/device_setting.dart';
import '../../domain/repositories/device_permissions_repository.dart';
import '../datasources/device_settings_data_source.dart';

class DevicePermissionsRepositoryImpl implements DevicePermissionsRepository {
  final DeviceSettingsDataSource _dataSource;

  const DevicePermissionsRepositoryImpl(this._dataSource);

  @override
  Future<ApiResult<bool>> isNotificationsEnabled() async {
    try {
      return Success(await _dataSource.isNotificationPermissionGranted());
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  /// Location counts as enabled only when the device's location service is
  /// on AND this app has been allowed to use it.
  @override
  Future<ApiResult<bool>> isLocationEnabled() async {
    try {
      if (!await _dataSource.isLocationServiceEnabled()) return const Success(false);
      return Success(await _dataSource.isLocationPermissionGranted());
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> openSettings(DeviceSetting setting) async {
    try {
      final opened = await _open(setting);
      if (opened) return const Success(null);
      return const ApiError(PermissionFailure('تعذر فتح إعدادات الجهاز'));
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  Future<bool> _open(DeviceSetting setting) async {
    switch (setting) {
      case DeviceSetting.notifications:
        return _dataSource.openAppSettings();
      case DeviceSetting.location:
        // With the location service itself off, the app's own settings page
        // can't help — send the user to the device's location settings.
        final serviceEnabled = await _dataSource.isLocationServiceEnabled();
        return serviceEnabled
            ? _dataSource.openAppSettings()
            : _dataSource.openLocationSettings();
    }
  }
}
