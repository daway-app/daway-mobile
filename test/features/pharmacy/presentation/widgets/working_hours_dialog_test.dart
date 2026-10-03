import 'package:daway_app/features/pharmacy/domain/entities/working_hours_entry.dart';
import 'package:daway_app/features/pharmacy/presentation/widgets/working_hours_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';

const _week = [
  WorkingHoursEntry(day: WeekDay.sat, open: '09:00', close: '22:00'),
  WorkingHoursEntry(day: WeekDay.sun, open: '09:00', close: '22:00'),
  WorkingHoursEntry(day: WeekDay.fri),
];

void main() {
  List<WorkingHoursEntry>? result;
  var closed = false;

  Future<void> openDialog(
    WidgetTester tester, {
    List<WorkingHoursEntry> initial = _week,
  }) async {
    result = null;
    closed = false;
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await WorkingHoursDialog.show(
                  context,
                  initial: initial,
                );
                closed = true;
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  /// The on/off switch on [day]'s row.
  Finder toggleOf(String day) {
    final row = find
        .ancestor(of: find.text(day), matching: find.byType(Row))
        .first;
    return find.descendant(of: row, matching: find.byType(AnimatedContainer));
  }

  testWidgets('lists all seven days, even ones the profile came back without', (
    tester,
  ) async {
    await openDialog(tester);

    for (final day in [
      'السبت',
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
    ]) {
      expect(find.text(day), findsOneWidget);
    }
  });

  testWidgets('shows from/to hours for an open day and مغلق for a closed one', (
    tester,
  ) async {
    await openDialog(tester);

    expect(find.text('من 9ص'), findsNWidgets(2));
    expect(find.text('إلى 10م'), findsNWidgets(2));
    expect(find.text('مغلق'), findsNWidgets(5));
  });

  testWidgets('confirming without changes returns the same week, in order', (
    tester,
  ) async {
    await openDialog(tester);

    await tester.tap(find.text('تم'));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(result!.map((e) => e.day), WeekDay.values);
    expect(result!.first.open, '09:00');
    expect(result!.last.isOpen, isFalse);
  });

  testWidgets('cancelling returns nothing', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(result, isNull);
  });

  testWidgets('a closed day can be opened, with the default hours', (
    tester,
  ) async {
    await openDialog(tester);

    await tester.tap(toggleOf('الجمعة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تم'));
    await tester.pumpAndSettle();

    final friday = result!.firstWhere((e) => e.day == WeekDay.fri);
    expect(friday.open, '09:00');
    expect(friday.close, '22:00');
  });

  testWidgets('an open day can be switched off', (tester) async {
    await openDialog(tester);

    await tester.tap(toggleOf('السبت'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تم'));
    await tester.pumpAndSettle();

    expect(result!.firstWhere((e) => e.day == WeekDay.sat).isOpen, isFalse);
  });

  testWidgets(
    'a day that opens and closes at the same hour cannot be confirmed',
    (tester) async {
      await openDialog(
        tester,
        initial: const [
          WorkingHoursEntry(day: WeekDay.sat, open: '09:00', close: '09:00'),
        ],
      );

      await tester.tap(find.text('تم'));
      await tester.pumpAndSettle();

      expect(closed, isFalse);
      expect(find.text('ساعات العمل'), findsOneWidget);
    },
  );
}
