import 'package:daway_app/features/patient/domain/entities/medicine_reminder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dailyTimes', () {
    test('daily fires once, at the given time', () {
      const reminder = MedicineReminder(
        id: '1',
        name: 'Panadol',
        frequency: ReminderFrequency.daily,
        hour: 9,
        minute: 30,
      );

      expect(reminder.dailyTimes, [(9, 30)]);
    });

    test('every12Hours fires twice, 12 hours apart', () {
      const reminder = MedicineReminder(
        id: '1',
        name: 'Panadol',
        frequency: ReminderFrequency.every12Hours,
        hour: 8,
        minute: 0,
      );

      expect(reminder.dailyTimes, [(8, 0), (20, 0)]);
    });

    test('every6Hours fires 4 times, 6 hours apart, wrapping past midnight', () {
      const reminder = MedicineReminder(
        id: '1',
        name: 'Panadol',
        frequency: ReminderFrequency.every6Hours,
        hour: 22,
        minute: 0,
      );

      expect(reminder.dailyTimes, [(22, 0), (4, 0), (10, 0), (16, 0)]);
    });

    test('the minute offset is preserved on every wrapped slot', () {
      const reminder = MedicineReminder(
        id: '1',
        name: 'Panadol',
        frequency: ReminderFrequency.every6Hours,
        hour: 7,
        minute: 15,
      );

      expect(reminder.dailyTimes, [(7, 15), (13, 15), (19, 15), (1, 15)]);
    });
  });

  group('labels', () {
    test('formattedTime renders 12-hour Arabic AM/PM', () {
      const morning = MedicineReminder(
        id: '1',
        name: 'x',
        frequency: ReminderFrequency.daily,
        hour: 9,
        minute: 5,
      );
      const noon = MedicineReminder(
        id: '1',
        name: 'x',
        frequency: ReminderFrequency.daily,
        hour: 12,
        minute: 0,
      );
      const evening = MedicineReminder(
        id: '1',
        name: 'x',
        frequency: ReminderFrequency.daily,
        hour: 22,
        minute: 0,
      );
      const midnight = MedicineReminder(
        id: '1',
        name: 'x',
        frequency: ReminderFrequency.daily,
        hour: 0,
        minute: 0,
      );

      expect(morning.formattedTime, '9:05 ص');
      expect(noon.formattedTime, '12:00 م');
      expect(evening.formattedTime, '10:00 م');
      expect(midnight.formattedTime, '12:00 ص');
    });

    test('scheduleLabel and alertLabel differ by frequency', () {
      const daily = MedicineReminder(
        id: '1',
        name: 'x',
        frequency: ReminderFrequency.daily,
        hour: 8,
        minute: 0,
      );
      const every6h = MedicineReminder(
        id: '1',
        name: 'x',
        frequency: ReminderFrequency.every6Hours,
        hour: 8,
        minute: 0,
      );

      expect(daily.scheduleLabel, 'كل يوم');
      expect(daily.alertLabel, 'تنبيه يومياً الساعة 8:00 ص');
      expect(every6h.scheduleLabel, 'كل 6 ساعة');
      expect(every6h.alertLabel, 'تنبيه كل 6 ساعة بدءاً من 8:00 ص');
    });
  });

  group('JSON round-trip', () {
    test('toJson/fromJson preserves every field, including frequency', () {
      const reminder = MedicineReminder(
        id: '42',
        name: 'Panadol',
        frequency: ReminderFrequency.every12Hours,
        hour: 14,
        minute: 30,
      );

      final restored = MedicineReminder.fromJson(reminder.toJson());

      expect(restored.id, reminder.id);
      expect(restored.name, reminder.name);
      expect(restored.frequency, reminder.frequency);
      expect(restored.hour, reminder.hour);
      expect(restored.minute, reminder.minute);
    });

    test('an unrecognized/missing frequency falls back to daily, not a crash', () {
      final restored = MedicineReminder.fromJson({'id': '1', 'name': 'x'});

      expect(restored.frequency, ReminderFrequency.daily);
    });
  });
}
