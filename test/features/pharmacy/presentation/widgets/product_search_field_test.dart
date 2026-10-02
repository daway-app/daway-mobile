import 'package:daway_app/features/pharmacy/presentation/widgets/product_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';

void main() {
  Future<void> pumpField(
    WidgetTester tester, {
    String initialText = '',
    ValueChanged<String>? onChanged,
  }) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Align(
              alignment: Alignment.topCenter,
              child: ProductSearchField(initialText: initialText, onChanged: onChanged ?? (_) {}),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows the hint when empty', (tester) async {
    await pumpField(tester);

    expect(find.text('ابحث'), findsOneWidget);
  });

  testWidgets('starts with the text it is given, so a rebuilt field keeps the query', (
    tester,
  ) async {
    await pumpField(tester, initialText: 'سيفتر');

    expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, 'سيفتر');
  });

  testWidgets('reports what is typed', (tester) async {
    final typed = <String>[];
    await pumpField(tester, onChanged: typed.add);

    await tester.enterText(find.byType(TextField), 'panadol');

    expect(typed, ['panadol']);
  });

  testWidgets('is 392 wide and 56 tall, with the search icon at the right', (tester) async {
    await pumpField(tester);

    final field = tester.getRect(find.byType(ProductSearchField));
    final icon = tester.getRect(find.byType(SvgPicture));

    expect(field.size, const Size(392, 56));
    expect(icon.size, const Size(24, 24));
    // 16 from the edge of the field, the border being one of them.
    expect(field.right - icon.right, 16);
    expect(icon.center.dy, field.center.dy);
  });

  testWidgets('the text starts to the left of the icon, 10 away', (tester) async {
    await pumpField(tester, initialText: 'x');

    final icon = tester.getRect(find.byType(SvgPicture));
    final text = tester.getRect(find.byType(EditableText));

    expect(icon.left - text.right, 10);
  });
}
