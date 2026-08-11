import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/patient_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/pharmacy_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/pharmacy_login_usecase.dart';
import 'package:daway_app/features/auth/domain/usecases/save_session_usecase.dart';
import 'package:daway_app/features/auth/presentation/cubit/pharmacy_auth_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
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
  }) async =>
      loginResult;

  @override
  Future<ApiResult<void>> logout({required String token}) async => const Success(null);
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession;

  @override
  Future<void> saveSession(UserSession session) async {
    savedSession = session;
  }

  @override
  Future<UserSession?> getSession() async => savedSession;

  @override
  Future<void> clearSession() async {
    savedSession = null;
  }
}

void main() {
  late _FakeAuthRepository repository;
  late _FakeSessionRepository sessionRepository;
  late PharmacyAuthCubit cubit;

  setUp(() {
    repository = _FakeAuthRepository();
    sessionRepository = _FakeSessionRepository();
    cubit = PharmacyAuthCubit(
      PharmacyLoginUseCase(repository),
      SaveSessionUseCase(sessionRepository),
    );
  });

  tearDown(() => cubit.close());

  group('login', () {
    test('rejects an empty pharmacy id', () async {
      await cubit.login(pharmacyId: '', password: 'password');

      expect(cubit.state.token, isNull);
      expect(cubit.state.errorMessage, isNotNull);
    });

    test('stores the token on success', () async {
      await cubit.login(pharmacyId: 'PH-1234', password: 'password');

      expect(cubit.state.token, 'fake-token');
      expect(cubit.state.isLoggingIn, isFalse);
      expect(cubit.state.errorMessage, isNull);
    });

    test('persists the session on success', () async {
      await cubit.login(pharmacyId: 'PH-1234', password: 'password');

      expect(sessionRepository.savedSession?.accountType, AccountType.pharmacy);
      expect(sessionRepository.savedSession?.token, 'fake-token');
    });

    test('surfaces the failure message on error', () async {
      repository.loginResult =
          const ApiError(ApiFailure(message: 'بيانات الدخول غير صحيحة', code: 'INVALID_CREDENTIALS'));

      await cubit.login(pharmacyId: 'PH-1234', password: 'wrong-password');

      expect(cubit.state.token, isNull);
      expect(cubit.state.errorMessage, 'بيانات الدخول غير صحيحة');
    });
  });
}
