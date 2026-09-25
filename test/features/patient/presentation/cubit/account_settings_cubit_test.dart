import 'dart:async';

import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/domain/entities/device_setting.dart';
import 'package:daway_app/features/patient/domain/repositories/app_info_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/device_permissions_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_account_settings_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/open_device_settings_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/account_settings_cubit.dart';
import 'package:daway_app/features/patient/presentation/cubit/account_settings_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePermissions implements DevicePermissionsRepository {
  ApiResult<bool> notifications = const Success(true);
  ApiResult<bool> location = const Success(false);
  ApiResult<void> openResult = const Success(null);
  DeviceSetting? lastOpened;
  int reads = 0;

  /// When set, the next read waits for it — after capturing the values it
  /// will report, so it reports a stale snapshot if released late.
  Completer<void>? holdNextRead;

  @override
  Future<ApiResult<bool>> isNotificationsEnabled() async {
    reads++;
    final captured = notifications;
    final hold = holdNextRead;
    if (hold != null) {
      holdNextRead = null;
      await hold.future;
    }
    return captured;
  }

  @override
  Future<ApiResult<bool>> isLocationEnabled() async => location;

  @override
  Future<ApiResult<void>> openSettings(DeviceSetting setting) async {
    lastOpened = setting;
    return openResult;
  }
}

class _FakeAppInfo implements AppInfoRepository {
  @override
  Future<ApiResult<String>> getVersion() async => const Success('1.0.0');
}

void main() {
  late _FakePermissions permissions;

  AccountSettingsCubit buildCubit() {
    final cubit = AccountSettingsCubit(
      GetAccountSettingsUseCase(permissions, _FakeAppInfo()),
      OpenDeviceSettingsUseCase(permissions),
    );
    addTearDown(cubit.close);
    return cubit;
  }

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  AccountSettingsLoaded loaded(AccountSettingsCubit cubit) => cubit.state as AccountSettingsLoaded;

  setUp(() {
    permissions = _FakePermissions();
  });

  test('starts loading, then emits the device settings', () async {
    final cubit = buildCubit();
    expect(cubit.state, isA<AccountSettingsLoading>());

    await settle();

    expect(cubit.state, isA<AccountSettingsLoaded>());
    expect(loaded(cubit).settings.notificationsEnabled, isTrue);
    expect(loaded(cubit).settings.locationEnabled, isFalse);
    expect(loaded(cubit).settings.appVersion, '1.0.0');
  });

  test('surfaces a load failure, and load() retries it', () async {
    permissions.notifications = const ApiError(PermissionFailure('تعذر القراءة'));
    final cubit = buildCubit();
    await settle();
    expect(cubit.state, isA<AccountSettingsLoadFailure>());
    expect((cubit.state as AccountSettingsLoadFailure).message, 'تعذر القراءة');

    permissions.notifications = const Success(true);
    await cubit.load();

    expect(cubit.state, isA<AccountSettingsLoaded>());
  });

  group('refresh', () {
    test('re-reads the device state without flashing the loading state', () async {
      final cubit = buildCubit();
      await settle();
      final states = <AccountSettingsState>[];
      final subscription = cubit.stream.listen(states.add);
      addTearDown(subscription.cancel);

      permissions.notifications = const Success(false);
      await cubit.refresh();
      await settle(); // stream events are delivered asynchronously

      expect(states, hasLength(1));
      expect(states.single, isA<AccountSettingsLoaded>());
      expect(loaded(cubit).settings.notificationsEnabled, isFalse);
    });

    test('keeps the values already shown when the re-read fails', () async {
      final cubit = buildCubit();
      await settle();

      permissions.notifications = const ApiError(PermissionFailure('boom'));
      await cubit.refresh();

      expect(cubit.state, isA<AccountSettingsLoaded>());
      expect(loaded(cubit).settings.notificationsEnabled, isTrue);
    });

    test('does nothing while there is nothing loaded to refresh', () async {
      permissions.notifications = const ApiError(PermissionFailure('boom'));
      final cubit = buildCubit();
      await settle();
      final readsBefore = permissions.reads;

      await cubit.refresh();

      expect(permissions.reads, readsBefore);
      expect(cubit.state, isA<AccountSettingsLoadFailure>());
    });

    test('a slow older read cannot overwrite a newer one', () async {
      final cubit = buildCubit();
      await settle(); // loaded with notifications == true

      // An older refresh is still in flight, holding the stale "true"...
      permissions.holdNextRead = Completer<void>();
      final hold = permissions.holdNextRead!;
      final slowRefresh = cubit.refresh();
      await settle();

      // ...when a newer read (a retry) completes with the new "false".
      permissions.notifications = const Success(false);
      await cubit.load();
      expect(loaded(cubit).settings.notificationsEnabled, isFalse);

      hold.complete();
      await slowRefresh;

      expect(loaded(cubit).settings.notificationsEnabled, isFalse);
    });
  });

  group('openSettings', () {
    test('sends the request through and returns null on success', () async {
      final cubit = buildCubit();
      await settle();

      final error = await cubit.openSettings(DeviceSetting.location);

      expect(error, isNull);
      expect(permissions.lastOpened, DeviceSetting.location);
    });

    test('returns the failure message when the system screen cannot be opened', () async {
      permissions.openResult = const ApiError(PermissionFailure('تعذر فتح إعدادات الجهاز'));
      final cubit = buildCubit();
      await settle();

      final error = await cubit.openSettings(DeviceSetting.notifications);

      expect(error, 'تعذر فتح إعدادات الجهاز');
    });
  });

  test('closing while the first read is in flight does not throw', () async {
    final hold = Completer<void>();
    permissions.holdNextRead = hold;
    final cubit = AccountSettingsCubit(
      GetAccountSettingsUseCase(permissions, _FakeAppInfo()),
      OpenDeviceSettingsUseCase(permissions),
    );
    await settle();

    await cubit.close();
    hold.complete();
    await settle();
    await settle();

    // Reaching here means no uncaught "emit after close" error failed the test.
    expect(cubit.isClosed, isTrue);
  });
}
