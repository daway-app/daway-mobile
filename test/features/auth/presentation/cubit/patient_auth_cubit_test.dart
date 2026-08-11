import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/patient_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/pharmacy_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/save_session_usecase.dart';
import 'package:daway_app/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:daway_app/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:daway_app/features/auth/presentation/cubit/patient_auth_cubit.dart';
import 'package:daway_app/features/auth/presentation/cubit/patient_auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  String? lastSendOtpPhone;
  String? lastVerifyPhone;
  String? lastVerifyOtp;
  ApiResult<String?> sendOtpResult = const Success(null);
  ApiResult<PatientAuthResult> verifyResult =
      const Success(PatientAuthResult(token: 'fake-token', isNewAccount: false));

  @override
  Future<ApiResult<String?>> sendOtp({required String phone}) async {
    lastSendOtpPhone = phone;
    return sendOtpResult;
  }

  @override
  Future<ApiResult<PatientAuthResult>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    lastVerifyPhone = phone;
    lastVerifyOtp = otp;
    return verifyResult;
  }

  @override
  Future<ApiResult<PharmacyAuthResult>> pharmacyLogin({
    required String pharmacyId,
    required String password,
  }) async => const Success(PharmacyAuthResult(token: 'fake-token'));

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
  late PatientAuthCubit cubit;

  setUp(() {
    repository = _FakeAuthRepository();
    sessionRepository = _FakeSessionRepository();
    cubit = PatientAuthCubit(
      SendOtpUseCase(repository),
      VerifyOtpUseCase(repository),
      SaveSessionUseCase(sessionRepository),
    );
  });

  tearDown(() => cubit.close());

  group('sendOtp', () {
    test('rejects sending without agreeing to the terms', () async {
      cubit.phoneChanged('0599123456');

      await cubit.sendOtp();

      expect(cubit.state.otpSent, isFalse);
      expect(cubit.state.errorMessage, isNotNull);
    });

    test('rejects an invalid phone even when terms are agreed', () async {
      cubit.termsToggled(true);
      cubit.phoneChanged('123');

      await cubit.sendOtp();

      expect(cubit.state.otpSent, isFalse);
      expect(cubit.state.errorMessage, isNotNull);
    });

    test('sends the 10-digit local phone as-is on success', () async {
      cubit.termsToggled(true);
      cubit.phoneChanged('0599123456');

      await cubit.sendOtp();

      expect(cubit.state.otpSent, isTrue);
      expect(cubit.state.isSendingOtp, isFalse);
      expect(repository.lastSendOtpPhone, '0599123456');
    });

    test('surfaces the failure message on error', () async {
      repository.sendOtpResult =
          const ApiError(ApiFailure(message: 'فشل الإرسال', code: 'VALIDATION_ERROR'));
      cubit.termsToggled(true);
      cubit.phoneChanged('0599123456');

      await cubit.sendOtp();

      expect(cubit.state.otpSent, isFalse);
      expect(cubit.state.errorMessage, 'فشل الإرسال');
    });

    test('succeeds whether or not the backend echoes the OTP back', () async {
      repository.sendOtpResult = const Success('519979');
      cubit.termsToggled(true);
      cubit.phoneChanged('0599123456');

      await cubit.sendOtp();

      expect(cubit.state.otpSent, isTrue);
    });
  });

  group('backToPhoneStep', () {
    test('clears otpSent and any error', () async {
      cubit.termsToggled(true);
      cubit.phoneChanged('0599123456');
      await cubit.sendOtp();

      cubit.backToPhoneStep();

      expect(cubit.state.otpSent, isFalse);
      expect(cubit.state.errorMessage, isNull);
    });
  });

  group('verifyOtp', () {
    test('rejects an otp that is not 6 digits', () async {
      await cubit.verifyOtp('12345');

      expect(cubit.state.destination, isNull);
      expect(cubit.state.errorMessage, isNotNull);
    });

    test('routes to profile when the account was just created', () async {
      repository.verifyResult =
          const Success(PatientAuthResult(token: 'tok', isNewAccount: true));
      cubit.phoneChanged('0599123456');

      await cubit.verifyOtp('123456');

      expect(cubit.state.destination, AuthDestination.profile);
      expect(repository.lastVerifyOtp, '123456');
    });

    test('routes to home when the account already existed', () async {
      repository.verifyResult =
          const Success(PatientAuthResult(token: 'tok', isNewAccount: false));
      cubit.phoneChanged('0599123456');

      await cubit.verifyOtp('123456');

      expect(cubit.state.destination, AuthDestination.home);
    });

    test('persists the session on success', () async {
      repository.verifyResult =
          const Success(PatientAuthResult(token: 'tok', isNewAccount: false));
      cubit.phoneChanged('0599123456');

      await cubit.verifyOtp('123456');

      expect(sessionRepository.savedSession?.accountType, AccountType.patient);
      expect(sessionRepository.savedSession?.token, 'tok');
    });

    test('surfaces the failure message on error', () async {
      repository.verifyResult =
          const ApiError(ApiFailure(message: 'رمز التحقق غير صحيح', code: 'OTP_INVALID'));
      cubit.phoneChanged('0599123456');

      await cubit.verifyOtp('123456');

      expect(cubit.state.destination, isNull);
      expect(cubit.state.errorMessage, 'رمز التحقق غير صحيح');
    });
  });
}
