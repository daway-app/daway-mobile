import 'package:daway_app/core/widgets/filter_tabs_row.dart';
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

  const tabs = [
    FilterTabItem<String?>(value: null, label: 'الكل (7)'),
    FilterTabItem<String?>(value: 'a', label: 'مكتملة (3)'),
    FilterTabItem<String?>(value: 'b', label: 'قيد التنفيذ (4)'),
    FilterTabItem<String?>(value: 'c', label: 'ملغاة (1)'),
  ];

  // RTL like the real app — the row's start (rightmost) tab and its default
  // scroll position depend on it.
  Widget buildTestable({
    String? selected,
    required ValueChanged<String?> onSelected,
  }) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: FilterTabsRow<String?>(tabs: tabs, selected: selected, onSelected: onSelected),
          ),
        ),
      ),
    );
  }

  testWidgets('shows every tab label', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestable(onSelected: (_) {}));

    for (final tab in tabs) {
      expect(find.text(tab.label), findsOneWidget);
    }
  });

  testWidgets('the first tab starts at the right edge and the row bleeds to both screen edges', (
    tester,
  ) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestable(onSelected: (_) {}));

    final first = tester.getRect(find.text('الكل (7)'));
    final second = tester.getRect(find.text('مكتملة (3)'));
    expect(first.center.dx, greaterThan(second.center.dx));
    // 24 of padding (+16 inside the tab) from the right edge of the screen.
    expect(375 - first.right, closeTo(24 + 16, 1));
    // Full-bleed: the scroll view itself spans the whole screen width.
    expect(tester.getSize(find.byType(FilterTabsRow<String?>)).width, 375);
  });

  testWidgets('tapping a tab reports its value', (tester) async {
    await setPhoneViewport(tester);
    String? tapped = 'sentinel';

    await tester.pumpWidget(buildTestable(onSelected: (value) => tapped = value));
    await tester.ensureVisible(find.text('قيد التنفيذ (4)'));
    await tester.tap(find.text('قيد التنفيذ (4)'));

    expect(tapped, 'b');
  });

  testWidgets('tapping the "all" tab reports its null value', (tester) async {
    await setPhoneViewport(tester);
    String? tapped = 'sentinel';

    await tester.pumpWidget(buildTestable(selected: 'a', onSelected: (value) => tapped = value));
    await tester.tap(find.text('الكل (7)'));

    expect(tapped, isNull);
  });
}
