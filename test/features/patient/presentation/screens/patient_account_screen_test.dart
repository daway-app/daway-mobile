import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:daway_app/features/auth/presentation/cubit/logout_cubit.dart';
import 'package:daway_app/features/patient/domain/entities/device_setting.dart';
import 'package:daway_app/features/patient/domain/repositories/app_info_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/device_permissions_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_account_settings_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/open_device_settings_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/account_settings_cubit.dart';
import 'package:daway_app/features/patient/presentation/screens/patient_account_screen.dart';
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

  Future<void> openHub(WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Like the real app, the LogoutCubit is provided around the tab shell —
    // above the hub, but NOT above the routes the hub pushes.
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
          home: BlocProvider.value(value: logoutCubit, child: const PatientAccountScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('offers no logout: that lives only in the settings screen', (tester) async {
    await openHub(tester);

    expect(find.text('تسجيل الخروج'), findsNothing);
    expect(find.byIcon(Icons.logout), findsNothing);
    expect(find.text('الإعدادات'), findsOneWidget);
  });

  testWidgets('"الإعدادات" opens the account-settings screen', (tester) async {
    await openHub(tester);

    await tester.ensureVisible(find.text('الإعدادات'));
    await tester.tap(find.text('الإعدادات'));
    await tester.pumpAndSettle();

    expect(find.text('التفضيلات'), findsOneWidget);
    expect(find.text('الخصوصية والأمان'), findsOneWidget);
  });

  testWidgets('logging out from the pushed settings screen reaches the hub\'s LogoutCubit', (
    tester,
  ) async {
    await openHub(tester);
    await tester.ensureVisible(find.text('الإعدادات'));
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
