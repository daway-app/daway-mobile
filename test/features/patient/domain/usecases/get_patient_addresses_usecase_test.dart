import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/patient_address.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_addresses_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_patient_addresses_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAddressesRepository implements PatientAddressesRepository {

  @override
  Future<ApiResult<void>> deleteAddress({required String token, required int addressId}) async =>
      const Success(null);
  ApiResult<List<PatientAddress>> addressesResult = const Success([]);
  String? lastToken;

  @override
  Future<ApiResult<List<PatientAddress>>> getAddresses({required String token}) async {
    lastToken = token;
    return addressesResult;
  }

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
  }) async =>
      throw UnimplementedError();
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
  test('passes the session token through to the repository', () async {
    final repository = _FakeAddressesRepository();
    final sessionRepository = _FakeSessionRepository()
      ..savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');
    final useCase = GetPatientAddressesUseCase(repository, sessionRepository);

    final result = await useCase();

    expect(repository.lastToken, 'tok-1');
    expect(result, isA<Success<Object?>>());
  });

  test('returns a session failure without calling the repository when logged out', () async {
    final repository = _FakeAddressesRepository();
    final useCase = GetPatientAddressesUseCase(repository, _FakeSessionRepository());

    final result = await useCase();

    expect(result, isA<ApiError<Object?>>());
    expect(repository.lastToken, isNull);
  });
}
