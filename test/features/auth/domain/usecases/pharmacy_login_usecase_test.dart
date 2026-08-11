import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/patient_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/pharmacy_auth_result.dart';
import 'package:daway_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/pharmacy_login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  String? lastPharmacyId;
  String? lastPassword;
  ApiResult<PharmacyAuthResult> loginResult =
      const Success(PharmacyAuthResult(token: 'fake-token'));

  @override
  Future<ApiResult<String?>> sendOtp({required String phone}) async =>
      const Success(null);

  @override
  Future<ApiResult<PatientAuthResult>> verifyOtp({
    required String phone,
    required String otp,
  }) async =>
      const Success(PatientAuthResult(token: 'tok', isNewAccount: false));

  @override
  Future<ApiResult<PharmacyAuthResult>> pharmacyLogin({
    required String pharmacyId,
    required String password,
  }) async {
    lastPharmacyId = pharmacyId;
    lastPassword = password;
    return loginResult;
  }

  @override
  Future<ApiResult<void>> logout({required String token}) async => const Success(null);
}

void main() {
  late _FakeAuthRepository repository;
  late PharmacyLoginUseCase useCase;

  setUp(() {
    repository = _FakeAuthRepository();
    useCase = PharmacyLoginUseCase(repository);
  });

  test('rejects an empty pharmacy id without calling the repository', () async {
    final result = await useCase(pharmacyId: '', password: 'password');

    expect(result, isA<ApiError<PharmacyAuthResult>>());
    expect((result as ApiError<PharmacyAuthResult>).failure, isA<ValidationFailure>());
    expect(repository.lastPharmacyId, isNull);
  });

  test('rejects an empty password without calling the repository', () async {
    final result = await useCase(pharmacyId: 'PH-1234', password: '');

    expect(result, isA<ApiError<PharmacyAuthResult>>());
    expect(repository.lastPassword, isNull);
  });

  test('delegates to the repository with valid credentials', () async {
    final result = await useCase(pharmacyId: 'PH-1234', password: 'password');

    expect(result, isA<Success<PharmacyAuthResult>>());
    expect(repository.lastPharmacyId, 'PH-1234');
    expect(repository.lastPassword, 'password');
  });
}
