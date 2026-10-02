import 'package:daway_app/core/di/dependency_injection.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/patient_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/pharmacy_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:daway_app/features/auth/presentation/cubit/logout_cubit.dart';
import 'package:daway_app/features/chat/presentation/cubit/conversations_cubit.dart';
import 'package:daway_app/features/chat/presentation/cubit/conversations_state.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_dashboard_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_dashboard_state.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_inventory_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_inventory_state.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_medicines_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_medicines_state.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_profile_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_profile_state.dart';
import 'package:daway_app/core/widgets/header_icon_button.dart';
import 'package:daway_app/features/pharmacy/presentation/screens/pharmacy_dashboard_shell_screen.dart';
import 'package:daway_app/features/pharmacy/presentation/screens/pharmacy_home_screen.dart';
import 'package:daway_app/features/pharmacy/presentation/screens/pharmacy_products_screen.dart';
import 'package:daway_app/features/pharmacy/presentation/widgets/pharmacy_dashboard_tab_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';

// The tabs' own cubits are stood in for by cubits that just sit in their
// loading state: what these tests are about is the shell — which screen a nav
// item shows, and when it refreshes الرئيسية — not what the tabs load.
class _FakeDashboardCubit extends Cubit<PharmacyDashboardState>
    implements PharmacyDashboardCubit {
  int refreshes = 0;

  _FakeDashboardCubit() : super(const PharmacyDashboardLoading());

  @override
  Future<void> refresh() async => refreshes++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMedicinesCubit extends Cubit<PharmacyMedicinesState>
    implements PharmacyMedicinesCubit {
  int refreshes = 0;

  _FakeMedicinesCubit() : super(const PharmacyMedicinesLoading());

  @override
  Future<void> refresh() async => refreshes++;

  /// Moves the cubit on from loading, to show the page's loaded state.
  void show(PharmacyMedicinesState state) => emit(state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeInventoryCubit extends Cubit<PharmacyInventoryState>
    implements PharmacyInventoryCubit {
  _FakeInventoryCubit() : super(const PharmacyInventoryLoading());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeConversationsCubit extends Cubit<ConversationsState>
    implements ConversationsCubit {
  _FakeConversationsCubit() : super(const ConversationsLoading());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileCubit extends Cubit<PharmacyProfileState>
    implements PharmacyProfileCubit {
  _FakeProfileCubit() : super(const PharmacyProfileLoading());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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
  @override
  Future<void> saveSession(UserSession session) async {}

  @override
  Future<UserSession?> getSession() async =>
      const UserSession(accountType: AccountType.pharmacy, token: 'tok-1');

  @override
  Future<void> clearSession() async {}
}

void main() {
  late _FakeDashboardCubit dashboardCubit;
  // In the order the shell asks for them: the medicines tab's own first, at
  // launch, then the products page's, the first time that page is opened.
  late List<_FakeMedicinesCubit> medicinesCubits;
  late LogoutCubit logoutCubit;

  setUp(() {
    dashboardCubit = _FakeDashboardCubit();
    medicinesCubits = [];
    logoutCubit = LogoutCubit(LogoutUseCase(_FakeAuthRepository(), _FakeSessionRepository()));
    getIt
      ..registerFactory<PharmacyDashboardCubit>(() => dashboardCubit)
      ..registerFactory<PharmacyMedicinesCubit>(() {
        final cubit = _FakeMedicinesCubit();
        medicinesCubits.add(cubit);
        return cubit;
      })
      ..registerFactory<PharmacyInventoryCubit>(_FakeInventoryCubit.new)
      ..registerFactory<ConversationsCubit>(
        _FakeConversationsCubit.new,
        instanceName: 'pharmacy',
      )
      ..registerFactory<PharmacyProfileCubit>(_FakeProfileCubit.new);
  });

  tearDown(() async {
    await logoutCubit.close();
    await getIt.reset();
  });

  Future<void> pumpShell(WidgetTester tester) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: BlocProvider.value(value: logoutCubit, child: const PharmacyDashboardShellScreen()),
      ),
    );
    // Not pumpAndSettle: the loading tabs spin forever.
    await tester.pump();
  }

  Future<void> tapNavItem(WidgetTester tester, String label) async {
    // The nav label is the only text with that wording that is also a button.
    await tester.tap(find.bySemanticsLabel(label).hitTestable(), warnIfMissed: false);
    await tester.pump();
  }

  Finder appBarTitle(String title) {
    return find.descendant(of: find.byType(AppBar), matching: find.text(title));
  }

  testWidgets('lands on the profile tab', (tester) async {
    await pumpShell(tester);

    expect(appBarTitle('حسابي'), findsOneWidget);
  });

  testWidgets('each nav item shows its own screen', (tester) async {
    await pumpShell(tester);
    final semantics = tester.ensureSemantics();

    await tapNavItem(tester, 'المنتجات');
    expect(appBarTitle('الأدوية'), findsOneWidget);

    await tapNavItem(tester, 'الطلبات');
    expect(appBarTitle('الطلبات'), findsOneWidget);

    await tapNavItem(tester, 'المراسلات');
    expect(find.text('الاستفسارات'), findsOneWidget);

    await tapNavItem(tester, 'الملف الشخصي');
    expect(appBarTitle('حسابي'), findsOneWidget);

    await tapNavItem(tester, 'الرئيسية');
    expect(find.textContaining('أهلا بك'), findsOneWidget);

    semantics.dispose();
  });

  testWidgets('the inventory tab, which has no nav item, is reached from the side menu', (
    tester,
  ) async {
    await pumpShell(tester);
    final semantics = tester.ensureSemantics();
    await tapNavItem(tester, 'المنتجات');

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400)); // the drawer opens
    await tester.tap(find.text('المخزون'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400)); // and closes again

    expect(appBarTitle('إدارة المخزون'), findsOneWidget);
    semantics.dispose();
  });

  group('refreshing الرئيسية', () {
    testWidgets('is not done at the start or when going to other tabs', (tester) async {
      await pumpShell(tester);
      final semantics = tester.ensureSemantics();

      await tapNavItem(tester, 'المنتجات');
      await tapNavItem(tester, 'المراسلات');

      expect(dashboardCubit.refreshes, 0);
      semantics.dispose();
    });

    testWidgets('is done when coming back to it from another tab', (tester) async {
      await pumpShell(tester);
      final semantics = tester.ensureSemantics();

      await tapNavItem(tester, 'الرئيسية');
      expect(dashboardCubit.refreshes, 1);

      await tapNavItem(tester, 'المنتجات');
      await tapNavItem(tester, 'الرئيسية');
      expect(dashboardCubit.refreshes, 2);

      semantics.dispose();
    });

    testWidgets('is not repeated by tapping الرئيسية while already on it', (tester) async {
      await pumpShell(tester);
      final semantics = tester.ensureSemantics();
      await tapNavItem(tester, 'الرئيسية');

      await tapNavItem(tester, 'الرئيسية');

      expect(dashboardCubit.refreshes, 1);
      semantics.dispose();
    });
  });

  group('the products page', () {
    // What the home card does: ask the shell for the page.
    Future<void> openProductsPage(WidgetTester tester) async {
      // The shell lands on حسابي, so the home tab is offstage.
      final scope = PharmacyDashboardTabScope.maybeOf(
        tester.element(find.byType(PharmacyHomeScreen, skipOffstage: false)),
      )!;
      scope.switchToTab(PharmacyDashboardTab.products);
      await tester.pump();
    }

    testWidgets('is not built, nor loaded, until it is opened', (tester) async {
      await pumpShell(tester);

      expect(find.byType(PharmacyProductsScreen), findsNothing);
      expect(medicinesCubits.length, 1);
    });

    testWidgets('opens on the home card, with the bar still marking الرئيسية', (tester) async {
      await pumpShell(tester);
      final semantics = tester.ensureSemantics();

      await openProductsPage(tester);

      expect(find.byType(PharmacyProductsScreen), findsOneWidget);
      expect(find.text('اجمالي المنتجات'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('الرئيسية')),
        isSemantics(label: 'الرئيسية', isButton: true, isSelected: true, hasTapAction: true),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('المنتجات')),
        isNot(isSemantics(isSelected: true)),
      );
      semantics.dispose();
    });

    testWidgets('loads when first opened, and is refreshed on every later visit', (tester) async {
      await pumpShell(tester);
      final semantics = tester.ensureSemantics();

      await openProductsPage(tester);
      expect(medicinesCubits.length, 2);
      expect(medicinesCubits.last.refreshes, 0);

      await tapNavItem(tester, 'المراسلات');
      await openProductsPage(tester);

      expect(medicinesCubits.length, 2);
      expect(medicinesCubits.last.refreshes, 1);
      semantics.dispose();
    });

    testWidgets('the back chip returns to الرئيسية', (tester) async {
      await pumpShell(tester);
      await openProductsPage(tester);

      await tester.tap(find.byType(HeaderIconButton));
      await tester.pump();

      expect(find.textContaining('أهلا بك'), findsOneWidget);
      expect(find.byType(PharmacyHomeScreen), findsOneWidget);
    });

    testWidgets('the system back button returns to الرئيسية instead of leaving the app', (
      tester,
    ) async {
      await pumpShell(tester);
      await openProductsPage(tester);

      await tester.binding.handlePopRoute();
      await tester.pump();

      expect(find.byType(PharmacyDashboardShellScreen), findsOneWidget);
      // الرئيسية is the tab showing again: the bar marks it, and the products
      // page's own header is offstage.
      expect(find.text('اجمالي المنتجات'), findsNothing);
      expect(find.textContaining('أهلا بك'), findsOneWidget);
    });

    testWidgets('تحديث المنتجات opens the inventory tab', (tester) async {
      await pumpShell(tester);
      await openProductsPage(tester);
      medicinesCubits.last.show(const PharmacyMedicinesLoaded(medicines: []));
      await tester.pump();

      await tester.tap(find.text('تحديث المنتجات'));
      await tester.pump();

      expect(appBarTitle('إدارة المخزون'), findsOneWidget);
    });
  });
}
