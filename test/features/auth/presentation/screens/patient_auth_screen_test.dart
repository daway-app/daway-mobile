import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/patient_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/pharmacy_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/save_session_usecase.dart';
import 'package:daway_app/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:daway_app/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:daway_app/features/auth/presentation/cubit/patient_auth_cubit.dart';
import 'package:daway_app/features/auth/presentation/screens/patient_auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  ApiResult<String?> sendOtpResult = const Success(null);
  ApiResult<PatientAuthResult> verifyResult =
      const Success(PatientAuthResult(token: 'fake-token', isNewAccount: false));

  @override
  Future<ApiResult<String?>> sendOtp({required String phone}) async => sendOtpResult;

  @override
  Future<ApiResult<PatientAuthResult>> verifyOtp({
    required String phone,
    required String otp,
  }) async => verifyResult;

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
  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget buildTestableScreen(PatientAuthCubit cubit) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) => const Scaffold(body: SizedBox.shrink()),
        ),
        home: BlocProvider.value(
          value: cubit,
          child: const PatientAuthScreen(),
        ),
      ),
    );
  }

  testWidgets('renders the phone step without layout overflow', (tester) async {
    await setPhoneViewport(tester);
    final repository = _FakeAuthRepository();
    final cubit = PatientAuthCubit(
      SendOtpUseCase(repository),
      VerifyOtpUseCase(repository),
      SaveSessionUseCase(_FakeSessionRepository()),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('أهلاً بك في دوائي'), findsOneWidget);
    expect(find.text('رقم الجوال'), findsOneWidget);
    expect(find.text('إرسال رمز التحقق'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is RichText && widget.text.toPlainText().contains('شروط الخدمة'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows a validation error when sending without agreeing to terms', (tester) async {
    await setPhoneViewport(tester);
    final repository = _FakeAuthRepository();
    final cubit = PatientAuthCubit(
      SendOtpUseCase(repository),
      VerifyOtpUseCase(repository),
      SaveSessionUseCase(_FakeSessionRepository()),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    await tester.tap(find.text('إرسال رمز التحقق'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(cubit.state.otpSent, isFalse);
    expect(cubit.state.errorMessage, isNotNull);
  });

  testWidgets('pushes the dedicated OTP screen after a successful send', (tester) async {
    await setPhoneViewport(tester);
    final repository = _FakeAuthRepository();
    final cubit = PatientAuthCubit(
      SendOtpUseCase(repository),
      VerifyOtpUseCase(repository),
      SaveSessionUseCase(_FakeSessionRepository()),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    cubit.termsToggled(true);
    cubit.phoneChanged('0599123456');
    await cubit.sendOtp();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('أهلاً بك في دوائي'), findsNothing);
    expect(find.text('ادخل رمز التحقق'), findsOneWidget);
    expect(find.text('تحقق'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(6));
  });
}
