import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/patient_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/pharmacy_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  String? lastLogoutToken;
  ApiResult<void> logoutResult = const Success(null);

  @override
  Future<ApiResult<String?>> sendOtp({required String phone}) async => const Success(null);

  @override
  Future<ApiResult<PatientAuthResult>> verifyOtp({
    required String phone,
    required String otp,
  }) async => const Success(PatientAuthResult(token: 'tok', isNewAccount: false));

  @override
  Future<ApiResult<PharmacyAuthResult>> pharmacyLogin({
    required String pharmacyId,
    required String password,
  }) async => const Success(PharmacyAuthResult(token: 'tok'));

  @override
  Future<ApiResult<void>> logout({required String token}) async {
    lastLogoutToken = token;
    return logoutResult;
  }
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession;
  bool clearCalled = false;

  @override
  Future<void> saveSession(UserSession session) async {
    savedSession = session;
  }

  @override
  Future<UserSession?> getSession() async => savedSession;

  @override
  Future<void> clearSession() async {
    clearCalled = true;
    savedSession = null;
  }
}

void main() {
  late _FakeAuthRepository authRepository;
  late _FakeSessionRepository sessionRepository;
  late LogoutUseCase useCase;

  setUp(() {
    authRepository = _FakeAuthRepository();
    sessionRepository = _FakeSessionRepository();
    useCase = LogoutUseCase(authRepository, sessionRepository);
  });

  test('revokes the token remotely and clears the local session', () async {
    sessionRepository.savedSession =
        const UserSession(accountType: AccountType.pharmacy, token: 'tok-123');

    await useCase();

    expect(authRepository.lastLogoutToken, 'tok-123');
    expect(sessionRepository.clearCalled, isTrue);
    expect(sessionRepository.savedSession, isNull);
  });

  test('still clears the local session when the remote call fails', () async {
    sessionRepository.savedSession =
        const UserSession(accountType: AccountType.patient, token: 'tok-456');
    authRepository.logoutResult =
        const ApiError(NetworkFailure('لا يوجد اتصال بالإنترنت'));

    await useCase();

    expect(sessionRepository.clearCalled, isTrue);
    expect(sessionRepository.savedSession, isNull);
  });

  test('clears the local session even when there was no saved session', () async {
    await useCase();

    expect(authRepository.lastLogoutToken, isNull);
    expect(sessionRepository.clearCalled, isTrue);
  });
}
