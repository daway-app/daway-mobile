import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/features/auth/domain/entities/patient_auth_result.dart';
import 'package:daway_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:daway_app/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:daway_app/features/auth/presentation/cubit/patient_auth_cubit.dart';
import 'package:daway_app/features/auth/presentation/screens/otp_verification_screen.dart';
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
}

void main() {
  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget buildTestableScreen(PatientAuthCubit cubit, {List<String>? visitedRoutes}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        onGenerateRoute: (settings) {
          visitedRoutes?.add(settings.name ?? '');
          return MaterialPageRoute(
            builder: (_) => const Scaffold(body: SizedBox.shrink()),
          );
        },
        home: BlocProvider.value(
          value: cubit,
          child: const OtpVerificationScreen(),
        ),
      ),
    );
  }

  testWidgets('renders the 6-box OTP step without layout overflow', (tester) async {
    await setPhoneViewport(tester);
    final repository = _FakeAuthRepository();
    final cubit = PatientAuthCubit(SendOtpUseCase(repository), VerifyOtpUseCase(repository));
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('ادخل رمز التحقق'), findsOneWidget);
    expect(find.text('تحقق'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(6));
  });

  testWidgets('resets otpSent when the back button is pressed', (tester) async {
    await setPhoneViewport(tester);
    final repository = _FakeAuthRepository();
    final cubit = PatientAuthCubit(SendOtpUseCase(repository), VerifyOtpUseCase(repository));
    addTearDown(cubit.close);
    cubit.termsToggled(true);
    cubit.phoneChanged('0599123456');
    await cubit.sendOtp();

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(cubit.state.otpSent, isFalse);
  });

  testWidgets('navigates to the home route when the account already existed', (tester) async {
    await setPhoneViewport(tester);
    final repository = _FakeAuthRepository()
      ..verifyResult = const Success(PatientAuthResult(token: 'tok', isNewAccount: false));
    final cubit = PatientAuthCubit(SendOtpUseCase(repository), VerifyOtpUseCase(repository));
    addTearDown(cubit.close);
    cubit.phoneChanged('0599123456');

    final visitedRoutes = <String>[];
    await tester.pumpWidget(buildTestableScreen(cubit, visitedRoutes: visitedRoutes));
    await tester.pumpAndSettle();

    await cubit.verifyOtp('123456');
    await tester.pumpAndSettle();

    expect(visitedRoutes, contains(Routes.homeScreen));
  });

  testWidgets('navigates to the profile route when the account was just created', (tester) async {
    await setPhoneViewport(tester);
    final repository = _FakeAuthRepository()
      ..verifyResult = const Success(PatientAuthResult(token: 'tok', isNewAccount: true));
    final cubit = PatientAuthCubit(SendOtpUseCase(repository), VerifyOtpUseCase(repository));
    addTearDown(cubit.close);
    cubit.phoneChanged('0599123456');

    final visitedRoutes = <String>[];
    await tester.pumpWidget(buildTestableScreen(cubit, visitedRoutes: visitedRoutes));
    await tester.pumpAndSettle();

    await cubit.verifyOtp('123456');
    await tester.pumpAndSettle();

    expect(visitedRoutes, contains(Routes.profileScreen));
  });
}
