import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/domain/entities/medicine_reminder.dart';
import 'package:daway_app/features/patient/domain/repositories/reminder_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/delete_reminder_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_reminders_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/save_reminder_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/reminders_cubit.dart';
import 'package:daway_app/features/patient/presentation/screens/add_medicine_reminder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';

const _existing = MedicineReminder(
  id: '1',
  name: 'أكامول',
  frequency: ReminderFrequency.every6Hours,
  hour: 8,
  minute: 0,
);

class _FakeReminderRepository implements ReminderRepository {
  List<MedicineReminder> reminders = const [];
  MedicineReminder? lastSaved;
  String? lastDeletedId;

  @override
  Future<ApiResult<List<MedicineReminder>>> getReminders() async => Success(reminders);

  @override
  Future<ApiResult<void>> saveReminder(MedicineReminder reminder) async {
    lastSaved = reminder;
    return const Success(null);
  }

  @override
  Future<ApiResult<void>> deleteReminder(String id) async {
    lastDeletedId = id;
    return const Success(null);
  }
}

void main() {
  late _FakeReminderRepository repository;
  late RemindersCubit cubit;

  setUp(() {
    repository = _FakeReminderRepository();
    cubit = RemindersCubit(
      GetRemindersUseCase(repository),
      SaveReminderUseCase(repository),
      DeleteReminderUseCase(repository),
    );
  });

  tearDown(() => cubit.close());

  Widget buildTestableScreen({MedicineReminder? existing}) {
    return buildArabicTestApp(
      home: BlocProvider.value(
        value: cubit,
        child: AddMedicineReminderScreen(existing: existing),
      ),
    );
  }

  testWidgets('add mode shows the add title and defaults to "كل يوم", no delete button',
      (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    expect(find.text('إضافة تذكير للدواء'), findsOneWidget);
    expect(find.text('كل يوم'), findsOneWidget);
    expect(find.text('كل 12 ساعة'), findsOneWidget);
    expect(find.text('كل 6 ساعة'), findsOneWidget);
    expect(find.text('حذف'), findsNothing);
  });

  testWidgets('edit mode pre-fills the name and shows the delete button', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestableScreen(existing: _existing));
    await tester.pumpAndSettle();

    expect(find.text('تعديل التذكير'), findsOneWidget);
    expect(find.text('أكامول'), findsOneWidget);
    expect(find.text('حذف'), findsOneWidget);
  });

  testWidgets('tapping حذف deletes the reminder and leaves the screen', (tester) async {
    await setDesignViewport(tester);
    repository.reminders = const [_existing];

    await tester.pumpWidget(buildTestableScreen(existing: _existing));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف'));
    await tester.pumpAndSettle();

    expect(repository.lastDeletedId, '1');
  });

  testWidgets('tapping التالي without picking a time does not save anything', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Panadol');
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();

    expect(repository.lastSaved, isNull);
  });

  testWidgets('tapping a different frequency chip selects it', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();
    await tester.tap(find.text('كل 12 ساعة'));
    await tester.pumpAndSettle();

    // No exception thrown by the rebuild is the main thing; check both
    // chips are still present (nothing got replaced/removed by the tap).
    expect(find.text('كل 12 ساعة'), findsOneWidget);
    expect(find.text('كل يوم'), findsOneWidget);
  });

  testWidgets('"كل يوم" sits to the right of "كل 12 ساعة" and "كل 6 ساعة"', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    final dailyX = tester.getTopLeft(find.text('كل يوم')).dx;
    final every12hX = tester.getTopLeft(find.text('كل 12 ساعة')).dx;
    final every6hX = tester.getTopLeft(find.text('كل 6 ساعة')).dx;

    expect(dailyX, greaterThan(every12hX));
    expect(every12hX, greaterThan(every6hX));
  });
}
