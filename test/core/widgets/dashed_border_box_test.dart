import 'package:daway_app/core/widgets/dashed_border_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestable(Widget child) {
    return MaterialApp(home: Scaffold(body: Center(child: child)));
  }

  testWidgets('shows its child', (tester) async {
    await tester.pumpWidget(
      buildTestable(
        const DashedBorderBox(color: Colors.blue, child: Text('أضف ملف')),
      ),
    );

    expect(find.text('أضف ملف'), findsOneWidget);
  });

  testWidgets('is exactly as big as its child — the border is drawn inside', (tester) async {
    await tester.pumpWidget(
      buildTestable(
        const DashedBorderBox(
          color: Colors.blue,
          radius: 8,
          child: SizedBox(width: 200, height: 100),
        ),
      ),
    );

    expect(tester.getSize(find.byType(DashedBorderBox)), const Size(200, 100));
  });

  // ScreenUtil scales every `.w` to 0 for a frame when the view has no size
  // yet, which hands the box a 0-long dash and a 0-long gap. Looping over
  // that never advances, so the app froze; it has to draw and return.
  testWidgets('paints (solid) instead of looping forever when the dashes have no length', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestable(
        const DashedBorderBox(
          color: Colors.blue,
          radius: 8,
          dashLength: 0,
          gapLength: 0,
          child: SizedBox(width: 100, height: 50),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(DashedBorderBox)), const Size(100, 50));
  });

  testWidgets('paints without error at a dash length longer than its sides', (tester) async {
    await tester.pumpWidget(
      buildTestable(
        const DashedBorderBox(
          color: Colors.blue,
          backgroundColor: Colors.white,
          radius: 4,
          dashLength: 500,
          child: SizedBox(width: 20, height: 20),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
