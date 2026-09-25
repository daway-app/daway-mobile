import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/domain/entities/account_settings.dart';
import 'package:daway_app/features/patient/domain/entities/device_setting.dart';
import 'package:daway_app/features/patient/domain/repositories/app_info_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/device_permissions_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_account_settings_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePermissions implements DevicePermissionsRepository {
  ApiResult<bool> notifications = const Success(true);
  ApiResult<bool> location = const Success(false);

  @override
  Future<ApiResult<bool>> isNotificationsEnabled() async => notifications;

  @override
  Future<ApiResult<bool>> isLocationEnabled() async => location;

  @override
  Future<ApiResult<void>> openSettings(DeviceSetting setting) async => const Success(null);
}

class _FakeAppInfo implements AppInfoRepository {
  ApiResult<String> version = const Success('1.0.0');

  @override
  Future<ApiResult<String>> getVersion() async => version;
}

void main() {
  late _FakePermissions permissions;
  late _FakeAppInfo appInfo;
  late GetAccountSettingsUseCase useCase;

  setUp(() {
    permissions = _FakePermissions();
    appInfo = _FakeAppInfo();
    useCase = GetAccountSettingsUseCase(permissions, appInfo);
  });

  test('combines the two permission reads and the app version', () async {
    final result = await useCase();

    expect(result, isA<Success<AccountSettings>>());
    final settings = (result as Success<AccountSettings>).data;
    expect(settings.notificationsEnabled, isTrue);
    expect(settings.locationEnabled, isFalse);
    expect(settings.appVersion, '1.0.0');
  });

  test('a failed version read only leaves the version out', () async {
    appInfo.version = const ApiError(UnknownFailure('boom'));

    final result = await useCase();

    expect(result, isA<Success<AccountSettings>>());
    final settings = (result as Success<AccountSettings>).data;
    expect(settings.appVersion, isNull);
    expect(settings.notificationsEnabled, isTrue);
  });

  test('a failed notifications read fails the whole call with that failure', () async {
    permissions.notifications = const ApiError(PermissionFailure('no notifications'));

    final result = await useCase();

    expect(result, isA<ApiError<AccountSettings>>());
    expect((result as ApiError<AccountSettings>).failure.message, 'no notifications');
  });

  test('a failed location read fails the whole call with that failure', () async {
    permissions.location = const ApiError(PermissionFailure('no location'));

    final result = await useCase();

    expect(result, isA<ApiError<AccountSettings>>());
    expect((result as ApiError<AccountSettings>).failure.message, 'no location');
  });
}
