import 'dart:async';
import 'dart:io';

import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/core/widgets/header_icon_button.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/patient_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/pharmacy_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:daway_app/features/auth/presentation/cubit/logout_cubit.dart';
import 'package:daway_app/features/patient/domain/repositories/avatar_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/upload_avatar_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/entities/pharmacy_dashboard_stats.dart';
import 'package:daway_app/features/pharmacy/domain/entities/pharmacy_order.dart';
import 'package:daway_app/features/pharmacy/domain/entities/pharmacy_profile.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_dashboard_repository.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_profile_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_dashboard_stats_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_profile_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/update_pharmacy_profile_usecase.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_dashboard_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_profile_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/screens/pharmacy_home_screen.dart';
import 'package:daway_app/features/pharmacy/presentation/widgets/pharmacy_dashboard_tab_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';

const _emptyStats = PharmacyDashboardStats(
  totalMedicines: 0,
  availableCount: 0,
  lowStockCount: 0,
  outOfStockCount: 0,
  newInquiriesCount: 0,
  averageRating: null,
  ratingsCount: 0,
  lowStockItems: [],
  recentInquiries: [],
);

const _fullStats = PharmacyDashboardStats(
  totalMedicines: 120,
  availableCount: 45,
  lowStockCount: 30,
  outOfStockCount: 75,
  newInquiriesCount: 3,
  averageRating: 4.5,
  ratingsCount: 6,
  lowStockItems: [],
  recentInquiries: [],
);

const _profile = PharmacyProfile(
  pharmacyId: 'PH-1234',
  name: 'صيدلية النور',
  phone: '0591234567',
  address: 'غزة الرمال',
);

const _addFilePrompt = 'رفع ملف المنتجات';

final _order = PharmacyOrder(
  orderNumber: 'DW-1021',
  createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
  itemsCount: 3,
  total: 80,
  area: 'غزة - النصر',
);

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<ApiResult<String?>> sendOtp({required String phone, String? name, String? birthDate}) async => const Success(null);

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
  UserSession? savedSession = const UserSession(accountType: AccountType.pharmacy, token: 'tok-1');

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

class _FakeDashboardRepository implements PharmacyDashboardRepository {
  ApiResult<PharmacyDashboardStats> result;

  /// When set, the next fetch waits for it — keeps the screen in its loading
  /// state for as long as a test needs.
  Completer<void>? gate;
  int fetches = 0;

  _FakeDashboardRepository(this.result);

  @override
  Future<ApiResult<PharmacyDashboardStats>> getDashboardStats({required String token}) async {
    fetches++;
    final pending = gate;
    if (pending != null) await pending.future;
    return result;
  }
}

class _FakeProfileRepository implements PharmacyProfileRepository {
  @override
  Future<ApiResult<PharmacyProfile>> getProfile({required String token}) async =>
      const Success(_profile);

  @override
  Future<ApiResult<void>> updateProfile({
    required String token,
    required PharmacyProfile profile,
  }) async => const Success(null);
}

class _FakeAvatarRepository implements AvatarRepository {
  @override
  Future<ApiResult<String>> uploadAvatar(File imageFile) async => const Success('https://x/y.jpg');
}

void main() {
  late _FakeDashboardRepository dashboardRepository;
  late List<PharmacyDashboardTab> switchedTabs;
  late List<String> visitedRoutes;
  late LogoutCubit logoutCubit;

  Widget buildTestableScreen({List<PharmacyOrder> orders = const []}) {
    final sessionRepository = _FakeSessionRepository();
    final dashboardCubit = PharmacyDashboardCubit(
      GetPharmacyDashboardStatsUseCase(dashboardRepository, sessionRepository),
    );
    final profileRepository = _FakeProfileRepository();
    final profileCubit = PharmacyProfileCubit(
      GetPharmacyProfileUseCase(profileRepository, sessionRepository),
      UpdatePharmacyProfileUseCase(profileRepository, sessionRepository),
      UploadAvatarUseCase(_FakeAvatarRepository()),
    );
    logoutCubit = LogoutCubit(LogoutUseCase(_FakeAuthRepository(), sessionRepository));
    addTearDown(dashboardCubit.close);
    addTearDown(profileCubit.close);
    addTearDown(logoutCubit.close);

    return buildArabicTestApp(
      onGenerateRoute: (settings) {
        visitedRoutes.add(settings.name ?? '');
        return MaterialPageRoute(builder: (_) => const Scaffold(body: SizedBox.shrink()));
      },
      home: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: dashboardCubit),
          BlocProvider.value(value: profileCubit),
          BlocProvider.value(value: logoutCubit),
        ],
        child: PharmacyDashboardTabScope(
          switchToTab: switchedTabs.add,
          child: PharmacyHomeScreen(orders: orders),
        ),
      ),
    );
  }

  setUp(() {
    dashboardRepository = _FakeDashboardRepository(const Success(_fullStats));
    switchedTabs = [];
    visitedRoutes = [];
  });

  group('header', () {
    testWidgets('greets the pharmacy by name and shows its address', (tester) async {
      await setDesignViewport(tester);

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('صيدلية النور'), findsOneWidget);
      expect(find.text('غزة الرمال'), findsOneWidget);
    });

    testWidgets('the bell opens the notifications screen', (tester) async {
      await setDesignViewport(tester);
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(HeaderIconButton));
      await tester.pumpAndSettle();

      expect(visitedRoutes, contains(Routes.pharmacyNotificationsScreen));
    });
  });

  group('a pharmacy with medicines', () {
    testWidgets('shows its stock figures and rating', (tester) async {
      await setDesignViewport(tester);

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.text('120'), findsOneWidget); // totalMedicines
      expect(find.text('45'), findsOneWidget); // availableCount
      expect(find.text('30'), findsOneWidget); // lowStockCount
      expect(find.text('75'), findsOneWidget); // outOfStockCount
      expect(find.text('4.5'), findsOneWidget); // averageRating
      expect(find.text('متوفرة'), findsOneWidget);
      expect(find.text('مخزون منخفض'), findsOneWidget);
      expect(find.text('نافد'), findsOneWidget);
      expect(find.text('التقييمات'), findsOneWidget);
    });

    testWidgets('does not ask for a medicines file', (tester) async {
      await setDesignViewport(tester);

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.text(_addFilePrompt), findsNothing);
    });

    testWidgets('has no sales figure to show, so the sales card shows a dash', (tester) async {
      await setDesignViewport(tester);

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.text('إجمالي المبيعات\nالشهرية'), findsOneWidget);
      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('the total-products card opens the products page', (tester) async {
      await setDesignViewport(tester);
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('إجمالي\nالمنتجات'));

      expect(switchedTabs, [PharmacyDashboardTab.products]);
    });

    testWidgets('the ratings tile opens the ratings screen', (tester) async {
      await setDesignViewport(tester);
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('التقييمات'));
      await tester.pumpAndSettle();

      expect(visitedRoutes, contains(Routes.pharmacyRatingsScreen));
    });
  });

  group('a pharmacy with no medicines', () {
    setUp(() {
      dashboardRepository = _FakeDashboardRepository(const Success(_emptyStats));
    });

    testWidgets('is asked to add its medicines file', (tester) async {
      await setDesignViewport(tester);

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.text(_addFilePrompt), findsOneWidget);
    });

    testWidgets('still shows the summary cards and tiles, all at zero', (tester) async {
      await setDesignViewport(tester);

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.text('0'), findsNWidgets(4)); // products, available, low, out
      expect(find.text('إجمالي\nالمنتجات'), findsOneWidget);
    });

    testWidgets('shows a dash instead of a rating it does not have', (tester) async {
      await setDesignViewport(tester);

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      // One for the sales card (no figure) and one for the ratings tile.
      expect(find.text('-'), findsNWidgets(2));
    });

    testWidgets('tapping the prompt says the import is coming soon', (tester) async {
      await setDesignViewport(tester);
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('اختيار ملف'));
      await tester.pump();

      expect(find.text('قريباً'), findsOneWidget);
    });
  });

  group('orders', () {
    testWidgets('are hidden while there are none', (tester) async {
      await setDesignViewport(tester);

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.text('الطلبات'), findsNothing);
    });

    testWidgets('show under the figures once there are some', (tester) async {
      await setDesignViewport(tester);

      await tester.pumpWidget(buildTestableScreen(orders: [_order]));
      await tester.pumpAndSettle();

      expect(find.text('الطلبات'), findsOneWidget);
      expect(find.text('#DW-1021'), findsOneWidget);
    });

    testWidgets('عرض الكل opens the orders tab', (tester) async {
      await setDesignViewport(tester);
      await tester.pumpWidget(buildTestableScreen(orders: [_order]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('عرض الكل'));

      expect(switchedTabs, [PharmacyDashboardTab.orders]);
    });

    testWidgets('عرض الطلب opens the order details', (tester) async {
      await setDesignViewport(tester);
      await tester.pumpWidget(buildTestableScreen(orders: [_order]));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('عرض الطلب'));
      await tester.tap(find.text('عرض الطلب'));
      await tester.pumpAndSettle();

      expect(find.text('تفاصيل الطلب'), findsOneWidget);
      expect(find.text('#DW-1021'), findsOneWidget);
    });
  });

  group('loading and failure', () {
    testWidgets('shows a spinner under the header while the figures load', (tester) async {
      await setDesignViewport(tester);
      final gate = Completer<void>();
      dashboardRepository.gate = gate;

      await tester.pumpWidget(buildTestableScreen());
      // Two frames — the profile arrives after the first — and not
      // pumpAndSettle, which would wait on the spinner forever.
      await tester.pump();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('غزة الرمال'), findsOneWidget); // the header does not wait

      gate.complete();
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('120'), findsOneWidget);
    });

    testWidgets('shows the failure with a retry that loads again', (tester) async {
      await setDesignViewport(tester);
      dashboardRepository.result = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.text('تعذر الاتصال بالخادم'), findsOneWidget);
      expect(find.text('120'), findsNothing);

      dashboardRepository.result = const Success(_fullStats);
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pumpAndSettle();

      expect(find.text('120'), findsOneWidget);
      expect(dashboardRepository.fetches, 2);
    });
  });

  testWidgets('goes back to the account-type screen once the app is logged out', (tester) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    await logoutCubit.logout();
    await tester.pumpAndSettle();

    expect(visitedRoutes, contains(Routes.accountTypeScreen));
  });
}
