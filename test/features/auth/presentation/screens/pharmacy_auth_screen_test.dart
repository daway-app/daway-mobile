import 'package:daway_app/core/helpers/api_result.dart';
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
  }) async =>
      const Success(PatientAuthResult(token: 'tok', isNewAccount: false));

  @override
  Future<ApiResult<PharmacyAuthResult>> pharmacyLogin({
    required String pharmacyId,
    required String password,
  }) async =>
      loginResult;

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

  Widget buildTestableScreen(PharmacyAuthCubit cubit) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        onGenerateRoute: (settings) => MaterialPageRoute(
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
    expect(find.text('دخول الصيدلة'), findsOneWidget);
    expect(find.text('معرف الصيدلية'), findsOneWidget);
    expect(find.text('كلمة المرور'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
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

  testWidgets('shows a validation error when submitting empty fields', (tester) async {
    await setPhoneViewport(tester);
    final cubit = PharmacyAuthCubit(
      PharmacyLoginUseCase(_FakeAuthRepository()),
      SaveSessionUseCase(_FakeSessionRepository()),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(cubit.state.token, isNull);
    expect(cubit.state.errorMessage, isNotNull);
  });
}
