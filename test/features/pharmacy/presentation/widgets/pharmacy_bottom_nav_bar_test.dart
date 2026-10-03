import 'package:daway_app/core/theming/app_colors.dart';
import 'package:daway_app/features/pharmacy/presentation/widgets/pharmacy_bottom_nav_bar.dart';
import 'package:daway_app/features/pharmacy/presentation/widgets/pharmacy_dashboard_tab_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';

void main() {
  Widget buildTestable({
    required PharmacyDashboardTab selected,
    ValueChanged<PharmacyDashboardTab>? onTabSelected,
  }) {
    return buildArabicTestApp(
      home: Scaffold(
        bottomNavigationBar: PharmacyBottomNavBar(
          selectedTab: selected,
          onTabSelected: onTabSelected ?? (_) {},
        ),
      ),
    );
  }

  Color labelColor(WidgetTester tester, String label) {
    return tester.widget<Text>(find.text(label)).style!.color!;
  }

  testWidgets('has the five tabs, home rightmost', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestable(selected: PharmacyDashboardTab.home));

    const labels = ['الرئيسية', 'المنتجات', 'الطلبات', 'المراسلات', 'الإعدادات'];
    for (final label in labels) {
      expect(find.text(label), findsOneWidget);
    }
    // RTL: each tab further along the list sits further to the left.
    final xs = [for (final label in labels) tester.getCenter(find.text(label)).dx];
    expect(xs, orderedEquals([...xs]..sort((a, b) => b.compareTo(a))));
  });

  testWidgets('tapping a tab reports it', (tester) async {
    await setDesignViewport(tester);
    final tapped = <PharmacyDashboardTab>[];
    await tester.pumpWidget(
      buildTestable(selected: PharmacyDashboardTab.home, onTabSelected: tapped.add),
    );

    await tester.tap(find.text('المنتجات'));
    await tester.tap(find.text('الطلبات'));
    await tester.tap(find.text('المراسلات'));
    await tester.tap(find.text('الإعدادات'));
    await tester.tap(find.text('الرئيسية'));

    expect(tapped, [
      PharmacyDashboardTab.medicines,
      PharmacyDashboardTab.orders,
      PharmacyDashboardTab.inquiries,
      PharmacyDashboardTab.settings,
      PharmacyDashboardTab.home,
    ]);
  });

  testWidgets('marks only the selected tab, in navy', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestable(selected: PharmacyDashboardTab.inquiries));

    expect(labelColor(tester, 'المراسلات'), AppColors.onboardingText);
    for (final other in ['الرئيسية', 'المنتجات', 'الطلبات', 'الإعدادات']) {
      expect(labelColor(tester, other), AppColors.authInputBorder);
    }
  });

  testWidgets('every label is Regular — selected or not, only the colour differs', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestable(selected: PharmacyDashboardTab.home));

    for (final label in ['الرئيسية', 'المنتجات', 'الطلبات', 'المراسلات', 'الإعدادات']) {
      expect(tester.widget<Text>(find.text(label)).style!.fontWeight, FontWeight.w400, reason: label);
    }
  });

  testWidgets('each item is one button for a screen reader, and the selected one says so', (
    tester,
  ) async {
    await setDesignViewport(tester);
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(buildTestable(selected: PharmacyDashboardTab.inquiries));

    expect(
      tester.getSemantics(find.bySemanticsLabel('المراسلات')),
      isSemantics(label: 'المراسلات', isButton: true, isSelected: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('الرئيسية')),
      isSemantics(label: 'الرئيسية', isButton: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('الرئيسية')),
      isNot(isSemantics(isSelected: true)),
    );

    // Must be disposed before the test ends, not in a tear-down.
    semantics.dispose();
  });

  testWidgets('inventory has no tab of its own, so it marks المنتجات', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestable(selected: PharmacyDashboardTab.inventory));

    expect(labelColor(tester, 'المنتجات'), AppColors.onboardingText);
    expect(labelColor(tester, 'الرئيسية'), AppColors.authInputBorder);
  });

  testWidgets('the products page has no tab of its own, so it marks الرئيسية', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestable(selected: PharmacyDashboardTab.products));

    expect(labelColor(tester, 'الرئيسية'), AppColors.onboardingText);
    for (final other in ['المنتجات', 'الطلبات', 'المراسلات', 'الإعدادات']) {
      expect(labelColor(tester, other), AppColors.authInputBorder);
    }
  });
}
