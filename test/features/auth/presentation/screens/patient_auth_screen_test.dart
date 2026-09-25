import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/models/picked_location.dart';
import 'package:daway_app/core/theming/app_colors.dart';
import 'package:daway_app/features/auth/domain/entities/patient_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/pharmacy_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/save_session_usecase.dart';
import 'package:daway_app/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:daway_app/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:daway_app/core/widgets/otp_input_field.dart';
import 'package:daway_app/features/auth/presentation/cubit/patient_auth_cubit.dart';
import 'package:daway_app/features/auth/presentation/screens/location_permission_screen.dart';
import 'package:daway_app/features/auth/presentation/screens/notifications_permission_screen.dart';
import 'package:daway_app/features/auth/presentation/screens/patient_auth_screen.dart';
import 'package:daway_app/features/auth/presentation/screens/sign_up_screen.dart';
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
    final cubit = buildCubit(repository);
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('مرحباً بعودتك!'), findsOneWidget);
    expect(find.text('رقم هاتفك'), findsOneWidget);
    expect(find.text('التالي'), findsOneWidget);
  });

  testWidgets('shows a validation error when sending with an empty phone', (tester) async {
    await setPhoneViewport(tester);
    final repository = _FakeAuthRepository();
    final cubit = buildCubit(repository);
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(cubit.state.otpSent, isFalse);
    expect(find.text('الرجاء إدخال رقم الهاتف'), findsOneWidget);
  });

  testWidgets('pushes the dedicated OTP screen after a successful send', (tester) async {
    await setPhoneViewport(tester);
    final repository = _FakeAuthRepository();
    final cubit = buildCubit(repository);
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    cubit.phoneChanged('0599123456');
    await cubit.sendOtp();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('مرحباً بعودتك!'), findsNothing);
    expect(find.text('خطوة أخيرة!'), findsOneWidget);
    expect(find.text('تحقق'), findsOneWidget);
    expect(find.byType(OtpInputField), findsOneWidget);
    expect(
      find.descendant(of: find.byType(OtpInputField), matching: find.byType(Container)),
      findsNWidgets(6),
    );
  });

  group('the primary buttons of the sign-up flow use the main button colour', () {
    Widget buildTestableFlowScreen(Widget screen, {PatientAuthCubit? cubit}) {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: cubit == null ? screen : BlocProvider.value(value: cubit, child: screen),
        ),
      );
    }

    // What the button labelled [label] is filled with while enabled.
    Color? fillOf(WidgetTester tester, String label) {
      final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, label));
      return button.style?.backgroundColor?.resolve(<WidgetState>{});
    }

    testWidgets('create account: "التالي"', (tester) async {
      await setPhoneViewport(tester);
      final cubit = buildCubit(_FakeAuthRepository());
      addTearDown(cubit.close);

      await tester.pumpWidget(buildTestableFlowScreen(const SignUpScreen(), cubit: cubit));
      await tester.pumpAndSettle();

      expect(fillOf(tester, 'التالي'), AppColors.mainTeal);
    });

    testWidgets('location permission: "السماح بالوصول للموقع"', (tester) async {
      await setPhoneViewport(tester);
      final cubit = buildCubit(_FakeAuthRepository());
      addTearDown(cubit.close);

      await tester.pumpWidget(
        buildTestableFlowScreen(const LocationPermissionScreen(), cubit: cubit),
      );
      await tester.pumpAndSettle();

      expect(fillOf(tester, 'السماح بالوصول للموقع'), AppColors.mainTeal);
    });

    testWidgets('notifications permission: "السماح بالإشعارات"', (tester) async {
      await setPhoneViewport(tester);

      await tester.pumpWidget(buildTestableFlowScreen(const NotificationsPermissionScreen()));
      await tester.pumpAndSettle();

      expect(fillOf(tester, 'السماح بالإشعارات'), AppColors.mainTeal);
    });
  });
}
