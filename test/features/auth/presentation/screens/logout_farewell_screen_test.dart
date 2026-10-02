import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/features/auth/presentation/screens/logout_farewell_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget buildTestableScreen({List<String>? visitedRoutes}) {
    return ScreenUtilInit(
      designSize: const Size(440, 956),
      builder: (context, child) => MaterialApp(
        onGenerateRoute: (settings) {
          visitedRoutes?.add(settings.name ?? '');
          return MaterialPageRoute(builder: (_) => const Scaffold(body: SizedBox.shrink()));
        },
        home: const LogoutFarewellScreen(),
      ),
    );
  }

  testWidgets('shows the farewell copy', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    expect(find.text('سوف نفتقدك'), findsOneWidget);
    expect(find.text('يمكنك العودة دائمًا متى احتجت إلينا.'), findsOneWidget);
    expect(find.text('العودة للتطبيق'), findsOneWidget);
  });

  testWidgets('tapping "العودة للتطبيق" navigates to account-type', (tester) async {
    await setPhoneViewport(tester);
    final visitedRoutes = <String>[];

    await tester.pumpWidget(buildTestableScreen(visitedRoutes: visitedRoutes));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العودة للتطبيق'));
    await tester.pumpAndSettle();

    expect(visitedRoutes, contains(Routes.accountTypeScreen));
  });
}
