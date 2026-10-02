import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/patient_address.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_addresses_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/create_patient_address_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

const _created = PatientAddress(
  id: 1,
  label: 'عنوان التوصيل',
  recipientName: 'مريض تجريبي',
  phone: '0599112233',
  address: 'غزة',
  latitude: 31.5,
  longitude: 34.47,
  isDefault: true,
);

class _FakeAddressesRepository implements PatientAddressesRepository {

  @override
  Future<ApiResult<void>> deleteAddress({required String token, required int addressId}) async =>
      const Success(null);
  ApiResult<PatientAddress> createResult = const Success(_created);
  String? lastToken;
  String? lastRecipientName;

  @override
  Future<ApiResult<List<PatientAddress>>> getAddresses({required String token}) async =>
      const Success([]);

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
    lastToken = token;
    lastRecipientName = recipientName;
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
  }) async =>
      createResult;
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession;

  @override
  Future<void> saveSession(UserSession session) async => savedSession = session;

  @override
  Future<UserSession?> getSession() async => savedSession;

  @override
  Future<void> clearSession() async => savedSession = null;
}

void main() {
  test('passes the session token and the address fields through to the repository', () async {
    final repository = _FakeAddressesRepository();
    final sessionRepository = _FakeSessionRepository()
      ..savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');
    final useCase = CreatePatientAddressUseCase(repository, sessionRepository);

    final result = await useCase(
      label: 'عنوان التوصيل',
      recipientName: 'مريض تجريبي',
      phone: '0599112233',
      address: 'غزة',
      latitude: 31.5,
      longitude: 34.47,
    );

    expect(repository.lastToken, 'tok-1');
    expect(repository.lastRecipientName, 'مريض تجريبي');
    expect(result, isA<Success<PatientAddress>>());
  });

  test('returns a session failure without calling the repository when logged out', () async {
    final repository = _FakeAddressesRepository();
    final useCase = CreatePatientAddressUseCase(repository, _FakeSessionRepository());

    final result = await useCase(
      label: 'عنوان التوصيل',
      recipientName: 'مريض تجريبي',
      phone: '0599112233',
      address: 'غزة',
      latitude: 31.5,
      longitude: 34.47,
    );

    expect(result, isA<ApiError<PatientAddress>>());
    expect(repository.lastToken, isNull);
  });
}
