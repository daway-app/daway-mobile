import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/models/picked_location.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/core/widgets/otp_input_field.dart';
import 'package:daway_app/features/auth/domain/entities/patient_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/pharmacy_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/save_session_usecase.dart';
import 'package:daway_app/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:daway_app/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:daway_app/features/auth/presentation/cubit/patient_auth_cubit.dart';
import 'package:daway_app/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:daway_app/features/patient/domain/repositories/location_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_current_location_usecase.dart';
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
    String? name,
    String? birthDate,
    double? latitude,
    double? longitude,
    bool? notificationsEnabled,
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

class _FakeLocationRepository implements LocationRepository {
  @override
  Future<ApiResult<PickedLocation>> getCurrentLocation() async =>
      const Success(PickedLocation(latitude: 31.5, longitude: 34.46, address: 'غزة'));

  @override
  Future<ApiResult<String>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async => const Success('غزة');

  @override
  Future<ApiResult<PickedLocation>> searchAddress(String query) async =>
      const Success(PickedLocation(latitude: 31.5, longitude: 34.46, address: 'غزة'));
}

void main() {
  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  PatientAuthCubit buildCubit(_FakeAuthRepository repository) {
    return PatientAuthCubit(
      SendOtpUseCase(repository),
      VerifyOtpUseCase(repository),
      SaveSessionUseCase(_FakeSessionRepository()),
      GetCurrentLocationUseCase(_FakeLocationRepository()),
    );
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
    final cubit = buildCubit(repository);
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('خطوة أخيرة!'), findsOneWidget);
    expect(find.text('تحقق'), findsOneWidget);
    expect(find.byType(OtpInputField), findsOneWidget);
    expect(
      find.descendant(of: find.byType(OtpInputField), matching: find.byType(Container)),
      findsNWidgets(6),
    );
  });

  testWidgets('resets otpSent when the back button is pressed', (tester) async {
    await setPhoneViewport(tester);
    final repository = _FakeAuthRepository();
    final cubit = buildCubit(repository);
    addTearDown(cubit.close);
    cubit.phoneChanged('0599123456');
    await cubit.sendOtp();

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('authBackButton')));
    await tester.pumpAndSettle();

    expect(cubit.state.otpSent, isFalse);
  });

  testWidgets('navigates to the home route when the account already existed', (tester) async {
    await setPhoneViewport(tester);
    final repository = _FakeAuthRepository()
      ..verifyResult = const Success(PatientAuthResult(token: 'tok', isNewAccount: false));
    final cubit = buildCubit(repository);
    addTearDown(cubit.close);
    cubit.phoneChanged('0599123456');

    final visitedRoutes = <String>[];
    await tester.pumpWidget(buildTestableScreen(cubit, visitedRoutes: visitedRoutes));
    await tester.pumpAndSettle();

    await cubit.verifyOtp('123456');
    await tester.pumpAndSettle();

    expect(visitedRoutes, contains(Routes.patientHomeScreen));
  });

  testWidgets('a sign-up needing registration data is sent to the location step', (tester) async {
    await setPhoneViewport(tester);
    final repository = _FakeAuthRepository()
      ..verifyResult = const ApiError(
        ApiFailure(message: 'يرجى إدخال بيانات التسجيل', registrationRequired: true),
      );
    final cubit = buildCubit(repository);
    addTearDown(cubit.close);
    cubit.phoneChanged('0599123456');
    cubit.nameChanged('عبدالرحمن');
    cubit.birthDateChanged('2005-08-15');

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    await cubit.verifyOtp('123456');
    await tester.pumpAndSettle();

    expect(find.text('اعثر على الأقرب إليك'), findsOneWidget);
  });
}
