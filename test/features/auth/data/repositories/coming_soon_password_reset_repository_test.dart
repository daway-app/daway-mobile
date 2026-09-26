import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/data/repositories/coming_soon_password_reset_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const repository = ComingSoonPasswordResetRepository();

  // Nothing is pretended to have been sent, checked or changed: every step
  // answers that it is not there yet.
  test('sending a code is not available yet', () async {
    final result = await repository.sendCode(phone: '0591234529');

    expect((result as ApiError).failure, isA<ComingSoonFailure>());
  });

  test('checking a code is not available yet', () async {
    final result = await repository.verifyCode(phone: '0591234529', code: '123456');

    expect((result as ApiError).failure, isA<ComingSoonFailure>());
  });

  test('setting a new password is not available yet', () async {
    final result = await repository.resetPassword(
      phone: '0591234529',
      resetToken: 'anything',
      password: 'new-secret-1',
    );

    expect((result as ApiError).failure, isA<ComingSoonFailure>());
  });

  test('the failure reads "قريباً"', () {
    expect(const ComingSoonFailure().message, 'قريباً');
  });
}
