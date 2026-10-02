import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/models/picked_location.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/order.dart';
import 'package:daway_app/features/patient/domain/entities/patient_address.dart';
import 'package:daway_app/features/patient/domain/entities/patient_profile.dart';
import 'package:daway_app/features/patient/domain/repositories/orders_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_addresses_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_profile_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/checkout_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/create_patient_address_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_patient_addresses_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_patient_profile_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/checkout_cubit.dart';
import 'package:daway_app/features/patient/presentation/cubit/checkout_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _defaultAddress = PatientAddress(
  id: 1,
  label: 'المنزل',
  recipientName: 'مريض',
  phone: '0599112233',
  address: 'غزة',
  latitude: 31.5,
  longitude: 34.47,
  isDefault: true,
);

const _nonDefaultAddress = PatientAddress(
  id: 2,
  label: 'العمل',
  recipientName: 'مريض',
  phone: '0599112233',
  address: 'رام الله',
  latitude: 31.9,
  longitude: 35.2,
  isDefault: false,
);

const _newAddress = PatientAddress(
  id: 3,
  label: 'عنوان التوصيل',
  recipientName: 'مريض',
  phone: '0599112233',
  address: 'خان يونس',
  latitude: 31.3,
  longitude: 34.3,
  isDefault: true,
);

class _FakeAddressesRepository implements PatientAddressesRepository {

  @override
  Future<ApiResult<void>> deleteAddress({required String token, required int addressId}) async =>
      const Success(null);
  ApiResult<List<PatientAddress>> addressesResult = const Success([]);
  ApiResult<PatientAddress> createResult = const Success(_newAddress);

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
  }) async =>
      createResult;

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
  }) async =>
      createResult;
}

class _FakeProfileRepository implements PatientProfileRepository {
  ApiResult<PatientProfile> profileResult =
      const Success(PatientProfile(name: 'مريض', phone: '0599112233'));

  @override
  Future<ApiResult<PatientProfile>> getProfile({required String token}) async => profileResult;

  @override
  Future<ApiResult<void>> updateProfile({
    required String token,
    required PatientProfile profile,
  }) async =>
      const Success(null);
}

class _FakeOrdersRepository implements OrdersRepository {

  @override
  Future<ApiResult<void>> cancelOrder({required String token, required int orderId}) async =>
      const Success(null);
  ApiResult<int> checkoutResult = const Success(42);
  int? lastAddressId;
  int checkoutCallCount = 0;

  @override
  Future<ApiResult<List<Order>>> getOrders({required String token}) async => const Success([]);

  @override
  Future<ApiResult<int>> checkout({
    required String token,
    required int addressId,
    String? couponCode,
    String? notes,
  }) async {
    checkoutCallCount++;
    lastAddressId = addressId;
    return checkoutResult;
  }
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
  late _FakeAddressesRepository addressesRepository;
  late _FakeProfileRepository profileRepository;
  late _FakeOrdersRepository ordersRepository;
  late _FakeSessionRepository sessionRepository;

  CheckoutCubit buildCubit() {
    return CheckoutCubit(
      GetPatientAddressesUseCase(addressesRepository, sessionRepository),
      CreatePatientAddressUseCase(addressesRepository, sessionRepository),
      GetPatientProfileUseCase(profileRepository, sessionRepository),
      CheckoutUseCase(ordersRepository, sessionRepository),
    );
  }

  setUp(() {
    addressesRepository = _FakeAddressesRepository();
    profileRepository = _FakeProfileRepository();
    ordersRepository = _FakeOrdersRepository();
    sessionRepository = _FakeSessionRepository();
  });

  test('start() with a saved default address checks out with it directly', () async {
    addressesRepository.addressesResult = const Success([_nonDefaultAddress, _defaultAddress]);
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.start();

    expect(ordersRepository.lastAddressId, 1);
    expect(cubit.state, isA<CheckoutSuccess>());
    expect((cubit.state as CheckoutSuccess).orderId, 42);
  });

  test('start() with saved addresses but none marked default uses the first one', () async {
    addressesRepository.addressesResult = const Success([_nonDefaultAddress]);
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.start();

    expect(ordersRepository.lastAddressId, 2);
  });

  test('start() with no saved address asks the screen to collect one instead of failing',
      () async {
    addressesRepository.addressesResult = const Success([]);
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.start();

    expect(cubit.state, isA<CheckoutNeedsAddress>());
    expect(ordersRepository.lastAddressId, isNull);
  });

  test('submitWithNewAddress creates the address from the profile + picked location, then checks out',
      () async {
    const location = PickedLocation(latitude: 31.3, longitude: 34.3, address: 'خان يونس');
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.submitWithNewAddress(location);

    expect(ordersRepository.lastAddressId, 3);
    expect(cubit.state, isA<CheckoutSuccess>());
  });

  test('a failure fetching addresses surfaces as CheckoutFailure', () async {
    addressesRepository.addressesResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.start();

    expect(cubit.state, isA<CheckoutFailure>());
  });

  test('a second start() call while one is already in flight is ignored, not run twice',
      () async {
    addressesRepository.addressesResult = const Success([_defaultAddress]);
    final cubit = buildCubit();
    addTearDown(cubit.close);

    // Fired without awaiting the first — simulates a fast double-tap landing
    // before the UI's isLoading-driven disable takes effect.
    final first = cubit.start();
    final second = cubit.start();
    await Future.wait([first, second]);

    expect(ordersRepository.checkoutCallCount, 1);
  });

  test('a checkout failure (e.g. empty cart) surfaces its message', () async {
    addressesRepository.addressesResult = const Success([_defaultAddress]);
    ordersRepository.checkoutResult = const ApiError(ApiFailure(message: 'السلة فارغة'));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.start();

    expect(cubit.state, isA<CheckoutFailure>());
    expect((cubit.state as CheckoutFailure).message, 'السلة فارغة');
  });
}
