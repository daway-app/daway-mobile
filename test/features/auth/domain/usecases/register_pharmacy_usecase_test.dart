import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/patient_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/pharmacy_auth_result.dart';
import 'package:daway_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/register_pharmacy_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  String? lastPharmacyName;
  String? lastPhone;
  String? lastRegion;
  String? lastPassword;
  ApiResult<void> registerResult = const Success(null);

  @override
  Future<ApiResult<String?>> sendOtp({required String phone}) async =>
      const Success(null);

  @override
  Future<ApiResult<PatientAuthResult>> verifyOtp({
    required String phone,
    required String otp,
    String? name,
    String? birthDate,
    double? latitude,
    double? longitude,
    bool? notificationsEnabled,
  }) async =>
      const Success(PatientAuthResult(token: 'tok', isNewAccount: false));

  @override
  Future<ApiResult<PharmacyAuthResult>> pharmacyLogin({
    required String pharmacyId,
    required String password,
  }) async => const Success(PharmacyAuthResult(token: 'fake-token'));

  @override
  Future<ApiResult<void>> registerPharmacy({
    required String pharmacyName,
    required String phone,
    required String region,
    required String password,
  }) async {
    lastPharmacyName = pharmacyName;
    lastPhone = phone;
    lastRegion = region;
    lastPassword = password;
    return registerResult;
  }

  @override
  Future<ApiResult<void>> logout({required String token}) async => const Success(null);
}

void main() {
  late _FakeAuthRepository repository;
  late RegisterPharmacyUseCase useCase;

  setUp(() {
    repository = _FakeAuthRepository();
    useCase = RegisterPharmacyUseCase(repository);
  });

  test('rejects an empty pharmacy name without calling the repository', () async {
    final result = await useCase(
      pharmacyName: '',
      phone: '0592067456',
      region: 'الزيتون',
      password: 'secret1234',
    );

    expect(result, isA<ApiError<void>>());
    expect((result as ApiError<void>).failure, isA<ValidationFailure>());
    expect(repository.lastPharmacyName, isNull);
  });

  test('rejects a password shorter than 8 characters without calling the repository',
      () async {
    final result = await useCase(
      pharmacyName: 'صيدلية الأمل',
      phone: '0592067456',
      region: 'الزيتون',
      password: 'short',
    );

    expect(result, isA<ApiError<void>>());
    expect(repository.lastPassword, isNull);
  });

  test('delegates to the repository with valid, trimmed fields', () async {
    final result = await useCase(
      pharmacyName: '  صيدلية الأمل  ',
      phone: '0592067456',
      region: 'الزيتون',
      password: 'secret1234',
    );

    expect(result, isA<Success<void>>());
    expect(repository.lastPharmacyName, 'صيدلية الأمل');
    expect(repository.lastPhone, '0592067456');
    expect(repository.lastRegion, 'الزيتون');
    expect(repository.lastPassword, 'secret1234');
  });

  test('surfaces a repository failure (e.g. phone already registered)', () async {
    repository.registerResult =
        const ApiError(ApiFailure(message: 'رقم الهاتف مستخدم مسبقاً', statusCode: 422));

    final result = await useCase(
      pharmacyName: 'صيدلية الأمل',
      phone: '0592067456',
      region: 'الزيتون',
      password: 'secret1234',
    );

    expect(result, isA<ApiError<void>>());
    expect((result as ApiError<void>).failure.message, 'رقم الهاتف مستخدم مسبقاً');
  });
}
