import 'dart:async';

import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/presentation/cubit/password_reset_cubit.dart';
import 'package:daway_app/features/auth/presentation/cubit/password_reset_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_password_reset_repository.dart';

void main() {
  late FakePasswordResetRepository repository;
  late PasswordResetCubit cubit;

  const phone = '0591234529';

  setUp(() {
    repository = FakePasswordResetRepository();
    cubit = repository.newCubit();
  });

  tearDown(() => cubit.close());

  Future<void> reachCodeStep() => cubit.sendCode(phone);

  Future<void> reachNewPasswordStep() async {
    await reachCodeStep();
    await cubit.verifyCode('123456');
  }

  test('starts on the phone step, with nothing in it', () {
    expect(cubit.state.step, PasswordResetStep.phone);
    expect(cubit.state.phone, isEmpty);
    expect(cubit.state.isBusy, isFalse);
    expect(cubit.state.errorMessage, isNull);
    expect(cubit.state.notice, isNull);
  });

  group('sendCode', () {
    test('moves on to the code step and remembers the phone', () async {
      await cubit.sendCode(phone);

      expect(cubit.state.step, PasswordResetStep.code);
      expect(cubit.state.phone, phone);
      expect(cubit.state.isBusy, isFalse);
    });

    test('is busy while the code is being sent', () async {
      repository.sendGate = Completer<void>();

      final sending = cubit.sendCode(phone);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.isBusy, isTrue);
      expect(cubit.state.step, PasswordResetStep.phone);

      repository.sendGate!.complete();
      await sending;
      expect(cubit.state.isBusy, isFalse);
    });

    test('a phone that is not valid stays on the phone step with the reason', () async {
      await cubit.sendCode('123');

      expect(cubit.state.step, PasswordResetStep.phone);
      expect(cubit.state.errorMessage, 'يرجى إدخال رقم جوال صحيح مكوّن من 10 أرقام');
      expect(repository.calls, isEmpty);
    });

    test('a failure of the backend is shown by the field', () async {
      repository.sendResult = const ApiError(ApiFailure(message: 'لا يوجد حساب بهذا الرقم'));

      await cubit.sendCode(phone);

      expect(cubit.state.step, PasswordResetStep.phone);
      expect(cubit.state.errorMessage, 'لا يوجد حساب بهذا الرقم');
      expect(cubit.state.notice, isNull);
    });

    test('a step the backend cannot do yet is a notice, not an error', () async {
      repository.sendResult = const ApiError(ComingSoonFailure());

      await cubit.sendCode(phone);

      expect(cubit.state.step, PasswordResetStep.phone);
      expect(cubit.state.notice, 'قريباً');
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.isBusy, isFalse);
    });

    test('the next attempt clears what the last one said', () async {
      repository.sendResult = const ApiError(ApiFailure(message: 'فشل الإرسال'));
      await cubit.sendCode(phone);
      expect(cubit.state.errorMessage, isNotNull);
      repository.sendResult = const Success(null);

      await cubit.sendCode(phone);

      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.step, PasswordResetStep.code);
    });

    test('a notice is set again each time, so each time can be shown', () async {
      repository.sendResult = const ApiError(ComingSoonFailure());
      final notices = <String?>[];
      final subscription = cubit.stream.listen((state) => notices.add(state.notice));

      await cubit.sendCode(phone);
      await cubit.sendCode(phone);
      await Future<void>.delayed(Duration.zero);

      // Cleared as each attempt starts, then set as it ends.
      expect(notices.where((notice) => notice == 'قريباً').length, 2);
      expect(notices, contains(null));
      await subscription.cancel();
    });
  });

  group('resendCode', () {
    test('sends to the same phone again and stays on the code step', () async {
      await reachCodeStep();

      final sent = await cubit.resendCode();

      expect(sent, isTrue);
      expect(repository.calls, ['send $phone', 'send $phone']);
      expect(cubit.state.step, PasswordResetStep.code);
      expect(cubit.state.isBusy, isFalse);
    });

    test('says when it could not send', () async {
      await reachCodeStep();
      repository.sendResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));

      final sent = await cubit.resendCode();

      expect(sent, isFalse);
      expect(cubit.state.errorMessage, 'تعذر الاتصال بالخادم');
    });
  });

  group('verifyCode', () {
    test('moves on to the new password step, keeping the proof', () async {
      await reachCodeStep();

      await cubit.verifyCode('123456');

      expect(cubit.state.step, PasswordResetStep.newPassword);
      expect(cubit.state.resetToken, 'proof-1');
      expect(repository.calls.last, 'verify $phone 123456');
    });

    test('a code that is not six digits stays with the reason', () async {
      await reachCodeStep();

      await cubit.verifyCode('123');

      expect(cubit.state.step, PasswordResetStep.code);
      expect(cubit.state.errorMessage, 'يرجى إدخال رمز التحقق المكوّن من 6 أرقام');
      expect(repository.calls, ['send $phone']);
    });

    test('a wrong code stays on the code step with the backend message', () async {
      await reachCodeStep();
      repository.verifyResult = const ApiError(ApiFailure(message: 'رمز التحقق غير صحيح'));

      await cubit.verifyCode('000000');

      expect(cubit.state.step, PasswordResetStep.code);
      expect(cubit.state.errorMessage, 'رمز التحقق غير صحيح');
      expect(cubit.state.resetToken, isEmpty);
    });
  });

  group('resetPassword', () {
    test('finishes the flow, presenting the proof with the new password', () async {
      await reachNewPasswordStep();

      await cubit.resetPassword(password: 'new-secret-1', passwordConfirmation: 'new-secret-1');

      expect(cubit.state.step, PasswordResetStep.done);
      expect(repository.calls.last, 'reset $phone proof-1 new-secret-1');
    });

    test('a short password stays with the reason', () async {
      await reachNewPasswordStep();

      await cubit.resetPassword(password: 'short', passwordConfirmation: 'short');

      expect(cubit.state.step, PasswordResetStep.newPassword);
      expect(cubit.state.errorMessage, 'كلمة المرور يجب أن تكون 8 أحرف على الأقل');
    });

    test('two passwords that differ stay with the reason', () async {
      await reachNewPasswordStep();

      await cubit.resetPassword(password: 'new-secret-1', passwordConfirmation: 'new-secret-2');

      expect(cubit.state.step, PasswordResetStep.newPassword);
      expect(cubit.state.errorMessage, 'كلمتا المرور غير متطابقتين');
    });

    test('a backend failure stays on the step with its message', () async {
      await reachNewPasswordStep();
      repository.resetResult = const ApiError(ApiFailure(message: 'انتهت صلاحية الطلب'));

      await cubit.resetPassword(password: 'new-secret-1', passwordConfirmation: 'new-secret-1');

      expect(cubit.state.step, PasswordResetStep.newPassword);
      expect(cubit.state.errorMessage, 'انتهت صلاحية الطلب');
    });
  });

  group('back', () {
    test('from the new password step returns to the code step, forgetting the proof', () async {
      await reachNewPasswordStep();

      cubit.back();

      expect(cubit.state.step, PasswordResetStep.code);
      expect(cubit.state.resetToken, isEmpty);
      expect(cubit.state.phone, phone);
    });

    test('from the code step returns to the phone step, keeping the phone', () async {
      await reachCodeStep();

      cubit.back();

      expect(cubit.state.step, PasswordResetStep.phone);
      expect(cubit.state.phone, phone);
    });

    test('drops a message of the step it leaves', () async {
      await reachCodeStep();
      await cubit.verifyCode('12');
      expect(cubit.state.errorMessage, isNotNull);

      cubit.back();

      expect(cubit.state.errorMessage, isNull);
    });

    test('on the first step, or after the flow is done, does nothing', () async {
      cubit.back();
      expect(cubit.state.step, PasswordResetStep.phone);

      await reachNewPasswordStep();
      await cubit.resetPassword(password: 'new-secret-1', passwordConfirmation: 'new-secret-1');
      cubit.back();
      expect(cubit.state.step, PasswordResetStep.done);
    });

    test('going forward again after going back asks the backend again', () async {
      await reachCodeStep();
      cubit.back();

      await cubit.sendCode(phone);

      expect(cubit.state.step, PasswordResetStep.code);
      expect(repository.calls, ['send $phone', 'send $phone']);
    });
  });

  group('a request still on its way when the user goes back', () {
    test('a code accepted meanwhile does not move the flow on', () async {
      await reachCodeStep();
      repository.verifyGate = Completer<void>();
      final verifying = cubit.verifyCode('123456');
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.isBusy, isTrue);

      cubit.back();
      expect(cubit.state.step, PasswordResetStep.phone);
      expect(cubit.state.isBusy, isFalse);
      repository.verifyGate!.complete();
      await verifying;

      expect(cubit.state.step, PasswordResetStep.phone);
      expect(cubit.state.resetToken, isEmpty);
      expect(cubit.state.isBusy, isFalse);
    });

    test('a code refused meanwhile does not put its message on the step they are on', () async {
      await reachCodeStep();
      repository.verifyResult = const ApiError(ApiFailure(message: 'رمز التحقق غير صحيح'));
      repository.verifyGate = Completer<void>();
      final verifying = cubit.verifyCode('000000');
      await Future<void>.delayed(Duration.zero);

      cubit.back();
      repository.verifyGate!.complete();
      await verifying;

      expect(cubit.state.errorMessage, isNull);
    });

    test('a new password set meanwhile does not finish the flow', () async {
      await reachNewPasswordStep();
      repository.resetGate = Completer<void>();
      final resetting = cubit.resetPassword(
        password: 'new-secret-1',
        passwordConfirmation: 'new-secret-1',
      );
      await Future<void>.delayed(Duration.zero);

      cubit.back();
      repository.resetGate!.complete();
      await resetting;

      expect(cubit.state.step, PasswordResetStep.code);
      expect(cubit.state.isBusy, isFalse);
    });

    test('a code resent meanwhile is not counted as sent', () async {
      await reachCodeStep();
      repository.sendGate = Completer<void>();
      final resending = cubit.resendCode();
      await Future<void>.delayed(Duration.zero);

      cubit.back();
      repository.sendGate!.complete();

      expect(await resending, isFalse);
      expect(cubit.state.step, PasswordResetStep.phone);
    });

    test('an answer from an earlier visit to a step is not taken for the answer to this one', () async {
      await reachCodeStep();
      repository.verifyGate = Completer<void>();
      final firstVerify = cubit.verifyCode('111111');
      await Future<void>.delayed(Duration.zero);
      cubit.back();
      // Back on the code step by way of the phone, while the first request is
      // still out.
      await cubit.sendCode(phone);
      expect(cubit.state.step, PasswordResetStep.code);

      repository.verifyGate!.complete();
      await firstVerify;

      expect(cubit.state.step, PasswordResetStep.code);
      expect(cubit.state.resetToken, isEmpty);
    });

    test('going forward again after that works as usual', () async {
      await reachCodeStep();
      repository.verifyGate = Completer<void>();
      final verifying = cubit.verifyCode('123456');
      await Future<void>.delayed(Duration.zero);
      cubit.back();
      repository.verifyGate!.complete();
      await verifying;

      await cubit.sendCode(phone);
      await cubit.verifyCode('123456');

      expect(cubit.state.step, PasswordResetStep.newPassword);
      expect(cubit.state.resetToken, 'proof-1');
    });
  });

  test('closing the cubit while a code is being sent is not an error', () async {
    repository.sendGate = Completer<void>();
    final sending = cubit.sendCode(phone);
    await Future<void>.delayed(Duration.zero);

    await cubit.close();
    repository.sendGate!.complete();

    // A state emitted after the close would throw out of the send.
    await sending;
    expect(cubit.isClosed, isTrue);
  });
}
