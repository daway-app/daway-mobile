import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/patient_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/pharmacy_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:daway_app/features/auth/presentation/cubit/logout_cubit.dart';
import 'package:daway_app/features/pharmacy/domain/entities/inquiry.dart';
import 'package:daway_app/features/pharmacy/domain/entities/pharmacy_dashboard_stats.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_dashboard_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_dashboard_stats_usecase.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_dashboard_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/screens/pharmacy_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
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
  }) async => const Success(PharmacyAuthResult(token: 'tok'));

  @override
  Future<ApiResult<void>> logout({required String token}) async =>
      const Success(null);
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

class _FakePharmacyDashboardRepository implements PharmacyDashboardRepository {
  final List<Inquiry> recentInquiries;

  const _FakePharmacyDashboardRepository({this.recentInquiries = const []});

  @override
  Future<ApiResult<PharmacyDashboardStats>> getDashboardStats({
    required String token,
  }) async {
    return Success(
      PharmacyDashboardStats(
        totalMedicines: 10,
        availableCount: 7,
        lowStockCount: 2,
        outOfStockCount: 1,
        newInquiriesCount: 3,
        averageRating: 4.5,
        ratingsCount: 6,
        lowStockItems: const [],
        recentInquiries: recentInquiries,
      ),
    );
  }
}

void main() {
  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget buildTestableScreen(
    LogoutCubit cubit, {
    List<String>? visitedRoutes,
    List<Inquiry> recentInquiries = const [],
  }) {
    final dashboardCubit = PharmacyDashboardCubit(
      GetPharmacyDashboardStatsUseCase(
        _FakePharmacyDashboardRepository(recentInquiries: recentInquiries),
        _FakeSessionRepository()
          ..savedSession = const UserSession(
            accountType: AccountType.pharmacy,
            token: 'tok-1',
          ),
      ),
    );
    addTearDown(dashboardCubit.close);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        onGenerateRoute: (settings) {
          visitedRoutes?.add(settings.name ?? '');
          return MaterialPageRoute(
            builder: (_) => const Scaffold(body: SizedBox.shrink()),
          );
        },
        home: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: cubit),
            BlocProvider.value(value: dashboardCubit),
          ],
          child: const PharmacyHomeScreen(),
        ),
      ),
    );
  }

  testWidgets('shows the confirmation dialog when tapping logout', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    final cubit = LogoutCubit(
      LogoutUseCase(_FakeAuthRepository(), _FakeSessionRepository()),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(find.text('تأكيد تسجيل الخروج'), findsOneWidget);
  });

  testWidgets('navigates to account-type screen after confirming logout', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    final cubit = LogoutCubit(
      LogoutUseCase(_FakeAuthRepository(), _FakeSessionRepository()),
    );
    addTearDown(cubit.close);

    final visitedRoutes = <String>[];
    await tester.pumpWidget(
      buildTestableScreen(cubit, visitedRoutes: visitedRoutes),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تأكيد'));
    await tester.pumpAndSettle();

    expect(cubit.state.isLoggedOut, isTrue);
    expect(visitedRoutes, contains(Routes.accountTypeScreen));
  });

  testWidgets('shows the loaded dashboard stats', (tester) async {
    await setPhoneViewport(tester);
    final cubit = LogoutCubit(
      LogoutUseCase(_FakeAuthRepository(), _FakeSessionRepository()),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    expect(find.text('10'), findsOneWidget); // totalMedicines
    expect(find.text('7'), findsOneWidget); // availableCount
    expect(find.text('2'), findsOneWidget); // lowStockCount
    expect(find.text('1'), findsOneWidget); // outOfStockCount
    expect(find.text('3'), findsOneWidget); // newInquiriesCount
    expect(find.text('4.5'), findsOneWidget); // averageRating
  });

  testWidgets('shows an empty state when there are no recent inquiries', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    final cubit = LogoutCubit(
      LogoutUseCase(_FakeAuthRepository(), _FakeSessionRepository()),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    expect(find.text('لا توجد استفسارات بعد'), findsOneWidget);
  });

  testWidgets(
    'renders a recent-inquiry tile with the patient name, medicine, and message',
    (tester) async {
      await setPhoneViewport(tester);
      final cubit = LogoutCubit(
        LogoutUseCase(_FakeAuthRepository(), _FakeSessionRepository()),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(
        buildTestableScreen(
          cubit,
          recentInquiries: [
            Inquiry(
              id: 1,
              message: 'هل يتوفر دواء الضغط؟',
              status: InquiryStatus.newInquiry,
              createdAt: DateTime.now().subtract(const Duration(hours: 2)),
              patientName: 'أحمد محمد',
              medicineName: 'بانادول',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('لا توجد استفسارات بعد'), findsNothing);
      expect(find.text('هل يتوفر دواء الضغط؟'), findsOneWidget);
      expect(find.textContaining('أحمد محمد'), findsOneWidget);
      expect(find.textContaining('بانادول'), findsOneWidget);
    },
  );
}
