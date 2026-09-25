import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/patient_notification.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_notifications_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_patient_notifications_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/patient_notifications_cubit.dart';
import 'package:daway_app/features/patient/presentation/screens/patient_notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements PatientNotificationsRepository {
  ApiResult<List<PatientNotification>> result = const Success([]);

  @override
  Future<ApiResult<List<PatientNotification>>> getNotifications({required String token}) async =>
      result;
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession =
      const UserSession(accountType: AccountType.patient, token: 'tok-1');

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

PatientNotification _notification(
  int id,
  PatientNotificationType type,
  String message,
) {
  return PatientNotification(
    id: id,
    type: type,
    message: message,
    isRead: false,
    createdAt: DateTime.now().subtract(Duration(minutes: id * 10)),
  );
}

void main() {
  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // RTL like the real app — the tabs row and items are laid out right-to-left.
  Widget buildTestableScreen(_FakeRepository repository) {
    final cubit = PatientNotificationsCubit(
      GetPatientNotificationsUseCase(repository, _FakeSessionRepository()),
    );
    addTearDown(cubit.close);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocProvider.value(
            value: cubit,
            child: const PatientNotificationsScreen(),
          ),
        ),
      ),
    );
  }

  testWidgets('shows the header and the bell empty state, without tabs, when there are none', (
    tester,
  ) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen(_FakeRepository()));
    await tester.pumpAndSettle();

    expect(find.text('الإشعارات'), findsOneWidget);
    expect(find.text('تابع طلباتك وراجع سجل مشترياتك'), findsOneWidget);
    expect(find.text('لا يوجد إشعارات'), findsOneWidget);
    expect(find.textContaining('الكل ('), findsNothing);
  });

  testWidgets('shows the tabs with counts and every notification under "الكل"', (tester) async {
    await setPhoneViewport(tester);
    final repository = _FakeRepository();
    repository.result = Success([
      _notification(1, PatientNotificationType.system, 'اصدار جديد من دواك متاح الان'),
      _notification(2, PatientNotificationType.inquiryAnswered, 'ردّت صيدلية النور على استفسارك'),
      _notification(3, PatientNotificationType.reminder, 'حان موعد دواء Panadol'),
    ]);

    await tester.pumpWidget(buildTestableScreen(repository));
    await tester.pumpAndSettle();

    expect(find.text('الكل (3)'), findsOneWidget);
    expect(find.text('الطلبات (0)'), findsOneWidget);
    expect(find.text('العروض (0)'), findsOneWidget);
    expect(find.text('النظام (1)'), findsOneWidget);
    expect(find.text('اصدار جديد من دواك متاح الان'), findsOneWidget);
    expect(find.text('ردّت صيدلية النور على استفسارك'), findsOneWidget);
    expect(find.text('حان موعد دواء Panadol'), findsOneWidget);
  });

  testWidgets('tapping "النظام" keeps only the system notifications', (tester) async {
    await setPhoneViewport(tester);
    final repository = _FakeRepository();
    repository.result = Success([
      _notification(1, PatientNotificationType.system, 'اصدار جديد من دواك متاح الان'),
      _notification(2, PatientNotificationType.inquiryAnswered, 'ردّت صيدلية النور على استفسارك'),
    ]);

    await tester.pumpWidget(buildTestableScreen(repository));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('النظام (1)'));
    await tester.tap(find.text('النظام (1)'));
    await tester.pumpAndSettle();

    expect(find.text('اصدار جديد من دواك متاح الان'), findsOneWidget);
    expect(find.text('ردّت صيدلية النور على استفسارك'), findsNothing);
  });

  testWidgets('a tab with nothing in it shows the empty state under the tabs', (tester) async {
    await setPhoneViewport(tester);
    final repository = _FakeRepository();
    repository.result = Success([
      _notification(1, PatientNotificationType.system, 'اصدار جديد من دواك متاح الان'),
    ]);

    await tester.pumpWidget(buildTestableScreen(repository));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('الطلبات (0)'));
    await tester.tap(find.text('الطلبات (0)'));
    await tester.pumpAndSettle();

    expect(find.text('لا يوجد إشعارات'), findsOneWidget);
    expect(find.text('اصدار جديد من دواك متاح الان'), findsNothing);
    expect(find.text('الكل (1)'), findsOneWidget); // tabs stay
  });

  testWidgets('tapping a notification\'s "X" shows the "قريباً" cue (no delete endpoint yet)', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    final repository = _FakeRepository();
    repository.result = Success([
      _notification(1, PatientNotificationType.system, 'اصدار جديد من دواك متاح الان'),
    ]);

    await tester.pumpWidget(buildTestableScreen(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(find.text('قريباً'), findsOneWidget);
  });

  testWidgets('shows an error with a working retry button on failure', (tester) async {
    await setPhoneViewport(tester);
    final repository = _FakeRepository();
    repository.result = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));

    await tester.pumpWidget(buildTestableScreen(repository));
    await tester.pumpAndSettle();
    expect(find.text('تعذر الاتصال بالخادم'), findsOneWidget);

    repository.result = Success([
      _notification(1, PatientNotificationType.system, 'اصدار جديد من دواك متاح الان'),
    ]);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(find.text('اصدار جديد من دواك متاح الان'), findsOneWidget);
  });
}
