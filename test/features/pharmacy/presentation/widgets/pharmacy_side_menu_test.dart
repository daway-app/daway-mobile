import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/patient_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/pharmacy_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:daway_app/features/auth/presentation/cubit/logout_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/widgets/pharmacy_dashboard_tab_scope.dart';
import 'package:daway_app/features/pharmacy/presentation/widgets/pharmacy_side_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';

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

void main() {
  late LogoutCubit logoutCubit;
  late List<PharmacyDashboardTab> switchedTabs;

  // A stand-in for any tab that has the menu: an AppBar with the hamburger
  // that opens it.
  Widget buildTestable() {
    return buildArabicTestApp(
      home: BlocProvider.value(
        value: logoutCubit,
        child: PharmacyDashboardTabScope(
          switchToTab: switchedTabs.add,
          child: Scaffold(
            appBar: AppBar(),
            drawer: const PharmacySideMenu(),
            body: const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  setUp(() {
    logoutCubit = LogoutCubit(LogoutUseCase(_FakeAuthRepository(), _FakeSessionRepository()));
    switchedTabs = [];
  });

  tearDown(() => logoutCubit.close());

  testWidgets('asks to confirm before logging out', (tester) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(buildTestable());

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(find.text('تسجيل الخروج؟'), findsOneWidget);
    expect(logoutCubit.state.isLoggedOut, isFalse);
  });

  testWidgets('logs out once confirmed', (tester) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(buildTestable());

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'تسجيل الخروج'));
    await tester.pumpAndSettle();

    expect(logoutCubit.state.isLoggedOut, isTrue);
  });

  testWidgets('its items switch the shell to that tab', (tester) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(buildTestable());

    for (final (label, tab) in [
      ('الأدوية', PharmacyDashboardTab.medicines),
      ('المخزون', PharmacyDashboardTab.inventory),
      ('الاستفسارات', PharmacyDashboardTab.inquiries),
    ]) {
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();

      expect(switchedTabs.last, tab, reason: label);
    }
  });
}
