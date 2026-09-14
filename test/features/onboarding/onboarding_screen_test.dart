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
}
