import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/theming/app_colors.dart';
import 'package:daway_app/core/widgets/app_custom_button.dart';
import 'package:daway_app/features/auth/presentation/cubit/password_reset_cubit.dart';
import 'package:daway_app/features/auth/presentation/cubit/password_reset_state.dart';
import 'package:daway_app/features/auth/presentation/screens/password_reset_code_screen.dart';
import 'package:daway_app/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';
import '../../../../helpers/fake_password_reset_repository.dart';

void main() {
  late FakePasswordResetRepository repository;
  late PasswordResetCubit cubit;

  const phone = '0591234529';

  setUp(() async {
    repository = FakePasswordResetRepository();
    cubit = repository.newCubit();
    // The screen is reached with the code sent: the phone is known.
    await cubit.sendCode(phone);
    repository.calls.clear();
  });

  tearDown(() => cubit.close());

  Future<void> pumpScreen(WidgetTester tester) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: BlocProvider.value(value: cubit, child: const PasswordResetCodeScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder codeInput() => find.byType(TextField);

  Future<void> typeCodeAndVerify(WidgetTester tester, String code) async {
    await tester.enterText(codeInput(), code);
    await tester.pump();
    await tester.tap(find.text('تحقق'));
    await tester.pumpAndSettle();
  }

  testWidgets('has the title and the line saying where the code went, with the number hidden', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('أدخل رمز التحقق'), findsOneWidget);
    expect(find.textContaining('أدخل رمز التحقق المرسل إلى رقم هاتفك'), findsOneWidget);
    expect(find.textContaining('+970 XXX XXX X29'), findsOneWidget);
    // Nothing of the number but its last two digits.
    expect(find.textContaining('591'), findsNothing);
    expect(find.textContaining('234'), findsNothing);
  });

  testWidgets('the number is one left-to-right unit in the line, so its "+" stays in front', (
    tester,
  ) async {
    await pumpScreen(tester);

    final subtitle = tester.widget<Text>(find.textContaining('للمتابعة')).data!;

    expect(subtitle, contains('\u2066+970 XXX XXX X29\u2069'));
  });

  testWidgets('has six boxes for the code, and a button under them', (tester) async {
    await pumpScreen(tester);

    // The boxes are drawn over one hidden field.
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.widget<TextField>(codeInput()).maxLength, 6);
    expect(find.text('تحقق'), findsOneWidget);
  });

  testWidgets('lays out like the design: the boxes 56 tall, the button 25 under them', (tester) async {
    await pumpScreen(tester);

    final button = tester.getRect(find.byType(AppCustomButton));

    expect(button.size, const Size(392, 56));
    expect(button.left, 24);
  });

  testWidgets('the button label is Bold 16 in white', (tester) async {
    await pumpScreen(tester);

    final style = tester.widget<Text>(find.text('تحقق')).style!;

    expect(style.fontSize, 16);
    expect(style.fontWeight, FontWeight.w700);
    expect(style.color, Colors.white);
  });

  testWidgets('shows the countdown to asking for the code again', (tester) async {
    await pumpScreen(tester);

    expect(find.text('إعادة الإرسال خلال 00:30'), findsOneWidget);
  });

  testWidgets('a code of six digits is checked, and moves on to the new password screen', (
    tester,
  ) async {
    await pumpScreen(tester);

    await typeCodeAndVerify(tester, '123456');

    expect(repository.calls, ['verify $phone 123456']);
    expect(find.byType(ResetPasswordScreen), findsOneWidget);
    expect(cubit.state.step, PasswordResetStep.newPassword);
  });

  testWidgets('a code that is too short is answered under the boxes, which turn red', (tester) async {
    await pumpScreen(tester);

    await typeCodeAndVerify(tester, '123');

    expect(find.text('يرجى إدخال رمز التحقق المكوّن من 6 أرقام'), findsOneWidget);
    expect(repository.calls, isEmpty);
    expect(find.byType(ResetPasswordScreen), findsNothing);
  });

  testWidgets('a wrong code is answered under the boxes with the backend message', (tester) async {
    repository.verifyResult = const ApiError(ApiFailure(message: 'رمز التحقق غير صحيح'));
    await pumpScreen(tester);

    await typeCodeAndVerify(tester, '000000');

    expect(find.text('رمز التحقق غير صحيح'), findsOneWidget);
    expect(find.byType(ResetPasswordScreen), findsNothing);
    expect(cubit.state.step, PasswordResetStep.code);
  });

  testWidgets('with the backend not there yet, "قريباً" comes up', (tester) async {
    repository.verifyResult = const ApiError(ComingSoonFailure());
    await pumpScreen(tester);

    await typeCodeAndVerify(tester, '123456');

    expect(find.text('قريباً'), findsOneWidget);
    expect(find.byType(ResetPasswordScreen), findsNothing);
  });

  testWidgets('asking again after the countdown sends to the same number, and restarts it', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.pump(const Duration(seconds: 30));
    expect(find.text('إعادة إرسال الرمز'), findsOneWidget);

    await tester.tap(find.text('إعادة إرسال الرمز'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(repository.calls, ['send $phone']);
    expect(find.text('إعادة الإرسال خلال 00:30'), findsOneWidget);
    expect(cubit.state.step, PasswordResetStep.code);
  });

  testWidgets('a resend that fails leaves the link to try again, and says why', (tester) async {
    await pumpScreen(tester);
    await tester.pump(const Duration(seconds: 30));
    repository.sendResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));

    await tester.tap(find.text('إعادة إرسال الرمز'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('تعذر الاتصال بالخادم'), findsOneWidget);
    expect(find.text('إعادة إرسال الرمز'), findsOneWidget);
  });

  testWidgets('going back returns the flow to the phone step', (tester) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(value: cubit, child: const PasswordResetCodeScreen()),
                ),
              ),
              child: const Text('الهاتف'),
            ),
          ),
        ),
      ),
    );
    final semantics = tester.ensureSemantics();
    await tester.tap(find.text('الهاتف'));
    await tester.pumpAndSettle();
    expect(cubit.state.step, PasswordResetStep.code);

    await tester.tap(find.bySemanticsLabel('رجوع'));
    await tester.pumpAndSettle();

    expect(find.byType(PasswordResetCodeScreen), findsNothing);
    expect(cubit.state.step, PasswordResetStep.phone);
    semantics.dispose();
  });

  testWidgets('the error colour is the auth red', (tester) async {
    repository.verifyResult = const ApiError(ApiFailure(message: 'رمز التحقق غير صحيح'));
    await pumpScreen(tester);

    await typeCodeAndVerify(tester, '000000');

    final message = tester.widget<Text>(find.text('رمز التحقق غير صحيح'));
    expect(message.style!.color, AppColors.authError);
  });
}
