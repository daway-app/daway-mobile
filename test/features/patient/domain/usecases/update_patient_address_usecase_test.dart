import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/patient_address.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_addresses_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/update_patient_address_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

const _updated = PatientAddress(
  id: 1,
  label: 'المنزل',
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
  ApiResult<PatientAddress> updateResult = const Success(_updated);
  String? lastToken;
  int? lastAddressId;

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
  }) async =>
      throw UnimplementedError();

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
    lastToken = token;
    lastAddressId = addressId;
    return updateResult;
  }
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
  test('passes the session token and address id through to the repository', () async {
    final repository = _FakeAddressesRepository();
    final sessionRepository = _FakeSessionRepository()
      ..savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');
    final useCase = UpdatePatientAddressUseCase(repository, sessionRepository);

    final result = await useCase(
      addressId: 1,
      label: 'المنزل',
      recipientName: 'مريض',
      phone: '0599112233',
      address: 'خان يونس',
      latitude: 31.3,
      longitude: 34.3,
      isDefault: true,
    );

    expect(repository.lastToken, 'tok-1');
    expect(repository.lastAddressId, 1);
    expect(result, isA<Success<PatientAddress>>());
  });

  test('returns a session failure without calling the repository when logged out', () async {
    final repository = _FakeAddressesRepository();
    final useCase = UpdatePatientAddressUseCase(repository, _FakeSessionRepository());

    final result = await useCase(
      addressId: 1,
      label: 'المنزل',
      recipientName: 'مريض',
      phone: '0599112233',
      address: 'خان يونس',
      latitude: 31.3,
      longitude: 34.3,
      isDefault: true,
    );

    expect(result, isA<ApiError<PatientAddress>>());
    expect(repository.lastAddressId, isNull);
  });
}
