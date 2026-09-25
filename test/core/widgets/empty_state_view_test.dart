import 'package:daway_app/core/widgets/empty_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget buildTestable(EmptyStateView view) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(child: view),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows the illustration and title, and nothing optional when none is given', (
    tester,
  ) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(
      buildTestable(
        const EmptyStateView(
          imageAsset: 'assets/images/empty_notifications.png',
          title: 'لا يوجد إشعارات',
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('لا يوجد إشعارات'), findsOneWidget);
    expect(find.byType(GestureDetector), findsNothing);
  });

  testWidgets('the title is ExtraBold, the real weight', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(
      buildTestable(
        const EmptyStateView(
          imageAsset: 'assets/images/empty_notifications.png',
          title: 'لا يوجد إشعارات',
        ),
      ),
    );

    expect(tester.widget<Text>(find.text('لا يوجد إشعارات')).style!.fontWeight, FontWeight.w800);
  });

  testWidgets('shows the subtitle and the action, and the action is tappable', (tester) async {
    await setPhoneViewport(tester);
    var tapped = false;

    await tester.pumpWidget(
      buildTestable(
        EmptyStateView(
          imageAsset: 'assets/images/empty_order.png',
          title: 'لا يوجد طلبات',
          subtitle: 'أضف الطلبات حتى تتمكن من تتبعها',
          actionLabel: 'تصفح الاقسام',
          onActionTap: () => tapped = true,
        ),
      ),
    );

    expect(find.text('أضف الطلبات حتى تتمكن من تتبعها'), findsOneWidget);
    await tester.tap(find.text('تصفح الاقسام'));

    expect(tapped, isTrue);
  });

  testWidgets('the supporting line and the action label are pure black, as in the design', (
    tester,
  ) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(
      buildTestable(
        EmptyStateView(
          imageAsset: 'assets/images/empty_order.png',
          title: 'لا يوجد طلبات',
          subtitle: 'أضف الطلبات حتى تتمكن من تتبعها',
          actionLabel: 'تصفح الاقسام',
          onActionTap: () {},
        ),
      ),
    );

    for (final text in ['أضف الطلبات حتى تتمكن من تتبعها', 'تصفح الاقسام']) {
      expect(
        tester.widget<Text>(find.text(text)).style!.color,
        const Color(0xFF000000),
        reason: text,
      );
    }
  });

  testWidgets('the action button is sized to its text, not stretched full-width', (
    tester,
  ) async {
    // Regression test: Container's `alignment` makes it expand to fill its
    // parent once bounded constraints reach it, even with no explicit width.
    await setPhoneViewport(tester);

    await tester.pumpWidget(
      buildTestable(
        EmptyStateView(
          imageAsset: 'assets/images/empty_order.png',
          title: 'لا يوجد طلبات',
          actionLabel: 'تصفح الاقسام',
          onActionTap: () {},
        ),
      ),
    );

    final buttonSize = tester.getSize(
      find.ancestor(of: find.text('تصفح الاقسام'), matching: find.byType(Container)).first,
    );

    expect(buttonSize.width, lessThan(200));
  });

  testWidgets('a long title wraps under the illustration instead of running wider than it', (
    tester,
  ) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(
      buildTestable(
        const EmptyStateView(
          imageAsset: 'assets/images/empty_reminder.png',
          title: 'لم تقم باضافة اي تذكير لادويتك',
        ),
      ),
    );

    final titleSize = tester.getSize(find.text('لم تقم باضافة اي تذكير لادويتك'));
    final imageSize = tester.getSize(find.byType(Image));

    expect(titleSize.width, lessThanOrEqualTo(imageSize.width));
    expect(titleSize.height, greaterThan(24)); // more than one line
  });
}
