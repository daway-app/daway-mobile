import 'package:daway_app/core/di/dependency_injection.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:daway_app/features/onboarding/domain/usecases/set_onboarding_seen_usecase.dart';
import 'package:daway_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOnboardingRepository implements OnboardingRepository {
  bool onboardingSeen = false;

  @override
  Future<bool> isOnboardingSeen() async => onboardingSeen;

  @override
  Future<void> setOnboardingSeen() async {
    onboardingSeen = true;
  }
}

void main() {
  late _FakeOnboardingRepository repository;

  setUp(() {
    repository = _FakeOnboardingRepository();
    getIt.registerFactory<SetOnboardingSeenUseCase>(
      () => SetOnboardingSeenUseCase(repository),
    );
  });

  tearDown(() => getIt.reset());

  Widget buildTestableScreen() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) => settings.name == Routes.accountTypeScreen
              ? const Text('account-type-screen')
              : const OnboardingScreen(),
        ),
        initialRoute: Routes.onboardingScreen,
      ),
    );
  }

  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('first page shows next + skip, no start button', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    expect(find.text('ابحث أو امسح وصفتك'), findsOneWidget);
    expect(find.text('التالي'), findsOneWidget);
    expect(find.text('تخطي'), findsOneWidget);
    expect(find.text('ابدأ الآن'), findsNothing);
  });

  testWidgets('tapping next advances through all pages', (tester) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(buildTestableScreen());
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

  testWidgets(
    'pressing start on the last page marks onboarding seen and navigates',
    (tester) async {
      await setPhoneViewport(tester);
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('التالي'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('التالي'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('ابدأ الآن'));
      await tester.pumpAndSettle();

      expect(repository.onboardingSeen, isTrue);
      expect(find.text('account-type-screen'), findsOneWidget);
    },
  );

  testWidgets('tapping skip marks onboarding seen and navigates', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('تخطي'));
    await tester.tap(find.text('تخطي'));
    await tester.pumpAndSettle();

    expect(repository.onboardingSeen, isTrue);
    expect(find.text('account-type-screen'), findsOneWidget);
  });
}
