import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/domain/entities/device_setting.dart';
import 'package:daway_app/features/patient/domain/repositories/device_permissions_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/open_device_settings_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePermissions implements DevicePermissionsRepository {
  ApiResult<void> result = const Success(null);
  DeviceSetting? lastSetting;

  @override
  Future<ApiResult<bool>> isNotificationsEnabled() async => const Success(true);

  @override
  Future<ApiResult<bool>> isLocationEnabled() async => const Success(true);

  @override
  Future<ApiResult<void>> openSettings(DeviceSetting setting) async {
    lastSetting = setting;
    return result;
  }
}

void main() {
  test('forwards the requested setting to the repository', () async {
    final permissions = _FakePermissions();
    final useCase = OpenDeviceSettingsUseCase(permissions);

    final result = await useCase(DeviceSetting.location);

    expect(permissions.lastSetting, DeviceSetting.location);
    expect(result, isA<Success<void>>());
  });

  test('passes a repository failure straight through', () async {
    final permissions = _FakePermissions()
      ..result = const ApiError(PermissionFailure('cannot open'));
    final useCase = OpenDeviceSettingsUseCase(permissions);

    final result = await useCase(DeviceSetting.notifications);

    expect(result, isA<ApiError<void>>());
    expect((result as ApiError<void>).failure.message, 'cannot open');
  });
}
