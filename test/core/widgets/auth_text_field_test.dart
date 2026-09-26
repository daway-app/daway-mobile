import 'package:daway_app/core/theming/app_colors.dart';
import 'package:daway_app/core/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/arabic_test_app.dart';

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  Future<void> pumpField(WidgetTester tester, Widget field) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Align(alignment: Alignment.topCenter, child: field),
          ),
        ),
      ),
    );
  }

  InputDecoration decorationOf(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).decoration!;

  group('AuthTextField', () {
    testWidgets('shows its label above the field, at the right', (tester) async {
      await pumpField(tester, AuthTextField(label: 'رقم الهاتف', controller: controller));

      final label = tester.getRect(find.text('رقم الهاتف'));
      final field = tester.getRect(find.byType(TextField));

      expect(label.bottom, lessThanOrEqualTo(field.top));
      expect(label.right, closeTo(field.right, 0.01));
    });

    testWidgets('the field is 392 wide and 56 tall, drawn to its border', (tester) async {
      await pumpField(tester, AuthTextField(label: 'رقم الهاتف', controller: controller));

      expect(tester.getSize(find.byType(TextField)), const Size(392, 56));
    });

    testWidgets('what is typed reaches the controller and the callback', (tester) async {
      final typed = <String>[];
      await pumpField(
        tester,
        AuthTextField(label: 'رقم الهاتف', controller: controller, onChanged: typed.add),
      );

      await tester.enterText(find.byType(TextField), '0591234529');

      expect(controller.text, '0591234529');
      expect(typed, ['0591234529']);
    });

    testWidgets('has a grey border, blue when focused', (tester) async {
      await pumpField(tester, AuthTextField(label: 'رقم الهاتف', controller: controller));

      final decoration = decorationOf(tester);
      expect((decoration.enabledBorder! as OutlineInputBorder).borderSide.color, AppColors.authInputBorder);
      expect((decoration.focusedBorder! as OutlineInputBorder).borderSide.color, AppColors.primaryTeal);
      expect((decoration.enabledBorder! as OutlineInputBorder).borderRadius, BorderRadius.circular(8));
    });

    testWidgets('is red, focused or not, while it has an error', (tester) async {
      await pumpField(
        tester,
        AuthTextField(label: 'رقم الهاتف', controller: controller, hasError: true),
      );

      final decoration = decorationOf(tester);
      expect((decoration.enabledBorder! as OutlineInputBorder).borderSide.color, AppColors.authError);
      expect((decoration.focusedBorder! as OutlineInputBorder).borderSide.color, AppColors.authError);
    });

    testWidgets('can be a number field that reads left to right', (tester) async {
      await pumpField(
        tester,
        AuthTextField(
          label: 'رقم الهاتف',
          controller: controller,
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.keyboardType, TextInputType.number);
      expect(field.textDirection, TextDirection.ltr);
    });
  });

  group('AuthPasswordField', () {
    testWidgets('hides what is typed until the eye is pressed, and again on the next press', (
      tester,
    ) async {
      await pumpField(tester, AuthPasswordField(label: 'كلمة المرور', controller: controller));
      expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();
      expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isFalse);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isTrue);
    });

    testWidgets('the eye says what it will do, for a screen reader', (tester) async {
      await pumpField(tester, AuthPasswordField(label: 'كلمة المرور', controller: controller));

      expect(find.byTooltip('إظهار كلمة المرور'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(find.byTooltip('إخفاء كلمة المرور'), findsOneWidget);
    });

    testWidgets('keeps what was typed when the eye is pressed', (tester) async {
      await pumpField(tester, AuthPasswordField(label: 'كلمة المرور', controller: controller));
      await tester.enterText(find.byType(TextField), 'new-secret-1');

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(controller.text, 'new-secret-1');
    });

    testWidgets('shows the error border like any auth field', (tester) async {
      await pumpField(
        tester,
        AuthPasswordField(label: 'كلمة المرور', controller: controller, hasError: true),
      );

      final decoration = decorationOf(tester);
      expect((decoration.enabledBorder! as OutlineInputBorder).borderSide.color, AppColors.authError);
    });
  });
}
