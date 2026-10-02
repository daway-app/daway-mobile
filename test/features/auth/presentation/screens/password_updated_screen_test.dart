import 'package:daway_app/core/theming/app_colors.dart';
import 'package:daway_app/features/auth/presentation/screens/password_updated_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(buildArabicTestApp(home: const PasswordUpdatedScreen()));
  }

  Finder card() => find.descendant(
        of: find.byType(PasswordUpdatedScreen),
        matching: find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration is BoxDecoration && (widget.decoration! as BoxDecoration).border != null,
        ),
      );

  testWidgets('says the password was updated', (tester) async {
    await pumpScreen(tester);

    expect(find.text('تم تحديث كلمة مرورك بنجاح'), findsOneWidget);
  });

  testWidgets('shows the check image above the message', (tester) async {
    await pumpScreen(tester);

    final image = tester.getRect(find.byType(Image));
    final message = tester.getRect(find.text('تم تحديث كلمة مرورك بنجاح'));

    expect(tester.widget<Image>(find.byType(Image)).image, isA<AssetImage>());
    expect((tester.widget<Image>(find.byType(Image)).image as AssetImage).assetName, 'assets/images/password_updated.jpg');
    expect(image.bottom, lessThan(message.top));
  });

  testWidgets('the message is 24 under the image, centered', (tester) async {
    await pumpScreen(tester);

    final image = tester.getRect(find.byType(Image));
    final message = tester.getRect(find.text('تم تحديث كلمة مرورك بنجاح'));

    expect(image.size.width, closeTo(142.4, 0.01));
    expect(image.height, closeTo(142.4, 0.01));
    expect(message.top - image.bottom, 24);
    expect(message.center.dx, closeTo(image.center.dx, 0.5));
    expect(tester.widget<Text>(find.text('تم تحديث كلمة مرورك بنجاح')).textAlign, TextAlign.center);
  });

  testWidgets('the message is Bold 16 in black', (tester) async {
    await pumpScreen(tester);

    final style = tester.widget<Text>(find.text('تم تحديث كلمة مرورك بنجاح')).style!;

    expect(style.fontSize, 16);
    expect(style.fontWeight, FontWeight.w700);
    expect(style.color, Colors.black);
    expect(style.height, 1.0);
  });

  testWidgets('the card is 392 by 342 inside a 1px border, in the middle of the whole screen', (
    tester,
  ) async {
    await pumpScreen(tester);

    final rect = tester.getRect(card());

    // 394 by 344 with the border.
    expect(rect.size, const Size(394, 344));
    expect(rect.center.dx, 220);
    expect(rect.center.dy, 478);
  });

  testWidgets('the card has a 16 corner and the light blue border', (tester) async {
    await pumpScreen(tester);

    final decoration = tester.widget<Container>(card()).decoration! as BoxDecoration;

    expect(decoration.borderRadius, BorderRadius.circular(16));
    expect(decoration.border!.top.color, AppColors.iconBlueBorder);
    expect(decoration.border!.top.width, 1);
    expect(decoration.color, Colors.white);
  });

  testWidgets('it has nothing to press', (tester) async {
    await pumpScreen(tester);

    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(IconButton), findsNothing);
  });

  group('after its two seconds', () {
    late GlobalKey<NavigatorState> navigatorKey;

    /// The confirmation over a login that has no name, as the router makes it,
    /// and with a screen under the login, as in the app.
    Future<void> pumpOverLogin(WidgetTester tester) async {
      await setDesignViewport(tester);
      navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        buildArabicTestApp(
          home: Navigator(
            key: navigatorKey,
            onGenerateRoute: (settings) => MaterialPageRoute<void>(
              builder: (_) => const Scaffold(body: Text('الصفحة الأولى')),
            ),
          ),
        ),
      );
      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('الدخول'))),
      );
      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(builder: (_) => const PasswordUpdatedScreen()),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('it stays for the two seconds', (tester) async {
      await pumpOverLogin(tester);

      await tester.pump(PasswordUpdatedScreen.displayTime - const Duration(milliseconds: 1));

      expect(find.byType(PasswordUpdatedScreen), findsOneWidget);
    });

    testWidgets('it takes the pharmacy back to the login', (tester) async {
      await pumpOverLogin(tester);

      await tester.pump(PasswordUpdatedScreen.displayTime);
      await tester.pumpAndSettle();

      expect(find.byType(PasswordUpdatedScreen), findsNothing);
      expect(find.text('الدخول'), findsOneWidget);
      // Only the screen under the login is left under it.
      expect(find.text('الصفحة الأولى', skipOffstage: false), findsOneWidget);
    });

    testWidgets('with nothing under it, it stays rather than leave the app with no screen', (
      tester,
    ) async {
      await setDesignViewport(tester);
      await tester.pumpWidget(buildArabicTestApp(home: const PasswordUpdatedScreen()));

      await tester.pump(PasswordUpdatedScreen.displayTime);
      await tester.pumpAndSettle();

      expect(find.byType(PasswordUpdatedScreen), findsOneWidget);
    });

    testWidgets('going away early leaves no timer to act on a screen that is gone', (tester) async {
      await pumpOverLogin(tester);
      await tester.pumpWidget(const SizedBox.shrink());

      await tester.pump(PasswordUpdatedScreen.displayTime * 2);

      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('the display time is two seconds', (tester) async {
    expect(PasswordUpdatedScreen.displayTime, const Duration(seconds: 2));
  });
}
