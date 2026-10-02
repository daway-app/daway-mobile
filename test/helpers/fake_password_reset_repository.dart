import 'dart:async';

import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/repositories/password_reset_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:daway_app/features/auth/domain/usecases/send_password_reset_code_usecase.dart';
import 'package:daway_app/features/auth/domain/usecases/verify_password_reset_code_usecase.dart';
import 'package:daway_app/features/auth/presentation/cubit/password_reset_cubit.dart';

/// Stands in for the password-reset backend in the tests of its screens: every
/// step succeeds unless a test says otherwise, and each call is noted.
class FakePasswordResetRepository implements PasswordResetRepository {
  ApiResult<void> sendResult = const Success(null);
  ApiResult<String> verifyResult = const Success('proof-1');
  ApiResult<void> resetResult = const Success(null);
  final List<String> calls = [];

  /// When set, the step waits for it before answering — keeps a screen busy as
  /// long as a test needs.
  Completer<void>? sendGate;
  Completer<void>? verifyGate;
  Completer<void>? resetGate;

  @override
  Future<ApiResult<void>> sendCode({required String phone}) async {
    calls.add('send $phone');
    final gate = sendGate;
    if (gate != null) await gate.future;
    return sendResult;
  }

  @override
  Future<ApiResult<String>> verifyCode({required String phone, required String code}) async {
    calls.add('verify $phone $code');
    final gate = verifyGate;
    if (gate != null) await gate.future;
    return verifyResult;
  }

  @override
  Future<ApiResult<void>> resetPassword({
    required String phone,
    required String resetToken,
    required String password,
  }) async {
    calls.add('reset $phone $resetToken $password');
    final gate = resetGate;
    if (gate != null) await gate.future;
    return resetResult;
  }

  /// A cubit over the real use cases and this fake backend.
  PasswordResetCubit newCubit() => PasswordResetCubit(
        SendPasswordResetCodeUseCase(this),
        VerifyPasswordResetCodeUseCase(this),
        ResetPasswordUseCase(this),
      );
}
