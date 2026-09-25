import 'dart:async';

import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/widgets/app_toggle_switch.dart';
import 'package:daway_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:daway_app/features/auth/presentation/cubit/logout_cubit.dart';
import 'package:daway_app/features/auth/presentation/screens/privacy_policy_screen.dart';
import 'package:daway_app/features/auth/presentation/screens/terms_screen.dart';
import 'package:daway_app/features/patient/domain/entities/device_setting.dart';
import 'package:daway_app/features/patient/domain/repositories/app_info_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/device_permissions_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_account_settings_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/open_device_settings_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/account_settings_cubit.dart';
import 'package:daway_app/features/patient/presentation/screens/patient_settings_screen.dart';
import 'package:daway_app/features/patient/presentation/widgets/account_row_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePermissions implements DevicePermissionsRepository {
  ApiResult<bool> notifications = const Success(true);
  ApiResult<bool> location = const Success(true);
  ApiResult<void> openResult = const Success(null);
  final List<DeviceSetting> opened = [];
  int reads = 0;

  /// When set, reads wait for it (to look at the loading state).
  Completer<void>? hold;

  @override
  Future<ApiResult<bool>> isNotificationsEnabled() async {
    reads++;
    final captured = notifications;
    await hold?.future;
    return captured;
  }

  @override
  Future<ApiResult<bool>> isLocationEnabled() async => location;

  @override
  Future<ApiResult<void>> openSettings(DeviceSetting setting) async {
    opened.add(setting);
    return openResult;
  }
}

class _FakeAppInfo implements AppInfoRepository {
  ApiResult<String> version = const Success('1.0.0');

  @override
  Future<ApiResult<String>> getVersion() async => version;
}

class _FakeLogoutUseCase implements LogoutUseCase {
  int calls = 0;

  @override
  Future<void> call() async {
    calls++;
  }
}

void main() {
  late _FakePermissions permissions;
  late _FakeAppInfo appInfo;
  late _FakeLogoutUseCase logoutUseCase;

  setUp(() {
    permissions = _FakePermissions();
    appInfo = _FakeAppInfo();
    logoutUseCase = _FakeLogoutUseCase();
  });

  Future<void> setViewport(WidgetTester tester, {Size size = const Size(440, 956)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // The app's own Arabic locale, so the sheets (built in the navigator's
  // overlay, above `home`) are right-to-left like in the real app.
  Widget buildTestable() {
    final cubit = AccountSettingsCubit(
      GetAccountSettingsUseCase(permissions, appInfo),
      OpenDeviceSettingsUseCase(permissions),
    );
    addTearDown(cubit.close);
    final logoutCubit = LogoutCubit(logoutUseCase);
    addTearDown(logoutCubit.close);

    return ScreenUtilInit(
      designSize: const Size(440, 956),
      builder: (context, child) => MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: cubit),
            BlocProvider.value(value: logoutCubit),
          ],
          child: const PatientSettingsScreen(),
        ),
      ),
    );
  }

  Future<void> openScreen(WidgetTester tester, {Size size = const Size(440, 956)}) async {
    await setViewport(tester, size: size);
    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();
  }

  List<bool> switchValues(WidgetTester tester) =>
      tester.widgetList<AppToggleSwitch>(find.byType(AppToggleSwitch)).map((s) => s.value).toList();

  group('content', () {
    testWidgets('shows the header, the three sections and the brand footer', (tester) async {
      await openScreen(tester);

      for (final text in [
        'معلومات الحساب',
        'إدارة معلوماتك الشخصية وتفاصيل حسابك',
        'التفضيلات',
        'اللغة',
        'العربية',
        'الإشعارات',
        'الموقع',
        'الخصوصية والأمان',
        'سياسة الخصوصية',
        'الشروط والأحكام',
        'الحساب',
        'تسجيل الخروج',
        'دواك',
        'الإصدار 1.0.0',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
    });

    testWidgets('the switches show the real permission state of each setting', (tester) async {
      permissions.location = const Success(false);

      await openScreen(tester);

      expect(switchValues(tester), [true, false]);
    });

    testWidgets('leaves the version line out when it could not be read', (tester) async {
      appInfo.version = const ApiError(UnknownFailure('boom'));

      await openScreen(tester);

      expect(find.textContaining('الإصدار'), findsNothing);
      expect(find.text('دواك'), findsOneWidget);
    });

    testWidgets('shows every row straight away, with no switches until the device state is read', (
      tester,
    ) async {
      permissions.hold = Completer<void>();
      await setViewport(tester);

      await tester.pumpWidget(buildTestable());
      await tester.pump();

      expect(find.text('التفضيلات'), findsOneWidget);
      expect(find.text('اللغة'), findsOneWidget);
      expect(find.text('تسجيل الخروج'), findsOneWidget);
      expect(find.byType(AppToggleSwitch), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      permissions.hold!.complete();
      await tester.pumpAndSettle();

      expect(find.byType(AppToggleSwitch), findsNWidgets(2));
    });

    testWidgets('a failed read shows an inline error and OFF switches, and the retry works', (
      tester,
    ) async {
      permissions.notifications = const ApiError(PermissionFailure('تعذر قراءة الإعدادات'));
      await openScreen(tester);

      expect(find.text('تعذر قراءة الإعدادات'), findsOneWidget);
      expect(switchValues(tester), [false, false]);

      permissions.notifications = const Success(true);
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pumpAndSettle();

      expect(find.text('تعذر قراءة الإعدادات'), findsNothing);
      expect(switchValues(tester), [true, true]);
    });

    testWidgets('a failed read leaves the language, privacy, terms and logout rows in place', (
      tester,
    ) async {
      permissions.location = const ApiError(PermissionFailure('تعذر قراءة الإعدادات'));

      await openScreen(tester);

      for (final label in ['اللغة', 'سياسة الخصوصية', 'الشروط والأحكام', 'تسجيل الخروج']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('a patient can still log out when the device state cannot be read', (tester) async {
      permissions.location = const ApiError(PermissionFailure('تعذر قراءة الإعدادات'));
      await openScreen(tester);

      await tester.tap(find.text('تسجيل الخروج'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'تسجيل الخروج'));
      await tester.pumpAndSettle();

      expect(logoutUseCase.calls, 1);
    });

    testWidgets('the switch rows still open the system settings when the state is unreadable', (
      tester,
    ) async {
      permissions.notifications = const ApiError(PermissionFailure('تعذر قراءة الإعدادات'));
      await openScreen(tester);

      await tester.tap(find.text('الإشعارات'));
      await tester.pump();

      expect(permissions.opened, [DeviceSetting.notifications]);
    });
  });

  group('device settings rows', () {
    testWidgets('tapping "الإشعارات" sends the user to the notification settings', (tester) async {
      await openScreen(tester);

      await tester.tap(find.text('الإشعارات'));
      await tester.pump();

      expect(permissions.opened, [DeviceSetting.notifications]);
    });

    testWidgets('tapping "الموقع" sends the user to the location settings', (tester) async {
      await openScreen(tester);

      await tester.tap(find.text('الموقع'));
      await tester.pump();

      expect(permissions.opened, [DeviceSetting.location]);
    });

    testWidgets('tapping the switch itself does the same as tapping the row', (tester) async {
      await openScreen(tester);

      await tester.tap(find.byType(AppToggleSwitch).first);
      await tester.pump();

      expect(permissions.opened, [DeviceSetting.notifications]);
    });

    testWidgets('shows the reason when the system screen could not be opened', (tester) async {
      permissions.openResult = const ApiError(PermissionFailure('تعذر فتح إعدادات الجهاز'));
      await openScreen(tester);

      await tester.tap(find.text('الإشعارات'));
      await tester.pump();

      expect(find.text('تعذر فتح إعدادات الجهاز'), findsOneWidget);
    });

    testWidgets('re-reads the device state when the app comes back from system settings', (
      tester,
    ) async {
      await openScreen(tester);
      expect(switchValues(tester), [true, true]);

      permissions.notifications = const Success(false);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(switchValues(tester), [false, true]);
    });
  });

  group('language', () {
    testWidgets('the row shows the current language and opens the picker', (tester) async {
      await openScreen(tester);

      await tester.tap(find.text('اللغة'));
      await tester.pumpAndSettle();

      expect(find.text('اختر اللغة'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('picking the current language just closes the picker', (tester) async {
      await openScreen(tester);
      await tester.tap(find.text('اللغة'));
      await tester.pumpAndSettle();

      // "العربية" is on screen twice now (the row's value and the option):
      // the option is the one inside the sheet.
      await tester.tap(find.descendant(of: find.byType(BottomSheet), matching: find.text('العربية')));
      await tester.pumpAndSettle();

      expect(find.text('اختر اللغة'), findsNothing);
      expect(find.text('قريباً'), findsNothing);
    });

    testWidgets('picking English shows the "قريباً" cue, as there is no translation yet', (
      tester,
    ) async {
      await openScreen(tester);
      await tester.tap(find.text('اللغة'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(find.text('اختر اللغة'), findsNothing);
      expect(find.text('قريباً'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget); // still Arabic
    });
  });

  group('privacy and account', () {
    testWidgets('"سياسة الخصوصية" opens the privacy policy', (tester) async {
      await openScreen(tester);

      await tester.tap(find.text('سياسة الخصوصية'));
      await tester.pumpAndSettle();

      expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
    });

    testWidgets('"الشروط والأحكام" opens the terms', (tester) async {
      await openScreen(tester);

      await tester.tap(find.text('الشروط والأحكام'));
      await tester.pumpAndSettle();

      expect(find.byType(TermsScreen), findsOneWidget);
    });

    testWidgets('logging out asks first, and only a confirmation ends the session', (tester) async {
      await openScreen(tester);

      await tester.tap(find.text('تسجيل الخروج'));
      await tester.pumpAndSettle();
      expect(find.text('تسجيل الخروج؟'), findsOneWidget);
      expect(logoutUseCase.calls, 0);

      await tester.tap(find.widgetWithText(ElevatedButton, 'تسجيل الخروج'));
      await tester.pumpAndSettle();

      expect(logoutUseCase.calls, 1);
      expect(find.text('تسجيل الخروج؟'), findsNothing);
    });

    testWidgets('cancelling the logout sheet keeps the session', (tester) async {
      await openScreen(tester);
      await tester.tap(find.text('تسجيل الخروج'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();

      expect(logoutUseCase.calls, 0);
      expect(find.text('تسجيل الخروج؟'), findsNothing);
    });

    testWidgets('the back button pops the screen', (tester) async {
      await setViewport(tester);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(440, 956),
          builder: (context, child) => MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (_) => AccountSettingsCubit(
                              GetAccountSettingsUseCase(permissions, appInfo),
                              OpenDeviceSettingsUseCase(permissions),
                            ),
                          ),
                          BlocProvider(create: (_) => LogoutCubit(logoutUseCase)),
                        ],
                        child: const PatientSettingsScreen(),
                      ),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('التفضيلات'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('authBackButton')));
      await tester.pumpAndSettle();

      expect(find.text('التفضيلات'), findsNothing);
    });
  });

  group('layout', () {
    testWidgets('the cards follow the design: 56 tall (58 for logout), 16 apart within a group', (
      tester,
    ) async {
      await openScreen(tester);

      final cards = [
        for (var i = 0; i < 6; i++) tester.getRect(find.byType(AccountRowCard).at(i)),
      ];

      expect(cards.map((c) => c.height), [56, 56, 56, 56, 56, 58]);
      expect(cards.map((c) => c.width), everyElement(392));
      expect(cards[1].top - cards[0].bottom, 16); // language -> notifications
      expect(cards[2].top - cards[1].bottom, 16); // notifications -> location
      expect(cards[4].top - cards[3].bottom, 16); // privacy -> terms
      // 32 + the 20-tall group title + 8 between groups (24 before the last one).
      expect(cards[3].top - cards[2].bottom, 32 + 20 + 8);
      expect(cards[5].top - cards[4].bottom, 24 + 20 + 8);
    });

    testWidgets('a row reads right-to-left: icon at the right edge, switch at the left', (
      tester,
    ) async {
      await openScreen(tester);
      final card = tester.getRect(find.byType(AccountRowCard).at(1));

      final icon = tester.getRect(
        find.descendant(of: find.byType(AccountRowCard).at(1), matching: find.byType(SvgPicture)),
      );
      final label = tester.getRect(find.text('الإشعارات'));
      final toggle = tester.getRect(find.byType(AppToggleSwitch).first);

      // 1 border + 16 padding on each side.
      expect(card.right - icon.right, closeTo(17, 0.5));
      expect(icon.size, const Size(22, 22));
      expect(icon.left - label.right, closeTo(8, 0.5)); // 8 between icon and label
      expect(toggle.left - card.left, closeTo(17, 0.5));
      expect(toggle.size, const Size(50, 28));
    });

    testWidgets('the language row ends with the value, 8 from a chevron, at the left', (tester) async {
      await openScreen(tester);
      final card = tester.getRect(find.byType(AccountRowCard).first);

      final value = tester.getRect(find.text('العربية'));
      final chevron = tester.getRect(
        find.descendant(
          of: find.byType(AccountRowCard).first,
          matching: find.byType(AccountRowChevron),
        ),
      );

      expect(chevron.left - card.left, closeTo(17, 0.5));
      expect(chevron.size, const Size(18, 18));
      expect(value.left - chevron.right, closeTo(8, 0.5));
    });

    testWidgets('the logout row has the label at the right and the red icon at the left', (
      tester,
    ) async {
      await openScreen(tester);
      final card = tester.getRect(find.byType(AccountRowCard).last);

      final label = tester.getRect(find.text('تسجيل الخروج'));
      final icon = tester.getRect(
        find.descendant(of: find.byType(AccountRowCard).last, matching: find.byType(SvgPicture)),
      );

      expect(card.right - label.right, closeTo(17, 0.5));
      expect(icon.left - card.left, closeTo(17, 0.5));
      final style = tester.widget<Text>(find.text('تسجيل الخروج')).style!;
      expect(style.color, const Color(0xFFDC2626));
    });

    testWidgets('the brand footer is pinned 50 above the bottom, mark to the left of the name', (
      tester,
    ) async {
      await openScreen(tester);

      final version = tester.getRect(find.text('الإصدار 1.0.0'));
      final name = tester.getRect(find.text('دواك'));
      final mark = tester.getRect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container && widget.constraints == BoxConstraints.tightFor(width: 34, height: 34),
        ),
      );

      expect(956 - version.bottom, closeTo(50, 0.5));
      expect(version.height, closeTo(20, 0.5));
      expect(mark.size, const Size(34, 34));
      expect(name.left - mark.right, closeTo(8, 0.5));
      expect(mark.center.dx, lessThan(name.center.dx));
      expect(((mark.left + name.right) / 2), closeTo(220, 1)); // centered on the screen
    });

    testWidgets('scrolls instead of overflowing on a short screen', (tester) async {
      await openScreen(tester, size: const Size(440, 600));

      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.text('الإصدار 1.0.0'), 200);
      expect(find.text('الإصدار 1.0.0'), findsOneWidget);
    });
  });
}
