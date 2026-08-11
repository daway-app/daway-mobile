import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/features/auth/domain/entities/patient_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/pharmacy_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:daway_app/features/auth/presentation/cubit/logout_cubit.dart';
import 'package:daway_app/features/patient_home/presentation/screens/patient_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<ApiResult<String?>> sendOtp({required String phone}) async => const Success(null);

  @override
  Future<ApiResult<PatientAuthResult>> verifyOtp({
    required String phone,
    required String otp,
  }) async => const Success(PatientAuthResult(token: 'tok', isNewAccount: false));

  @override
  Future<ApiResult<PharmacyAuthResult>> pharmacyLogin({
    required String pharmacyId,
    required String password,
  }) async => const Success(PharmacyAuthResult(token: 'tok'));

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

  Widget buildTestableScreen(LogoutCubit cubit, {List<String>? visitedRoutes}) {
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
          child: const PatientHomeScreen(),
        ),
      ),
    );
  }

  testWidgets('shows the confirmation dialog when tapping logout', (tester) async {
    await setPhoneViewport(tester);
    final cubit = LogoutCubit(LogoutUseCase(_FakeAuthRepository(), _FakeSessionRepository()));
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(find.text('تأكيد تسجيل الخروج'), findsOneWidget);
  });

  testWidgets('navigates to account-type screen after confirming logout', (tester) async {
    await setPhoneViewport(tester);
    final cubit = LogoutCubit(LogoutUseCase(_FakeAuthRepository(), _FakeSessionRepository()));
    addTearDown(cubit.close);

    final visitedRoutes = <String>[];
    await tester.pumpWidget(buildTestableScreen(cubit, visitedRoutes: visitedRoutes));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تأكيد'));
    await tester.pumpAndSettle();

    expect(cubit.state.isLoggedOut, isTrue);
    expect(visitedRoutes, contains(Routes.accountTypeScreen));
  });
}
