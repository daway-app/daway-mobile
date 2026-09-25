import 'package:daway_app/core/theming/app_colors.dart';
import 'package:daway_app/features/onboarding/domain/entities/onboarding_page.dart';
import 'package:daway_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const _testPages = [
  OnboardingPage(title: 'ابحث أو امسح وصفتك', subtitle: 'اعثر على أدويتك بطريقة أسهل.'),
  OnboardingPage(title: 'قارن الصيدليات', subtitle: 'قارن الأسعار والتقييم والمسافة.'),
  OnboardingPage(title: 'اطلب من أكثر من صيدلية', subtitle: 'اجمع منتجاتك في طلب واحد.'),
];

void main() {
  Widget buildTestableScreen(VoidCallback onFinished) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        home: OnboardingScreen(pages: _testPages, onFinished: onFinished),
      ),
    );
  }

  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('first page shows next + skip, no start button, and renders a placeholder', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(buildTestableScreen(() {}));
    await tester.pumpAndSettle();

    expect(find.text('ابحث أو امسح وصفتك'), findsOneWidget);
    expect(find.text('التالي'), findsOneWidget);
    expect(find.text('تخطي'), findsOneWidget);
    expect(find.text('ابدأ الآن'), findsNothing);
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });

  testWidgets('the action button is the main button colour, on "التالي" and on "ابدأ الآن"', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(buildTestableScreen(() {}));
    await tester.pumpAndSettle();

    Color? fillOf(String label) => tester
        .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, label))
        .style
        ?.backgroundColor
        ?.resolve(<WidgetState>{});

    expect(fillOf('التالي'), AppColors.mainTeal);

    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();

    expect(fillOf('ابدأ الآن'), AppColors.mainTeal);
  });

  testWidgets('tapping next advances through all pages', (tester) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(buildTestableScreen(() {}));
    await tester.pumpAndSettle();

    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    expect(find.text('قارن الصيدليات'), findsOneWidget);
    expect(find.text('تخطي'), findsOneWidget);

    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    expect(find.text('اطلب من أكثر من صيدلية'), findsOneWidget);
    expect(find.text('ابدأ الآن'), findsOneWidget);
    expect(find.text('تخطي'), findsNothing);
  });

  testWidgets('pressing start on the last page calls onFinished', (tester) async {
    var finished = false;
    await setPhoneViewport(tester);
    await tester.pumpWidget(buildTestableScreen(() => finished = true));
    await tester.pumpAndSettle();

    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ابدأ الآن'));
    await tester.pumpAndSettle();

    expect(finished, isTrue);
  });

  testWidgets('tapping skip calls onFinished immediately', (tester) async {
    var finished = false;
    await setPhoneViewport(tester);
    await tester.pumpWidget(buildTestableScreen(() => finished = true));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('تخطي'));
    await tester.tap(find.text('تخطي'));
    await tester.pumpAndSettle();

    expect(finished, isTrue);
  });

  testWidgets('the skip link has a 44-tall tap target, not just the text line', (tester) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(buildTestableScreen(() {}));
    await tester.pumpAndSettle();

    final target = tester.getRect(
      find.ancestor(of: find.text('تخطي'), matching: find.byType(GestureDetector)).first,
    );
    expect(target.height, greaterThanOrEqualTo(44));

    // A tap just above the text (inside the padding) still skips.
    var finished = false;
    await tester.pumpWidget(buildTestableScreen(() => finished = true));
    await tester.pumpAndSettle();
    final text = tester.getRect(find.text('تخطي'));
    await tester.tapAt(Offset(text.center.dx, text.top - 10));
    await tester.pumpAndSettle();
    expect(finished, isTrue);
  });

  testWidgets('keeps 24 of visible space between the button and "تخطي", and under it', (tester) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(buildTestableScreen(() {}));
    await tester.pumpAndSettle();

    final button = tester.getRect(find.widgetWithText(ElevatedButton, 'التالي'));
    final skip = tester.getRect(find.text('تخطي'));
    final page = tester.getRect(find.byType(PageView));

    expect(skip.top - button.bottom, closeTo(24, 0.5));
    expect(page.bottom - skip.bottom, closeTo(24, 0.5));
  });
}
