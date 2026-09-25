import '../../../../core/helpers/api_result.dart';
import '../entities/device_setting.dart';
import '../repositories/device_permissions_repository.dart';

class OpenDeviceSettingsUseCase {
  final DevicePermissionsRepository _repository;

  const OpenDeviceSettingsUseCase(this._repository);

  Future<ApiResult<void>> call(DeviceSetting setting) => _repository.openSettings(setting);
}
