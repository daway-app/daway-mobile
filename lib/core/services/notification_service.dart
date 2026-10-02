import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

import '../../features/patient/domain/entities/medicine_reminder.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    // Without this tz.local stays UTC, so a reminder set for 8:00 would fire
    // at 8:00 UTC (11:00 in Palestine) and look like it never went off.
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      // Unknown zone name: keep the UTC default rather than fail startup.
    }

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
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    // Android 12+ (S): exact alarms need this granted separately from the
    // notification permission above — opens the system "alarms & reminders"
    // settings screen. scheduleReminder() falls back to an inexact alarm if
    // it's denied, so this not being granted degrades timing rather than
    // silently dropping the reminder.
    await androidPlugin?.requestExactAlarmsPermission();
    _initialized = true;
  }

  /// The most time-of-day slots any [ReminderFrequency] uses (every 6
  /// hours = 4/day) — how many notification ids [cancelReminder] clears per
  /// reminder, and the multiplier that keeps them contiguous per reminder.
  static const _maxSlotsPerReminder = 4;

  static Future<void> scheduleReminder(MedicineReminder reminder) async {
    await cancelReminder(reminder.id);

    final scheduleMode = await _androidScheduleMode();
    final times = reminder.dailyTimes;
    for (var slot = 0; slot < times.length; slot++) {
      final (hour, minute) = times[slot];
      final id = _notificationId(reminder.id, slot);
      final scheduledDate = _nextInstanceOfTime(hour, minute);

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
        androidScheduleMode: scheduleMode,
        // Repeats daily at that clock time, any weekday — unlike the old
        // per-weekday model this replaces (see MedicineReminder's doc
        // comment), a reminder no longer targets specific days.
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  /// Exact (fires within seconds of the target time, even in Doze) when the
  /// exact-alarms permission `init()` requested is actually granted;
  /// otherwise Android would silently refuse to schedule a *recurring*
  /// exact alarm at all rather than just delaying it (per the plugin's own
  /// README), so this falls back to an inexact-but-still-while-idle alarm —
  /// a few minutes late beats not going off.
  static Future<AndroidScheduleMode> _androidScheduleMode() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) {
      // Not Android (this branch only runs there anyway — iOS ignores
      // androidScheduleMode).
      return AndroidScheduleMode.exactAllowWhileIdle;
    }
    final canScheduleExact = await androidPlugin.canScheduleExactNotifications();
    return canScheduleExact ?? false
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  static Future<void> cancelReminder(String id) async {
    for (var slot = 0; slot < _maxSlotsPerReminder; slot++) {
      await _plugin.cancel(_notificationId(id, slot));
    }
  }

  /// Combines the reminder id and time-of-day slot into one notification
  /// id. Multiplying the hash by 10 keeps each reminder's slots contiguous
  /// while making cross-reminder collisions require an exact hash match
  /// rather than merely landing within [_maxSlotsPerReminder] of each other.
  static int _notificationId(String reminderId, int slot) =>
      (reminderId.hashCode % 100000) * 10 + slot;

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
