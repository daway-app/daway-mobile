import 'package:daway_app/core/theming/app_colors.dart';
import 'package:daway_app/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // AppTextField uses ScreenUtil's .sp/.w/.r extensions internally, which
  // throw unless ScreenUtilInit has run first.
  Widget wrap(Widget child) => ScreenUtilInit(
        designSize: const Size(440, 956),
        builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
      );

  testWidgets('defaults to a single line when maxLines is not given', (tester) async {
    await tester.pumpWidget(wrap(AppTextField(controller: TextEditingController())));

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.maxLines, 1);
  });

  testWidgets('maxLines makes a multi-line field', (tester) async {
    await tester.pumpWidget(
      wrap(AppTextField(controller: TextEditingController(), maxLines: 4)),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.maxLines, 4);
  });

  testWidgets('obscureText stays single-line even if maxLines is given', (tester) async {
    await tester.pumpWidget(
      wrap(AppTextField(controller: TextEditingController(), obscureText: true, maxLines: 4)),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.maxLines, 1);
  });

  testWidgets('defaults to the standard light-grey fill', (tester) async {
    await tester.pumpWidget(wrap(AppTextField(controller: TextEditingController())));

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.fillColor, AppColors.inputFill);
  });

  testWidgets('fillColor overrides the default fill', (tester) async {
    await tester.pumpWidget(
      wrap(AppTextField(controller: TextEditingController(), fillColor: Colors.white)),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.fillColor, Colors.white);
  });
}
