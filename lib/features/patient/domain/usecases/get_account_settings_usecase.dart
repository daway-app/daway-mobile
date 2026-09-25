import '../../../../core/helpers/api_result.dart';
import '../entities/account_settings.dart';
import '../repositories/app_info_repository.dart';
import '../repositories/device_permissions_repository.dart';

/// Reads everything the settings screen shows in one go. The two permission
/// reads are required (a failure in either fails the whole call); the app
/// version is decorative, so a failed read just leaves it out.
class GetAccountSettingsUseCase {
  final DevicePermissionsRepository _permissions;
  final AppInfoRepository _appInfo;

  const GetAccountSettingsUseCase(this._permissions, this._appInfo);

  Future<ApiResult<AccountSettings>> call() async {
    final (notifications, location, version) = await (
      _permissions.isNotificationsEnabled(),
      _permissions.isLocationEnabled(),
      _appInfo.getVersion(),
    ).wait;

    switch ((notifications, location)) {
      case (Success<bool>(data: final notificationsEnabled), Success<bool>(data: final locationEnabled)):
        return Success(
          AccountSettings(
            notificationsEnabled: notificationsEnabled,
            locationEnabled: locationEnabled,
            appVersion: switch (version) {
              Success(:final data) => data,
              ApiError() => null,
            },
          ),
        );
      case (ApiError<bool>(:final failure), _):
        return ApiError(failure);
      case (_, ApiError<bool>(:final failure)):
        return ApiError(failure);
    }
  }
}
