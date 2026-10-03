import 'package:daway_app/core/models/picked_location.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/features/pharmacy/domain/entities/pharmacy_profile.dart';
import 'package:daway_app/features/pharmacy/domain/entities/working_hours_entry.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_profile_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_profile_state.dart';
import 'package:daway_app/features/pharmacy/presentation/screens/pharmacy_account_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';

const _profile = PharmacyProfile(
  pharmacyId: 'PH-1234',
  name: 'صيدلية النور',
  phone: '+970595554729',
  latitude: 31.5,
  longitude: 34.47,
  address: 'غزة-السرايا',
  workingHours: [
    WorkingHoursEntry(day: WeekDay.sat, open: '09:00', close: '22:00'),
    WorkingHoursEntry(day: WeekDay.sun, open: '09:00', close: '22:00'),
    WorkingHoursEntry(day: WeekDay.fri),
  ],
);

/// Edits state the way the real cubit does and records the calls the screen
/// makes, without any repository behind it.
class _FakeProfileCubit extends Cubit<PharmacyProfileState>
    implements PharmacyProfileCubit {
  _FakeProfileCubit() : super(PharmacyProfileLoaded.fromProfile(_profile));

  int saves = 0;
  int discards = 0;

  PharmacyProfileLoaded get loaded => state as PharmacyProfileLoaded;

  @override
  void nameChanged(String value) => emit(loaded.copyWith(name: value));

  @override
  void locationSelected(PickedLocation location) => emit(
    loaded.copyWith(
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
    ),
  );

  @override
  void workingHoursReplaced(List<WorkingHoursEntry> entries) =>
      emit(loaded.copyWith(workingHours: entries));

  @override
  Future<void> save() async => saves++;

  @override
  void discardEdits() {
    discards++;
    emit(PharmacyProfileLoaded.fromProfile(_profile));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeProfileCubit cubit;

  setUp(() => cubit = _FakeProfileCubit());
  tearDown(() => cubit.close());

  /// The screen is pushed above a first page, as the settings tab pushes it, so
  /// the back chip has somewhere to return to.
  Future<void> pumpScreen(WidgetTester tester) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        onGenerateRoute: (settings) {
          if (settings.name != Routes.locationPickerScreen) return null;
          return MaterialPageRoute<PickedLocation>(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).pop(
                  const PickedLocation(
                    latitude: 31.4,
                    longitude: 34.3,
                    address: 'خان يونس',
                  ),
                ),
                child: const Text('confirm location'),
              ),
            ),
          );
        },
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider<PharmacyProfileCubit>.value(
                    value: cubit,
                    child: const PharmacyAccountInfoScreen(),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  /// The "تعديل" chip on the row of [label].
  Finder editChipOf(String label) {
    // The label sits above its row: the chip is the n-th "تعديل" on screen.
    const order = [
      'الاسم',
      'رقم الهاتف',
      'العنوان',
      'ساعات العمل',
      'كلمة المرور',
    ];
    return find.text('تعديل').at(order.indexOf(label));
  }

  testWidgets('shows the pharmacy\'s details, one row each', (tester) async {
    await pumpScreen(tester);

    expect(find.text('معلومات الحساب'), findsOneWidget);
    for (final label in [
      'الاسم',
      'رقم الهاتف',
      'العنوان',
      'ساعات العمل',
      'كلمة المرور',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('+970595554729'), findsOneWidget);
    expect(find.text('غزة-السرايا'), findsOneWidget);
    expect(find.text('9ص - 10م'), findsOneWidget);
    expect(find.text('*******'), findsOneWidget);
    expect(find.text('تعديل'), findsNWidgets(5));
  });

  testWidgets('the save button does nothing until something changes', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.ensureVisible(find.text('حفظ التعديلات'));
    await tester.tap(find.text('حفظ التعديلات'));
    await tester.pump();

    expect(cubit.saves, 0);
  });

  testWidgets(
    'editing the name turns its row into a field, and saving calls the cubit',
    (tester) async {
      await pumpScreen(tester);

      await tester.tap(editChipOf('الاسم'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'صيدلية الأمل');
      await tester.pump();
      await tester.ensureVisible(find.text('حفظ التعديلات'));
      await tester.tap(find.text('حفظ التعديلات'));
      await tester.pump();

      expect(cubit.loaded.name, 'صيدلية الأمل');
      expect(cubit.saves, 1);
    },
  );

  testWidgets('the phone and password have no edit flow yet', (tester) async {
    await pumpScreen(tester);

    await tester.tap(editChipOf('رقم الهاتف'));
    await tester.pump();
    expect(find.text('قريباً'), findsOneWidget);

    await tester.tap(editChipOf('كلمة المرور'));
    await tester.pump();
    expect(find.text('قريباً'), findsOneWidget);
    expect(cubit.loaded.hasChanges, isFalse);
  });

  testWidgets('editing the address opens the map and keeps what it returns', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(editChipOf('العنوان'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('confirm location'));
    await tester.pumpAndSettle();

    expect(find.text('خان يونس'), findsOneWidget);
    expect(cubit.loaded.latitude, 31.4);
    expect(cubit.loaded.hasChanges, isTrue);
  });

  testWidgets(
    'editing the working hours opens the dialog and keeps its result',
    (tester) async {
      await pumpScreen(tester);

      await tester.tap(editChipOf('ساعات العمل'));
      await tester.pumpAndSettle();
      expect(find.text('حدد ساعة الفتح والإغلاق لكل يوم'), findsOneWidget);

      // Switch Saturday off, then confirm.
      final saturdayRow = find
          .ancestor(of: find.text('السبت'), matching: find.byType(Row))
          .first;
      await tester.tap(
        find.descendant(
          of: saturdayRow,
          matching: find.byType(AnimatedContainer),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('تم'));
      await tester.pumpAndSettle();

      expect(
        cubit.loaded.workingHours
            .firstWhere((e) => e.day == WeekDay.sat)
            .isOpen,
        isFalse,
      );
      // Only Sunday is left open, and its hours are the shared ones.
      expect(find.text('9ص - 10م'), findsOneWidget);
    },
  );

  testWidgets('cancelling the working-hours dialog changes nothing', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(editChipOf('ساعات العمل'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();

    expect(cubit.loaded.hasChanges, isFalse);
  });

  testWidgets('leaving the screen discards what was not saved', (tester) async {
    await pumpScreen(tester);
    cubit.nameChanged('اسم غير محفوظ');

    await tester.tap(find.byKey(const ValueKey('authBackButton')));
    await tester.pumpAndSettle();

    expect(cubit.discards, 1);
    expect(cubit.loaded.name, 'صيدلية النور');
  });
}
