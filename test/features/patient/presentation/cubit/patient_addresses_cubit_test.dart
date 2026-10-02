import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/models/picked_location.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/patient_address.dart';
import 'package:daway_app/features/patient/domain/entities/patient_profile.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_addresses_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_profile_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/create_patient_address_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/delete_patient_address_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_patient_addresses_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_patient_profile_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/update_patient_address_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/patient_addresses_cubit.dart';
import 'package:daway_app/features/patient/presentation/cubit/patient_addresses_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _home = PatientAddress(
  id: 1,
  label: 'المنزل',
  recipientName: 'مريض',
  phone: '0599112233',
  address: 'غزة',
  latitude: 31.5,
  longitude: 34.47,
  isDefault: true,
);

const _createdWork = PatientAddress(
  id: 2,
  label: 'العمل',
  recipientName: 'مريض',
  phone: '0599112233',
  address: 'رام الله',
  latitude: 31.9,
  longitude: 35.2,
  isDefault: true,
);

class _FakeAddressesRepository implements PatientAddressesRepository {

  int? lastDeletedId;

  @override
  Future<ApiResult<void>> deleteAddress({required String token, required int addressId}) async {
    lastDeletedId = addressId;
    return const Success(null);
  }

  ApiResult<List<PatientAddress>> addressesResult = const Success([]);
  ApiResult<PatientAddress> createResult = const Success(_createdWork);
  ApiResult<PatientAddress> updateResult = const Success(_home);
  String? lastCreateLabel;
  String? lastCreateRecipientName;
  bool? lastCreateIsDefault;
  int createCallCount = 0;
  int updateCallCount = 0;

  @override
  Future<ApiResult<List<PatientAddress>>> getAddresses({required String token}) async =>
      addressesResult;

  @override
  Future<ApiResult<PatientAddress>> createAddress({
    required String token,
    required String label,
    required String recipientName,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    bool isDefault = true,
  }) async {
    createCallCount++;
    lastCreateLabel = label;
    lastCreateRecipientName = recipientName;
    lastCreateIsDefault = isDefault;
    if (createResult case Success(:final data)) {
      final existing = (addressesResult as Success).data;
      addressesResult = Success([...existing, data]);
    }
    return createResult;
  }

  @override
  Future<ApiResult<PatientAddress>> updateAddress({
    required String token,
    required int addressId,
    required String label,
    required String recipientName,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    updateCallCount++;
    if (updateResult case Success(:final data)) {
      final existing = (addressesResult as Success).data;
      addressesResult = Success([
        for (final a in existing)
          if (a.id == addressId) data else a,
      ]);
    }
    return updateResult;
  }
}

class _FakeProfileRepository implements PatientProfileRepository {
  @override
  Future<ApiResult<PatientProfile>> getProfile({required String token}) async =>
      const Success(PatientProfile(name: 'مريض', phone: '0599112233'));

  @override
  Future<ApiResult<void>> updateProfile({
    required String token,
    required PatientProfile profile,
  }) async =>
      const Success(null);
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');

  @override
  Future<void> saveSession(UserSession session) async => savedSession = session;

  @override
  Future<UserSession?> getSession() async => savedSession;

  @override
  Future<void> clearSession() async => savedSession = null;
}

void main() {
  late _FakeAddressesRepository repository;
  late _FakeSessionRepository sessionRepository;

  PatientAddressesCubit buildCubit() {
    return PatientAddressesCubit(
      GetPatientAddressesUseCase(repository, sessionRepository),
      CreatePatientAddressUseCase(repository, sessionRepository),
      UpdatePatientAddressUseCase(repository, sessionRepository),
      GetPatientProfileUseCase(_FakeProfileRepository(), sessionRepository),
      DeletePatientAddressUseCase(repository, sessionRepository),
    );
  }

  setUp(() {
    repository = _FakeAddressesRepository();
    sessionRepository = _FakeSessionRepository();
  });

  test('loads the addresses on construction', () async {
    repository.addressesResult = const Success([_home]);
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<PatientAddressesLoaded>());
    expect((cubit.state as PatientAddressesLoaded).addresses, [_home]);
  });

  test('surfaces a load failure', () async {
    repository.addressesResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<PatientAddressesLoadFailure>());
  });

  test('addAddress uses the label the patient picked instead of the automatic one', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    await cubit.addAddress(
      const PickedLocation(latitude: 31.5, longitude: 34.47, address: 'غزة'),
      label: 'آخر',
    );

    expect(repository.lastCreateLabel, 'آخر');
  });

  test('deleteAddress removes it and reloads', () async {
    repository.addressesResult = const Success([_home]);
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    final error = await cubit.deleteAddress(_home);

    expect(error, isNull);
    expect(repository.lastDeletedId, _home.id);
  });

  test('addAddress labels the first address "المنزل" and reloads with it included', () async {
    repository.createResult = const Success(_home);
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    final error = await cubit.addAddress(
      const PickedLocation(latitude: 31.5, longitude: 34.47, address: 'غزة'),
    );

    expect(error, isNull);
    expect(repository.lastCreateLabel, 'المنزل');
    expect(repository.lastCreateRecipientName, 'مريض'); // borrowed from the profile
    expect((cubit.state as PatientAddressesLoaded).addresses, [_home]);
  });

  test('addAddress labels the second address "العمل"', () async {
    repository.addressesResult = const Success([_home]);
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    await cubit.addAddress(
      const PickedLocation(latitude: 31.9, longitude: 35.2, address: 'رام الله'),
    );

    expect(repository.lastCreateLabel, 'العمل');
  });

  test('the first address is sent as the default; later ones are not', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    await cubit.addAddress(
      const PickedLocation(latitude: 31.5, longitude: 34.47, address: 'غزة'),
    );
    expect(repository.lastCreateIsDefault, isTrue);

    await cubit.addAddress(
      const PickedLocation(latitude: 31.9, longitude: 35.2, address: 'رام الله'),
    );
    expect(repository.lastCreateIsDefault, isFalse);
  });

  test('a second addAddress call while one is already in flight is ignored', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    final location = const PickedLocation(latitude: 31.5, longitude: 34.47, address: 'غزة');
    // Fired without awaiting the first — simulates a fast double-tap landing
    // before the "أضف عنوان" button's disabled state takes effect.
    final first = cubit.addAddress(location);
    final second = cubit.addAddress(location);
    await Future.wait([first, second]);

    expect(repository.createCallCount, 1);
  });

  test('a create failure returns a message instead of silently doing nothing', () async {
    repository.createResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    final error = await cubit.addAddress(
      const PickedLocation(latitude: 31.5, longitude: 34.47, address: 'غزة'),
    );

    expect(error, 'تعذر الاتصال بالخادم');
  });

  test('updateAddress keeps the existing label/name/phone, only replacing the location',
      () async {
    repository.addressesResult = const Success([_home]);
    repository.updateResult = const Success(
      PatientAddress(
        id: 1,
        label: 'المنزل',
        recipientName: 'مريض',
        phone: '0599112233',
        address: 'خان يونس',
        latitude: 31.3,
        longitude: 34.3,
        isDefault: true,
      ),
    );
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    final error = await cubit.updateAddress(
      _home,
      const PickedLocation(latitude: 31.3, longitude: 34.3, address: 'خان يونس'),
    );

    expect(error, isNull);
    expect((cubit.state as PatientAddressesLoaded).addresses.single.address, 'خان يونس');
  });

  test('a second updateAddress call while one is already in flight is ignored', () async {
    repository.addressesResult = const Success([_home]);
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    final location = const PickedLocation(latitude: 31.3, longitude: 34.3, address: 'خان يونس');
    final first = cubit.updateAddress(_home, location);
    final second = cubit.updateAddress(_home, location);
    await Future.wait([first, second]);

    expect(repository.updateCallCount, 1);
  });
}
