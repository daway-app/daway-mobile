import 'package:daway_app/core/widgets/header_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/arabic_test_app.dart';

void main() {
  const asset = 'assets/icons/notification_icon.svg';

  Widget buildTestable(HeaderIconButton button) {
    return buildArabicTestApp(home: Scaffold(body: Center(child: button)));
  }

  testWidgets('is a 42px square', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestable(HeaderIconButton(assetName: asset, onTap: () {})));

    expect(tester.getSize(find.byType(HeaderIconButton)), const Size(42, 42));
  });

  testWidgets('draws its icon at 22px unless told otherwise', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestable(HeaderIconButton(assetName: asset, onTap: () {})));

    expect(tester.getSize(find.byType(SvgPicture)), const Size(22, 22));
  });

  testWidgets('draws a bigger icon centered in the same square', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(
      buildTestable(HeaderIconButton(assetName: asset, iconSize: 30, onTap: () {})),
    );

    expect(tester.getSize(find.byType(SvgPicture)), const Size(30, 30));
    expect(tester.getCenter(find.byType(SvgPicture)), tester.getCenter(find.byType(HeaderIconButton)));
    expect(tester.getSize(find.byType(HeaderIconButton)), const Size(42, 42));
  });

  testWidgets('is filled white, and draws the icon in its own colours, unless told otherwise', (
    tester,
  ) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestable(HeaderIconButton(assetName: asset, onTap: () {})));

    final decoration = tester.widget<Container>(find.byType(Container).first).decoration! as BoxDecoration;
    expect(decoration.color, Colors.white);
    expect(tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter, isNull);
  });

  testWidgets('takes another fill, and one colour for the whole icon', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(
      buildTestable(
        HeaderIconButton(
          assetName: asset,
          backgroundColor: Colors.amber,
          iconColor: Colors.purple,
          onTap: () {},
        ),
      ),
    );

    final decoration = tester.widget<Container>(find.byType(Container).first).decoration! as BoxDecoration;
    expect(decoration.color, Colors.amber);
    expect(
      tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter,
      const ColorFilter.mode(Colors.purple, BlendMode.srcIn),
    );
  });

  testWidgets('has no name for a screen reader unless given one', (tester) async {
    await setDesignViewport(tester);
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(buildTestable(HeaderIconButton(assetName: asset, onTap: () {})));

    expect(find.bySemanticsLabel('رجوع'), findsNothing);
    semantics.dispose();
  });

  testWidgets('is a named button for a screen reader when given a label', (tester) async {
    await setDesignViewport(tester);
    final semantics = tester.ensureSemantics();
    var taps = 0;

    await tester.pumpWidget(
      buildTestable(HeaderIconButton(assetName: asset, semanticLabel: 'رجوع', onTap: () => taps++)),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('رجوع')),
      isSemantics(label: 'رجوع', isButton: true, hasTapAction: true),
    );
    await tester.tap(find.bySemanticsLabel('رجوع'));
    expect(taps, 1);
    semantics.dispose();
  });

  testWidgets('tapping it calls back', (tester) async {
    await setDesignViewport(tester);
    var taps = 0;
    await tester.pumpWidget(buildTestable(HeaderIconButton(assetName: asset, onTap: () => taps++)));

    await tester.tap(find.byType(HeaderIconButton));

    expect(taps, 1);
  });
}
