import 'dart:async';

import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/features/auth/domain/entities/patient_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/pharmacy_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/pharmacy_login_usecase.dart';
import 'package:daway_app/features/auth/domain/usecases/save_session_usecase.dart';
import 'package:daway_app/features/auth/presentation/cubit/password_reset_cubit.dart';
import 'package:daway_app/features/auth/presentation/cubit/pharmacy_auth_cubit.dart';
import 'package:daway_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:daway_app/features/auth/presentation/screens/password_reset_code_screen.dart';
import 'package:daway_app/features/auth/presentation/screens/password_updated_screen.dart';
import 'package:daway_app/features/auth/presentation/screens/pharmacy_auth_screen.dart';
import 'package:daway_app/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';
import '../../../../helpers/fake_password_reset_repository.dart';

// The whole way through: from the login's link to the confirmation and back to
// the login, over the real screens, cubit and use cases, with only the backend
// stood in for.

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<ApiResult<String?>> sendOtp({required String phone}) async => const Success(null);

  @override
  Future<ApiResult<PatientAuthResult>> verifyOtp({
    required String phone,
    required String otp,
    String? name,
    String? birthDate,
    double? latitude,
    double? longitude,
    bool? notificationsEnabled,
  }) async => const Success(PatientAuthResult(token: 'tok', isNewAccount: false));

  @override
  Future<ApiResult<PharmacyAuthResult>> pharmacyLogin({
    required String pharmacyId,
    required String password,
  }) async => const Success(PharmacyAuthResult(token: 'tok'));

  @override
  Future<ApiResult<void>> registerPharmacy({
    required String pharmacyName,
    required String phone,
    required String region,
    required String password,
  }) async => const Success(null);

  @override
  Future<ApiResult<void>> logout({required String token}) async => const Success(null);
}

class _FakeSessionRepository implements SessionRepository {
  @override
  Future<void> saveSession(UserSession session) async {}

  @override
  Future<UserSession?> getSession() async => null;

  @override
  Future<void> clearSession() async {}
}

void main() {
  late FakePasswordResetRepository repository;

  setUp(() => repository = FakePasswordResetRepository());

  PasswordResetCubit newCubit() => repository.newCubit();

  /// The login, with the route to the flow that the real router has: as there,
  /// the route to the flow has its name and the login has none.
  Future<void> pumpLogin(WidgetTester tester) async {
    await setDesignViewport(tester);
    final loginCubit = PharmacyAuthCubit(
      PharmacyLoginUseCase(_FakeAuthRepository()),
      SaveSessionUseCase(_FakeSessionRepository()),
    );
    addTearDown(loginCubit.close);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: testDesignSize,
        builder: (context, child) => MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: Routes.pharmacyAuthScreen,
          onGenerateRoute: (settings) {
            switch (settings.name) {
              // What is under the login in the app.
              case '/':
                return MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(body: Text('الصفحة الأولى')),
                );
              case Routes.pharmacyAuthScreen:
                return MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(
                    value: loginCubit,
                    child: const PharmacyAuthScreen(),
                  ),
                );
              case Routes.pharmacyForgotPasswordScreen:
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (_) => BlocProvider(
                    create: (_) => newCubit(),
                    child: const ForgotPasswordScreen(),
                  ),
                );
            }
            return null;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openFlowFromLogin(WidgetTester tester) async {
    await tester.ensureVisible(find.text('نسيت كلمة المرور؟'));
    await tester.tap(find.text('نسيت كلمة المرور؟'));
    await tester.pumpAndSettle();
  }

  Finder codeBoxesInput() => find.byType(TextField).last;

  testWidgets('the whole way: phone, code, new password, confirmation, and back to the login', (
    tester,
  ) async {
    await pumpLogin(tester);

    // The link on the login opens the first screen.
    await openFlowFromLogin(tester);
    expect(find.text('نسيت كلمة المرور ؟'), findsOneWidget);

    // The phone.
    await tester.enterText(find.byType(TextField), '0591234529');
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    expect(repository.calls, ['send 0591234529']);
    expect(find.byType(PasswordResetCodeScreen), findsOneWidget);
    expect(find.textContaining('+970 XXX XXX X29'), findsOneWidget);

    // The code.
    await tester.enterText(codeBoxesInput(), '123456');
    await tester.pump();
    await tester.tap(find.text('تحقق'));
    await tester.pumpAndSettle();
    expect(repository.calls.last, 'verify 0591234529 123456');
    expect(find.byType(ResetPasswordScreen), findsOneWidget);

    // The new password.
    await tester.enterText(find.byType(TextField).first, 'new-secret-1');
    await tester.enterText(find.byType(TextField).last, 'new-secret-1');
    await tester.tap(find.text('تعيين كلمة المرور'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(repository.calls.last, 'reset 0591234529 proof-1 new-secret-1');

    // The confirmation replaces the screens of the flow.
    expect(find.byType(PasswordUpdatedScreen), findsOneWidget);
    expect(find.text('تم تحديث كلمة مرورك بنجاح'), findsOneWidget);
    expect(find.byType(ResetPasswordScreen, skipOffstage: false), findsNothing);
    expect(find.byType(PasswordResetCodeScreen, skipOffstage: false), findsNothing);
    expect(find.byType(ForgotPasswordScreen, skipOffstage: false), findsNothing);

    // And after its two seconds the login is back, its own screen.
    await tester.pump(PasswordUpdatedScreen.displayTime);
    await tester.pumpAndSettle();
    expect(find.byType(PasswordUpdatedScreen, skipOffstage: false), findsNothing);
    expect(find.byType(PharmacyAuthScreen), findsOneWidget);
    expect(find.text('نسيت كلمة المرور؟'), findsOneWidget);
    // Not the page under it.
    expect(find.text('الصفحة الأولى'), findsNothing);
  });

  testWidgets('with the backend not there yet, the first step says "قريباً" and goes nowhere', (
    tester,
  ) async {
    repository.sendResult = const ApiError(ComingSoonFailure());
    await pumpLogin(tester);
    await openFlowFromLogin(tester);

    await tester.enterText(find.byType(TextField), '0591234529');
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();

    expect(find.text('قريباً'), findsOneWidget);
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    expect(find.byType(PasswordResetCodeScreen), findsNothing);
  });

  testWidgets('going back from the code screen and forward again sends the code again', (
    tester,
  ) async {
    await pumpLogin(tester);
    await openFlowFromLogin(tester);
    await tester.enterText(find.byType(TextField), '0591234529');
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    expect(find.byType(PasswordResetCodeScreen), findsOneWidget);

    final semantics = tester.ensureSemantics();
    await tester.tap(find.bySemanticsLabel('رجوع'));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    expect(find.byType(PasswordResetCodeScreen), findsNothing);

    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();

    expect(repository.calls, ['send 0591234529', 'send 0591234529']);
    expect(find.byType(PasswordResetCodeScreen), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('going back twice from the new password screen leaves the phone screen, with no extra screens behind', (
    tester,
  ) async {
    await pumpLogin(tester);
    await openFlowFromLogin(tester);
    await tester.enterText(find.byType(TextField), '0591234529');
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    await tester.enterText(codeBoxesInput(), '123456');
    await tester.pump();
    await tester.tap(find.text('تحقق'));
    await tester.pumpAndSettle();
    expect(find.byType(ResetPasswordScreen), findsOneWidget);
    final semantics = tester.ensureSemantics();

    await tester.tap(find.bySemanticsLabel('رجوع'));
    await tester.pumpAndSettle();

    // One code screen, the one that was there, not a second on top of it —
    // counting the ones a screen above hides too.
    expect(find.byType(PasswordResetCodeScreen, skipOffstage: false), findsOneWidget);
    expect(find.byType(ResetPasswordScreen, skipOffstage: false), findsNothing);

    await tester.tap(find.bySemanticsLabel('رجوع'));
    await tester.pumpAndSettle();

    expect(find.byType(PasswordResetCodeScreen, skipOffstage: false), findsNothing);
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('a code accepted after the user went back opens nothing, and going forward again still works', (
    tester,
  ) async {
    await pumpLogin(tester);
    await openFlowFromLogin(tester);
    await tester.enterText(find.byType(TextField), '0591234529');
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    repository.verifyGate = Completer<void>();
    await tester.enterText(codeBoxesInput(), '123456');
    await tester.pump();
    await tester.tap(find.text('تحقق'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final semantics = tester.ensureSemantics();

    await tester.tap(find.bySemanticsLabel('رجوع'));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    repository.verifyGate!.complete();
    await tester.pumpAndSettle();

    // The answer came to a screen that is gone: nothing opens for it.
    expect(find.byType(ResetPasswordScreen, skipOffstage: false), findsNothing);
    expect(find.byType(PasswordResetCodeScreen, skipOffstage: false), findsNothing);
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);

    // And the flow goes on as if it had not happened.
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    expect(find.byType(PasswordResetCodeScreen), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('going back from the new password screen returns to the code screen', (tester) async {
    await pumpLogin(tester);
    await openFlowFromLogin(tester);
    await tester.enterText(find.byType(TextField), '0591234529');
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    await tester.enterText(codeBoxesInput(), '123456');
    await tester.pump();
    await tester.tap(find.text('تحقق'));
    await tester.pumpAndSettle();
    expect(find.byType(ResetPasswordScreen), findsOneWidget);

    final semantics = tester.ensureSemantics();
    await tester.tap(find.bySemanticsLabel('رجوع'));
    await tester.pumpAndSettle();

    expect(find.byType(PasswordResetCodeScreen), findsOneWidget);
    expect(find.byType(ResetPasswordScreen), findsNothing);
    semantics.dispose();
  });
}
