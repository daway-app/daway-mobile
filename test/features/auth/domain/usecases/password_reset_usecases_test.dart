import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/repositories/password_reset_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:daway_app/features/auth/domain/usecases/send_password_reset_code_usecase.dart';
import 'package:daway_app/features/auth/domain/usecases/verify_password_reset_code_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePasswordResetRepository implements PasswordResetRepository {
  final List<String> calls = [];
  ApiResult<void> sendResult = const Success(null);
  ApiResult<String> verifyResult = const Success('proof-1');
  ApiResult<void> resetResult = const Success(null);

  @override
  Future<ApiResult<void>> sendCode({required String phone}) async {
    calls.add('send $phone');
    return sendResult;
  }

  @override
  Future<ApiResult<String>> verifyCode({required String phone, required String code}) async {
    calls.add('verify $phone $code');
    return verifyResult;
  }

  @override
  Future<ApiResult<void>> resetPassword({
    required String phone,
    required String resetToken,
    required String password,
  }) async {
    calls.add('reset $phone $resetToken $password');
    return resetResult;
  }
}

String? _validationMessage(ApiResult<Object?> result) {
  if (result case ApiError(:final failure) when failure is ValidationFailure) {
    return failure.message;
  }
  return null;
}

void main() {
  late _FakePasswordResetRepository repository;

  setUp(() => repository = _FakePasswordResetRepository());

  group('SendPasswordResetCodeUseCase', () {
    test('sends the code to a valid local phone', () async {
      final result = await SendPasswordResetCodeUseCase(repository)(phone: '0591234529');

      expect(result, isA<Success<void>>());
      expect(repository.calls, ['send 0591234529']);
    });

    test('rejects a phone that is not a local mobile number, without calling the backend', () async {
      for (final phone in ['', '059123', '0491234529', '05912345290', '05912a4529']) {
        final result = await SendPasswordResetCodeUseCase(repository)(phone: phone);

        expect(_validationMessage(result), 'يرجى إدخال رقم جوال صحيح مكوّن من 10 أرقام', reason: phone);
      }
      expect(repository.calls, isEmpty);
    });

    test('passes the repository failure on', () async {
      repository.sendResult = const ApiError(ComingSoonFailure());

      final result = await SendPasswordResetCodeUseCase(repository)(phone: '0591234529');

      expect(result, isA<ApiError<void>>());
      expect((result as ApiError).failure, isA<ComingSoonFailure>());
    });
  });

  group('VerifyPasswordResetCodeUseCase', () {
    test('returns the proof the backend gives for a six-digit code', () async {
      final result = await VerifyPasswordResetCodeUseCase(repository)(
        phone: '0591234529',
        code: '123456',
      );

      expect((result as Success<String>).data, 'proof-1');
      expect(repository.calls, ['verify 0591234529 123456']);
    });

    test('rejects a code that is not exactly six digits, without calling the backend', () async {
      for (final code in ['', '12345', '1234567', '12345a', '12 456']) {
        final result = await VerifyPasswordResetCodeUseCase(repository)(
          phone: '0591234529',
          code: code,
        );

        expect(_validationMessage(result), 'يرجى إدخال رمز التحقق المكوّن من 6 أرقام', reason: code);
      }
      expect(repository.calls, isEmpty);
    });

    test('passes a wrong-code failure on', () async {
      repository.verifyResult = const ApiError(ApiFailure(message: 'رمز التحقق غير صحيح'));

      final result = await VerifyPasswordResetCodeUseCase(repository)(
        phone: '0591234529',
        code: '000000',
      );

      expect((result as ApiError).failure.message, 'رمز التحقق غير صحيح');
    });
  });

  group('ResetPasswordUseCase', () {
    Future<ApiResult<void>> reset(String password, String confirmation) {
      return ResetPasswordUseCase(repository)(
        phone: '0591234529',
        resetToken: 'proof-1',
        password: password,
        passwordConfirmation: confirmation,
      );
    }

    test('sets a matching password of eight characters or more', () async {
      final result = await reset('new-secret-1', 'new-secret-1');

      expect(result, isA<Success<void>>());
      expect(repository.calls, ['reset 0591234529 proof-1 new-secret-1']);
    });

    test('rejects a short password, without calling the backend', () async {
      final result = await reset('short', 'short');

      expect(_validationMessage(result), 'كلمة المرور يجب أن تكون 8 أحرف على الأقل');
      expect(repository.calls, isEmpty);
    });

    test('rejects two passwords that differ, without calling the backend', () async {
      final result = await reset('new-secret-1', 'new-secret-2');

      expect(_validationMessage(result), 'كلمتا المرور غير متطابقتين');
      expect(repository.calls, isEmpty);
    });

    test('checks the length before the match', () async {
      final result = await reset('abc', 'abd');

      expect(_validationMessage(result), 'كلمة المرور يجب أن تكون 8 أحرف على الأقل');
    });

    test('passes the repository failure on', () async {
      repository.resetResult = const ApiError(ComingSoonFailure());

      final result = await reset('new-secret-1', 'new-secret-1');

      expect((result as ApiError).failure, isA<ComingSoonFailure>());
    });
  });
}
