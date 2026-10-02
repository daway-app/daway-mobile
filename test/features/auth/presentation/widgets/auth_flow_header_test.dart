import 'package:daway_app/features/auth/presentation/widgets/auth_flow_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';

void main() {
  Future<void> pumpHeader(WidgetTester tester, {AuthFlowHeader? header}) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header ??
                      const AuthFlowHeader(
                        title: 'أدخل رمز التحقق',
                        subtitle: 'أدخل رمز التحقق المرسل إلى رقم هاتفك',
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows the title and the subtitle', (tester) async {
    await pumpHeader(tester);

    expect(find.text('أدخل رمز التحقق'), findsOneWidget);
    expect(find.text('أدخل رمز التحقق المرسل إلى رقم هاتفك'), findsOneWidget);
  });

  testWidgets('has the back chip at the right, above the title', (tester) async {
    await pumpHeader(tester);
    final semantics = tester.ensureSemantics();

    final chip = tester.getRect(find.bySemanticsLabel('رجوع'));
    final title = tester.getRect(find.text('أدخل رمز التحقق'));

    expect(chip.size, const Size(42, 42));
    expect(chip.right, closeTo(416, 0.01));
    expect(chip.bottom, lessThanOrEqualTo(title.top));
    semantics.dispose();
  });

  testWidgets('the title and the subtitle start at the right, under each other', (tester) async {
    await pumpHeader(tester);

    final title = tester.getRect(find.text('أدخل رمز التحقق'));
    final subtitle = tester.getRect(find.text('أدخل رمز التحقق المرسل إلى رقم هاتفك'));

    expect(title.right, closeTo(416, 0.01));
    expect(subtitle.right, closeTo(416, 0.01));
    expect(title.bottom, lessThanOrEqualTo(subtitle.top));
  });

  testWidgets('the gaps around the title can be set', (tester) async {
    await pumpHeader(tester);
    final closeTitle = tester.getRect(find.text('أدخل رمز التحقق')).top;
    final closeSubtitle = tester.getRect(find.text('أدخل رمز التحقق المرسل إلى رقم هاتفك')).top;

    await pumpHeader(
      tester,
      header: const AuthFlowHeader(
        title: 'أدخل رمز التحقق',
        subtitle: 'أدخل رمز التحقق المرسل إلى رقم هاتفك',
        titleTop: 21,
        subtitleGap: 4,
      ),
    );

    expect(tester.getRect(find.text('أدخل رمز التحقق')).top, closeTitle + 8);
    // 8 lower for the title, and its gap to the subtitle 8 smaller.
    expect(tester.getRect(find.text('أدخل رمز التحقق المرسل إلى رقم هاتفك')).top, closeSubtitle);
  });

  testWidgets('the back chip goes back a screen', (tester) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(
                    body: SafeArea(
                      child: AuthFlowHeader(title: 'الثانية', subtitle: 'الشاشة الثانية'),
                    ),
                  ),
                ),
              ),
              child: const Text('الأولى'),
            ),
          ),
        ),
      ),
    );
    final semantics = tester.ensureSemantics();
    await tester.tap(find.text('الأولى'));
    await tester.pumpAndSettle();
    expect(find.text('الثانية'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('رجوع'));
    await tester.pumpAndSettle();

    expect(find.text('الثانية'), findsNothing);
    expect(find.text('الأولى'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('the back chip is heard by the screen\'s own PopScope, like the system back button', (
    tester,
  ) async {
    var pops = 0;
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PopScope(
                    onPopInvokedWithResult: (didPop, result) {
                      if (didPop) pops++;
                    },
                    child: const Scaffold(
                      body: SafeArea(
                        child: AuthFlowHeader(title: 'الثانية', subtitle: 'الشاشة الثانية'),
                      ),
                    ),
                  ),
                ),
              ),
              child: const Text('الأولى'),
            ),
          ),
        ),
      ),
    );
    final semantics = tester.ensureSemantics();
    await tester.tap(find.text('الأولى'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('رجوع'));
    await tester.pumpAndSettle();

    expect(pops, 1);
    semantics.dispose();
  });
}
