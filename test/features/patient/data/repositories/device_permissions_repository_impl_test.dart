import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/data/datasources/device_settings_data_source.dart';
import 'package:daway_app/features/patient/data/repositories/device_permissions_repository_impl.dart';
import 'package:daway_app/features/patient/domain/entities/device_setting.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDataSource implements DeviceSettingsDataSource {
  bool notificationGranted = true;
  bool locationServiceEnabled = true;
  bool locationPermissionGranted = true;
  bool canOpenSettings = true;
  bool throws = false;

  final List<String> calls = [];

  void _maybeThrow() {
    if (throws) throw StateError('plugin failure');
  }

  @override
  Future<bool> isNotificationPermissionGranted() async {
    calls.add('notificationPermission');
    _maybeThrow();
    return notificationGranted;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    calls.add('locationService');
    _maybeThrow();
    return locationServiceEnabled;
  }

  @override
  Future<bool> isLocationPermissionGranted() async {
    calls.add('locationPermission');
    _maybeThrow();
    return locationPermissionGranted;
  }

  @override
  Future<bool> openAppSettings() async {
    calls.add('openAppSettings');
    _maybeThrow();
    return canOpenSettings;
  }

  @override
  Future<bool> openLocationSettings() async {
    calls.add('openLocationSettings');
    _maybeThrow();
    return canOpenSettings;
  }
}

void main() {
  late _FakeDataSource dataSource;
  late DevicePermissionsRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeDataSource();
    repository = DevicePermissionsRepositoryImpl(dataSource);
  });

  group('isNotificationsEnabled', () {
    test('mirrors the OS notification permission', () async {
      dataSource.notificationGranted = false;
      final denied = await repository.isNotificationsEnabled();
      dataSource.notificationGranted = true;
      final granted = await repository.isNotificationsEnabled();

      expect((denied as Success<bool>).data, isFalse);
      expect((granted as Success<bool>).data, isTrue);
    });

    test('maps a plugin exception to a failure', () async {
      dataSource.throws = true;

      final result = await repository.isNotificationsEnabled();

      expect(result, isA<ApiError<bool>>());
      expect((result as ApiError<bool>).failure, isA<UnknownFailure>());
    });
  });

  group('isLocationEnabled', () {
    test('is on only when the service is on AND the app is allowed to use it', () async {
      final result = await repository.isLocationEnabled();

      expect((result as Success<bool>).data, isTrue);
    });

    test('is off when the app is not allowed, even with the service on', () async {
      dataSource.locationPermissionGranted = false;

      final result = await repository.isLocationEnabled();

      expect((result as Success<bool>).data, isFalse);
    });

    test('is off when the device location service is off, without asking about permission', () async {
      dataSource.locationServiceEnabled = false;

      final result = await repository.isLocationEnabled();

      expect((result as Success<bool>).data, isFalse);
      expect(dataSource.calls, isNot(contains('locationPermission')));
    });

    test('maps a plugin exception to a failure', () async {
      dataSource.throws = true;

      final result = await repository.isLocationEnabled();

      expect(result, isA<ApiError<bool>>());
    });
  });

  group('openSettings', () {
    test('notifications opens the app settings page', () async {
      final result = await repository.openSettings(DeviceSetting.notifications);

      expect(result, isA<Success<void>>());
      expect(dataSource.calls, ['openAppSettings']);
    });

    test('location opens the app settings page while the location service is on', () async {
      final result = await repository.openSettings(DeviceSetting.location);

      expect(result, isA<Success<void>>());
      expect(dataSource.calls, ['locationService', 'openAppSettings']);
    });

    test('location opens the device location settings when the service itself is off', () async {
      dataSource.locationServiceEnabled = false;

      final result = await repository.openSettings(DeviceSetting.location);

      expect(result, isA<Success<void>>());
      expect(dataSource.calls, ['locationService', 'openLocationSettings']);
    });

    test('reports a failure when the system screen could not be opened', () async {
      dataSource.canOpenSettings = false;

      final result = await repository.openSettings(DeviceSetting.notifications);

      expect(result, isA<ApiError<void>>());
      expect((result as ApiError<void>).failure, isA<PermissionFailure>());
    });

    test('maps a plugin exception to a failure', () async {
      dataSource.throws = true;

      final result = await repository.openSettings(DeviceSetting.notifications);

      expect(result, isA<ApiError<void>>());
    });
  });
}
