import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:daway_app/features/auth/presentation/cubit/logout_cubit.dart';
import 'package:daway_app/features/patient/domain/entities/device_setting.dart';
import 'package:daway_app/features/patient/domain/repositories/app_info_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/device_permissions_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_account_settings_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/open_device_settings_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/account_settings_cubit.dart';
import 'package:daway_app/features/patient/presentation/widgets/patient_side_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class _FakePermissions implements DevicePermissionsRepository {
  @override
  Future<ApiResult<bool>> isNotificationsEnabled() async => const Success(true);

  @override
  Future<ApiResult<bool>> isLocationEnabled() async => const Success(true);

  @override
  Future<ApiResult<void>> openSettings(DeviceSetting setting) async => const Success(null);
}

class _FakeAppInfo implements AppInfoRepository {
  @override
  Future<ApiResult<String>> getVersion() async => const Success('1.0.0');
}

class _FakeLogoutUseCase implements LogoutUseCase {
  int calls = 0;

  @override
  Future<void> call() async {
    calls++;
  }
}

void main() {
  final getIt = GetIt.instance;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late _FakeLogoutUseCase logoutUseCase;

  setUp(() {
    logoutUseCase = _FakeLogoutUseCase();
    final permissions = _FakePermissions();
    getIt.registerFactory<AccountSettingsCubit>(
      () => AccountSettingsCubit(
        GetAccountSettingsUseCase(permissions, _FakeAppInfo()),
        OpenDeviceSettingsUseCase(permissions),
      ),
    );
  });

  tearDown(() => getIt.reset());

  Future<void> openDrawer(WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Like the real app, the LogoutCubit is provided around the tab shell,
    // above the drawer but not above the routes the drawer pushes.
    final logoutCubit = LogoutCubit(logoutUseCase);
    addTearDown(logoutCubit.close);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(440, 956),
        builder: (context, child) => MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: BlocProvider.value(
            value: logoutCubit,
            child: Scaffold(
              key: scaffoldKey,
              drawer: const PatientSideMenu(),
              body: const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
    scaffoldKey.currentState!.openDrawer();
    await tester.pumpAndSettle();
  }

  testWidgets('lists the destinations but offers no logout (that lives in the settings)', (
    tester,
  ) async {
    await openDrawer(tester);

    for (final label in ['الرئيسية', 'البحث', 'المراسلات', 'الملف الشخصي', 'الإعدادات', 'المساعدة والدعم']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('تسجيل الخروج'), findsNothing);
    expect(find.byIcon(Icons.logout), findsNothing);
  });

  testWidgets('"الإعدادات" closes the drawer and opens the settings screen', (tester) async {
    await openDrawer(tester);

    await tester.tap(find.text('الإعدادات'));
    await tester.pumpAndSettle();

    expect(find.text('التفضيلات'), findsOneWidget);
    expect(find.byType(Drawer), findsNothing);
  });

  testWidgets('logging out from the settings opened here reaches the LogoutCubit', (tester) async {
    await openDrawer(tester);
    await tester.tap(find.text('الإعدادات'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('تسجيل الخروج'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'تسجيل الخروج'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(logoutUseCase.calls, 1);
  });
}
