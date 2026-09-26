import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/features/auth/domain/entities/patient_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/pharmacy_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/pharmacy_login_usecase.dart';
import 'package:daway_app/features/auth/domain/usecases/save_session_usecase.dart';
import 'package:daway_app/features/auth/presentation/cubit/pharmacy_auth_cubit.dart';
import 'package:daway_app/features/auth/presentation/screens/pharmacy_auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';

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
    String? name,
    String? birthDate,
    double? latitude,
    double? longitude,
    bool? notificationsEnabled,
  }) async =>
      const Success(PatientAuthResult(token: 'tok', isNewAccount: false));

  @override
  Future<ApiResult<PharmacyAuthResult>> pharmacyLogin({
    required String pharmacyId,
    required String password,
  }) async =>
      loginResult;

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
  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget buildTestableScreen(PharmacyAuthCubit cubit, {RouteFactory? onGenerateRoute}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        onGenerateRoute: onGenerateRoute ??
            (settings) => MaterialPageRoute(
                  builder: (_) => const Scaffold(body: SizedBox.shrink()),
                ),
        home: BlocProvider.value(
          value: cubit,
          child: const PharmacyAuthScreen(),
        ),
      ),
    );
  }

  testWidgets('renders the pharmacy login form without layout overflow', (tester) async {
    await setPhoneViewport(tester);
    final cubit = PharmacyAuthCubit(
      PharmacyLoginUseCase(_FakeAuthRepository()),
      SaveSessionUseCase(_FakeSessionRepository()),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('مرحباً بعودتك!'), findsOneWidget);
    expect(find.text('معرف الصيدلية (ID)'), findsOneWidget);
    expect(find.text('كلمة المرور'), findsOneWidget);
    expect(find.text('التالي'), findsOneWidget);
  });

  group('the forgot-password link', () {
    testWidgets('sits under the password field, at the right of the right-to-left page', (
      tester,
    ) async {
      await setDesignViewport(tester);
      final cubit = PharmacyAuthCubit(
        PharmacyLoginUseCase(_FakeAuthRepository()),
        SaveSessionUseCase(_FakeSessionRepository()),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(
        buildArabicTestApp(
          home: BlocProvider.value(value: cubit, child: const PharmacyAuthScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final link = tester.getRect(find.text('نسيت كلمة المرور؟'));
      final passwordField = tester.getRect(find.byType(TextField).last);
      final button = tester.getRect(find.byType(ElevatedButton));

      expect(link.top, greaterThan(passwordField.bottom));
      expect(link.bottom, lessThan(button.top));
      expect(link.right, closeTo(passwordField.right, 1));
    });

    testWidgets('is underlined', (tester) async {
      await setPhoneViewport(tester);
      final cubit = PharmacyAuthCubit(
        PharmacyLoginUseCase(_FakeAuthRepository()),
        SaveSessionUseCase(_FakeSessionRepository()),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(buildTestableScreen(cubit));
      await tester.pumpAndSettle();

      final style = tester.widget<Text>(find.text('نسيت كلمة المرور؟')).style!;
      expect(style.decoration, TextDecoration.underline);
    });

    testWidgets('opens the forgot-password screen', (tester) async {
      await setPhoneViewport(tester);
      final cubit = PharmacyAuthCubit(
        PharmacyLoginUseCase(_FakeAuthRepository()),
        SaveSessionUseCase(_FakeSessionRepository()),
      );
      addTearDown(cubit.close);
      final opened = <String?>[];

      await tester.pumpWidget(
        buildTestableScreen(
          cubit,
          onGenerateRoute: (settings) {
            opened.add(settings.name);
            return MaterialPageRoute(builder: (_) => const Scaffold(body: SizedBox.shrink()));
          },
        ),
      );
      await tester.pumpAndSettle();
      opened.clear();

      await tester.tap(find.text('نسيت كلمة المرور؟'));
      await tester.pumpAndSettle();

      expect(opened, [Routes.pharmacyForgotPasswordScreen]);
    });

    testWidgets('does not try to log in', (tester) async {
      await setPhoneViewport(tester);
      final cubit = PharmacyAuthCubit(
        PharmacyLoginUseCase(_FakeAuthRepository()),
        SaveSessionUseCase(_FakeSessionRepository()),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(buildTestableScreen(cubit));
      await tester.pumpAndSettle();

      await tester.tap(find.text('نسيت كلمة المرور؟'));
      await tester.pumpAndSettle();

      expect(cubit.state.isLoggingIn, isFalse);
      expect(cubit.state.errorMessage, isNull);
      expect(find.text('معرف الصيدلية مطلوب'), findsNothing);
    });
  });

  testWidgets('toggles password visibility without changing cubit state', (tester) async {
    await setPhoneViewport(tester);
    final cubit = PharmacyAuthCubit(
      PharmacyLoginUseCase(_FakeAuthRepository()),
      SaveSessionUseCase(_FakeSessionRepository()),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    final passwordField = tester.widget<TextField>(find.byType(TextField).last);
    expect(passwordField.obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pumpAndSettle();

    final toggledField = tester.widget<TextField>(find.byType(TextField).last);
    expect(toggledField.obscureText, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows per-field validation errors when submitting empty fields', (tester) async {
    await setPhoneViewport(tester);
    final cubit = PharmacyAuthCubit(
      PharmacyLoginUseCase(_FakeAuthRepository()),
      SaveSessionUseCase(_FakeSessionRepository()),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('معرف الصيدلية مطلوب'), findsOneWidget);
    expect(find.text('كلمة المرور مطلوبة'), findsOneWidget);
    expect(cubit.state.token, isNull);
    expect(cubit.state.errorMessage, isNull);
  });
}
