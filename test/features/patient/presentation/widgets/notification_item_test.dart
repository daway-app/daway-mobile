import 'package:daway_app/features/patient/domain/entities/patient_notification.dart';
import 'package:daway_app/features/patient/presentation/widgets/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // RTL like the real app — the item's layout is right-to-left.
  Widget buildTestable(PatientNotification notification, {VoidCallback? onDismissTap}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: NotificationItem(
              notification: notification,
              onDismissTap: onDismissTap ?? () {},
            ),
          ),
        ),
      ),
    );
  }

  PatientNotification notification({
    PatientNotificationType type = PatientNotificationType.system,
    String message = 'اصدار جديد من دواك متاح الان',
  }) {
    return PatientNotification(
      id: 1,
      type: type,
      message: message,
      isRead: false,
      // A fixed, old date: it renders as an absolute "1 يناير 2020، 9:30 ص", so
      // nothing here depends on the clock (a relative "10 minutes ago" would
      // read "yesterday" for a test run just after midnight).
      createdAt: DateTime(2020, 1, 1, 9, 30),
    );
  }

  testWidgets('shows a per-type title, the message, the category chip and the time', (
    tester,
  ) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestable(notification()));

    expect(find.text('إشعار من النظام'), findsOneWidget);
    expect(find.text('اصدار جديد من دواك متاح الان'), findsOneWidget);
    expect(find.text('النظام'), findsOneWidget);
    expect(find.text('1 يناير 2020، 9:30 ص'), findsOneWidget);
  });

  testWidgets('the icon follows the kind of notification instead of always being the order bag', (
    tester,
  ) async {
    await setPhoneViewport(tester);

    for (final (type, asset) in [
      (PatientNotificationType.medicineAvailable, 'assets/icons/order_icon.svg'),
      (PatientNotificationType.inquiryAnswered, 'assets/icons/massage_icon.svg'),
      (PatientNotificationType.reminder, 'assets/icons/timer_icon.svg'),
      (PatientNotificationType.system, 'assets/icons/bell_icon.svg'),
    ]) {
      await tester.pumpWidget(buildTestable(notification(type: type)));

      final loader = tester.widget<SvgPicture>(find.byType(SvgPicture)).bytesLoader as SvgAssetLoader;
      expect(loader.assetName, asset, reason: '$type');
    }
  });

  testWidgets('derives a different title and chip for each type', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(
      buildTestable(notification(type: PatientNotificationType.inquiryAnswered)),
    );

    expect(find.text('تم الرد على استفسارك'), findsOneWidget);
    expect(find.text('الاستفسارات'), findsOneWidget);
  });

  testWidgets('lays out right-to-left like the design', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestable(notification()));

    final item = tester.getRect(find.byType(NotificationItem));
    // The 40x42 box around the SVG icon.
    final icon = tester.getRect(
      find.ancestor(of: find.byType(SvgPicture), matching: find.byType(Container)).first,
    );
    final title = tester.getRect(find.text('إشعار من النظام'));
    final close = tester.getRect(find.byIcon(Icons.close));

    // Icon box hugging the right padding (16), title beside it, "X" at the far left.
    expect(item.right - icon.right, closeTo(16, 1));
    expect(title.center.dx, lessThan(icon.center.dx));
    expect(close.center.dx, lessThan(title.center.dx));
    expect(close.left - item.left, lessThan(16 + 8));

    // Title hugs the icon (11 gap), right-aligned in the text column.
    expect(icon.left - title.right, closeTo(11, 1));

    // Chip on the right, the time to its left.
    final chip = tester.getRect(find.text('النظام')).center.dx;
    final time = tester.getRect(find.text('1 يناير 2020، 9:30 ص')).center.dx;
    expect(chip, greaterThan(time));
  });

  testWidgets('tapping the "X" invokes onDismissTap', (tester) async {
    await setPhoneViewport(tester);
    var dismissed = false;

    await tester.pumpWidget(buildTestable(notification(), onDismissTap: () => dismissed = true));
    await tester.tap(find.byIcon(Icons.close));

    expect(dismissed, isTrue);
  });
}
