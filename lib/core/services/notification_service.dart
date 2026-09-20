import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

import '../../features/patient/domain/entities/medicine_reminder.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _initialized = true;
  }

  static Future<void> scheduleReminder(MedicineReminder reminder) async {
    await cancelReminder(reminder.id);

    for (final day in reminder.daysOfWeek) {
      final id = _notificationId(reminder.id, day);
      final scheduledDate = _nextInstanceOfDayTime(
        day,
        reminder.hour,
        reminder.minute,
      );

      await _plugin.zonedSchedule(
        id,
        'تذكير دواء',
        'حان موعد ${reminder.name}',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medicine_reminders',
            'تذكيرات الأدوية',
            channelDescription: 'تنبيهات مواعيد الأدوية',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  static Future<void> cancelReminder(String id) async {
    for (var day = 0; day < 7; day++) {
      await _plugin.cancel(_notificationId(id, day));
    }
  }

  /// Combines the reminder id and day-of-week into one notification id.
  /// Multiplying the hash by 10 keeps each reminder's 7 day-slots
  /// contiguous while making cross-reminder collisions require an exact
  /// hash match rather than merely landing within 7 of each other.
  static int _notificationId(String reminderId, int day) =>
      (reminderId.hashCode % 100000) * 10 + day;

  static tz.TZDateTime _nextInstanceOfDayTime(
      int dayOfWeek, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduled.weekday % 7 != dayOfWeek) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }
    return scheduled;
  }
}
