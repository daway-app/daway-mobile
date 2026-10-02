import 'package:daway_app/core/theming/app_colors.dart';
import 'package:daway_app/core/theming/app_text_styles.dart';
import 'package:daway_app/core/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/arabic_test_app.dart';

void main() {
  Widget buildTestable(SectionHeader header) {
    return buildArabicTestApp(home: Scaffold(body: header));
  }

  testWidgets('shows the title and the "عرض الكل" chip', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestable(SectionHeader(title: 'الاقسام', onActionTap: () {})));

    expect(find.text('الاقسام'), findsOneWidget);
    expect(find.text('عرض الكل'), findsOneWidget);
  });

  testWidgets('tapping the chip calls back', (tester) async {
    await setDesignViewport(tester);
    var taps = 0;
    await tester.pumpWidget(buildTestable(SectionHeader(title: 'الطلبات', onActionTap: () => taps++)));

    await tester.tap(find.text('عرض الكل'));

    expect(taps, 1);
  });

  testWidgets('the chip is 32px high even with a 24px chevron', (tester) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildTestable(SectionHeader(title: 'الطلبات', onActionTap: () {}, chevronSize: 24)),
    );

    final chip = find.ancestor(of: find.text('عرض الكل'), matching: find.byType(Container)).first;

    expect(tester.getSize(chip).height, 32);
  });

  testWidgets('keeps the patient home look unless given another', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestable(SectionHeader(title: 'الاقسام', onActionTap: () {})));

    expect(tester.widget<Text>(find.text('الاقسام')).style, AppTextStyles.homeSectionTitle);
    expect(tester.widget<Text>(find.text('عرض الكل')).style, AppTextStyles.homeSectionChip);
    expect(tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter, isNull);
  });

  testWidgets('takes the title style, the label style and the chevron colour it is given', (
    tester,
  ) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(
      buildTestable(
        SectionHeader(
          title: 'الطلبات',
          onActionTap: () {},
          titleStyle: AppTextStyles.pharmacySectionTitle,
          actionStyle: AppTextStyles.pharmacySectionAction,
          chevronColor: AppColors.mainTeal,
        ),
      ),
    );

    expect(tester.widget<Text>(find.text('الطلبات')).style, AppTextStyles.pharmacySectionTitle);
    expect(tester.widget<Text>(find.text('عرض الكل')).style, AppTextStyles.pharmacySectionAction);
    expect(
      tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter,
      const ColorFilter.mode(AppColors.mainTeal, BlendMode.srcIn),
    );
  });
}
