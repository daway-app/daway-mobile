import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/domain/entities/medicine_reminder.dart';
import 'package:daway_app/features/patient/domain/repositories/reminder_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/delete_reminder_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_reminders_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/save_reminder_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/reminders_cubit.dart';
import 'package:daway_app/features/patient/presentation/screens/medicine_reminders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class _FakeReminderRepository implements ReminderRepository {
  List<MedicineReminder> reminders = const [];

  @override
  Future<ApiResult<List<MedicineReminder>>> getReminders() async => Success(reminders);

  @override
  Future<ApiResult<void>> saveReminder(MedicineReminder reminder) async => const Success(null);

  @override
  Future<ApiResult<void>> deleteReminder(String id) async => const Success(null);
}

void main() {
  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  final getIt = GetIt.instance;
  late _FakeReminderRepository repository;

  setUp(() {
    repository = _FakeReminderRepository();
    getIt.registerFactory<RemindersCubit>(
      () => RemindersCubit(
        GetRemindersUseCase(repository),
        SaveReminderUseCase(repository),
        DeleteReminderUseCase(repository),
      ),
    );
  });

  tearDown(() => getIt.reset());

  Widget buildTestableScreen() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: MedicineRemindersScreen(),
        ),
      ),
    );
  }

  testWidgets('shows the alarm-clock empty state when there are no reminders', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    expect(find.text('تذكيرات الأدوية'), findsOneWidget);
    expect(find.text('لم تقم باضافة اي تذكير لادويتك'), findsOneWidget);
    expect(find.text('أضف تذكير'), findsOneWidget);
    expect(find.text('اضافة تذكير جديد'), findsNothing); // the list's own add button
  });

  testWidgets('tapping "أضف تذكير" opens the add-reminder sheet', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();
    await tester.tap(find.text('أضف تذكير'));
    await tester.pumpAndSettle();

    expect(find.text('إضافة تذكير جديد'), findsOneWidget);
  });

  testWidgets('shows the reminders list, not the empty state, once there is a reminder', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    repository.reminders = const [
      MedicineReminder(
        id: '1',
        name: 'أكامول',
        daysOfWeek: [0, 1, 2, 3, 4, 5, 6],
        hour: 10,
        minute: 0,
      ),
    ];

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    expect(find.text('أكامول'), findsOneWidget);
    expect(find.text('اضافة تذكير جديد'), findsOneWidget);
    expect(find.text('لم تقم باضافة اي تذكير لادويتك'), findsNothing);
  });
}
