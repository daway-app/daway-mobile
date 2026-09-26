import 'dart:async';

import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/theming/app_colors.dart';
import 'package:daway_app/core/widgets/app_custom_button.dart';
import 'package:daway_app/features/auth/presentation/cubit/password_reset_cubit.dart';
import 'package:daway_app/features/auth/presentation/cubit/password_reset_state.dart';
import 'package:daway_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:daway_app/features/auth/presentation/screens/password_reset_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';
import '../../../../helpers/fake_password_reset_repository.dart';

void main() {
  late FakePasswordResetRepository repository;
  late PasswordResetCubit cubit;

  setUp(() {
    repository = FakePasswordResetRepository();
    cubit = repository.newCubit();
  });

  tearDown(() => cubit.close());

  Future<void> pumpScreen(WidgetTester tester) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: BlocProvider.value(value: cubit, child: const ForgotPasswordScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester, String phone) async {
    await tester.enterText(find.byType(TextField), phone);
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
  }

  OutlineInputBorder borderOf(WidgetTester tester) {
    final decoration = tester.widget<TextField>(find.byType(TextField)).decoration!;
    return decoration.enabledBorder! as OutlineInputBorder;
  }

  testWidgets('has the title, the line under it, the phone field and the button', (tester) async {
    await pumpScreen(tester);

    expect(find.text('نسيت كلمة المرور ؟'), findsOneWidget);
    expect(find.text('أدخل رقم هاتفك لنرسل لك رمز التحقق لإعادة تعيين كلمة المرور.'), findsOneWidget);
    expect(find.text('رقم الهاتف'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('التالي'), findsOneWidget);
  });

  testWidgets('lays out like the design: chip, title, line, label, field, button', (tester) async {
    await pumpScreen(tester);

    final title = tester.getRect(find.text('نسيت كلمة المرور ؟'));
    final label = tester.getRect(find.text('رقم الهاتف'));
    final field = tester.getRect(find.byType(TextField));
    final button = tester.getRect(find.byType(AppCustomButton));

    expect(field.size, const Size(392, 56));
    expect(button.size, const Size(392, 56));
    expect(field.left, 24);
    expect(field.right, 416);
    // 24 between the field and the button, as in the design.
    expect(button.top - field.bottom, 24);
    expect(title.right, closeTo(416, 0.01));
    expect(label.bottom, lessThanOrEqualTo(field.top));
  });

  testWidgets('the button label is Bold 16 in white', (tester) async {
    await pumpScreen(tester);

    final style = tester.widget<Text>(find.text('التالي')).style!;

    expect(style.fontSize, 16);
    expect(style.fontWeight, FontWeight.w700);
    expect(style.color, Colors.white);
  });

  testWidgets('the field takes a number, read left to right, and keeps only digits', (tester) async {
    await pumpScreen(tester);

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.keyboardType, TextInputType.number);
    expect(field.textDirection, TextDirection.ltr);

    await tester.enterText(find.byType(TextField), '059-123 4529');
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '0591234529');
  });

  testWidgets('a phone that is not valid is answered under the field, which turns red', (tester) async {
    await pumpScreen(tester);

    await submit(tester, '123');

    expect(find.text('يرجى إدخال رقم جوال صحيح مكوّن من 10 أرقام'), findsOneWidget);
    expect(borderOf(tester).borderSide.color, AppColors.authError);
    expect(repository.calls, isEmpty);
    expect(find.byType(PasswordResetCodeScreen), findsNothing);
  });

  testWidgets('the error goes when the phone is sent again', (tester) async {
    await pumpScreen(tester);
    await submit(tester, '123');
    expect(find.text('يرجى إدخال رقم جوال صحيح مكوّن من 10 أرقام'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '0591234529');
    await tester.tap(find.text('التالي'));
    await tester.pump();

    expect(find.text('يرجى إدخال رقم جوال صحيح مكوّن من 10 أرقام'), findsNothing);
  });

  testWidgets('a failure of the backend is answered under the field', (tester) async {
    repository.sendResult = const ApiError(ApiFailure(message: 'لا يوجد حساب بهذا الرقم'));
    await pumpScreen(tester);

    await submit(tester, '0591234529');

    expect(find.text('لا يوجد حساب بهذا الرقم'), findsOneWidget);
    expect(find.byType(PasswordResetCodeScreen), findsNothing);
  });

  testWidgets('a valid phone sends the code and moves on to the code screen', (tester) async {
    await pumpScreen(tester);

    await submit(tester, '0591234529');

    expect(repository.calls, ['send 0591234529']);
    expect(find.byType(PasswordResetCodeScreen), findsOneWidget);
    expect(cubit.state.step, PasswordResetStep.code);
  });

  testWidgets('while the code is being sent the button is busy and cannot be pressed again', (
    tester,
  ) async {
    repository.sendGate = Completer<void>();
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField), '0591234529');
    await tester.tap(find.text('التالي'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('التالي'), findsNothing);
    await tester.tap(find.byType(AppCustomButton), warnIfMissed: false);
    await tester.pump();
    expect(repository.calls, ['send 0591234529']);

    repository.sendGate!.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('with the backend not there yet, "قريباً" comes up each time it is pressed', (
    tester,
  ) async {
    repository.sendResult = const ApiError(ComingSoonFailure());
    await pumpScreen(tester);

    await submit(tester, '0591234529');
    expect(find.text('قريباً'), findsOneWidget);
    expect(find.byType(PasswordResetCodeScreen), findsNothing);
    // It is not an error: no red under the field.
    expect(borderOf(tester).borderSide.color, AppColors.authInputBorder);

    // Let the snackbar go, and press again.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('قريباً'), findsNothing);
    await tester.tap(find.text('التالي'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('قريباً'), findsOneWidget);
  });

  testWidgets('the back chip leaves the screen', (tester) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(value: cubit, child: const ForgotPasswordScreen()),
                ),
              ),
              child: const Text('الدخول'),
            ),
          ),
        ),
      ),
    );
    final semantics = tester.ensureSemantics();
    await tester.tap(find.text('الدخول'));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('رجوع'));
    await tester.pumpAndSettle();

    expect(find.byType(ForgotPasswordScreen), findsNothing);
    semantics.dispose();
  });
}
