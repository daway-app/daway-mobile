import 'package:daway_app/core/widgets/app_custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/arabic_test_app.dart';

void main() {
  Future<void> pumpButton(WidgetTester tester, Widget button) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: Scaffold(body: Padding(padding: const EdgeInsets.all(24), child: button)),
      ),
    );
  }

  TextStyle labelStyle(WidgetTester tester, String label) =>
      tester.widget<Text>(find.text(label)).style!;

  testWidgets('is 56 tall and takes the width it is given', (tester) async {
    await pumpButton(tester, AppCustomButton(text: 'التالي', onPressed: () {}));

    expect(tester.getSize(find.byType(AppCustomButton)), const Size(392, 56));
  });

  testWidgets('its label is bold and white unless told otherwise', (tester) async {
    await pumpButton(tester, AppCustomButton(text: 'التالي', onPressed: () {}));

    final style = labelStyle(tester, 'التالي');
    expect(style.fontWeight, FontWeight.bold);
    expect(style.color, Colors.white);
    expect(style.fontSize, 16);
  });

  testWidgets('takes the whole style of its label when given one, keeping the colour white', (
    tester,
  ) async {
    await pumpButton(
      tester,
      AppCustomButton(
        text: 'التالي',
        onPressed: () {},
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0.4),
      ),
    );

    final style = labelStyle(tester, 'التالي');
    expect(style.fontSize, 18);
    expect(style.fontWeight, FontWeight.w700);
    expect(style.letterSpacing, 0.4);
    expect(style.color, Colors.white);
  });

  testWidgets('a given style takes the button text colour', (tester) async {
    await pumpButton(
      tester,
      AppCustomButton(
        text: 'التالي',
        onPressed: () {},
        textColor: Colors.black,
        textStyle: const TextStyle(fontSize: 16),
      ),
    );

    expect(labelStyle(tester, 'التالي').color, Colors.black);
  });

  testWidgets('pressing it calls back', (tester) async {
    var presses = 0;
    await pumpButton(tester, AppCustomButton(text: 'التالي', onPressed: () => presses++));

    await tester.tap(find.byType(AppCustomButton));

    expect(presses, 1);
  });

  testWidgets('while loading it shows a spinner instead of the label, and cannot be pressed', (
    tester,
  ) async {
    var presses = 0;
    await pumpButton(
      tester,
      AppCustomButton(text: 'التالي', onPressed: () => presses++, isLoading: true),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('التالي'), findsNothing);
    await tester.tap(find.byType(AppCustomButton), warnIfMissed: false);
    expect(presses, 0);
  });
}
