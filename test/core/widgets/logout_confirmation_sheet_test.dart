import 'package:daway_app/core/widgets/logout_confirmation_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> setDesignViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // The app's own Arabic locale, so the sheet (built in the navigator's
  // overlay, above `home`) is right-to-left like in the real app.
  Widget buildTestable({required VoidCallback onConfirm}) {
    return ScreenUtilInit(
      designSize: const Size(440, 956),
      builder: (context, child) => MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => LogoutConfirmationSheet.show(context, onConfirm: onConfirm),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openSheet(WidgetTester tester, {required VoidCallback onConfirm}) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(buildTestable(onConfirm: onConfirm));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('asks for confirmation with a title, a message and two actions', (tester) async {
    await openSheet(tester, onConfirm: () {});

    expect(find.text('تسجيل الخروج؟'), findsOneWidget);
    expect(find.text('هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟'), findsOneWidget);
    expect(find.text('تسجيل الخروج'), findsOneWidget);
    expect(find.text('إلغاء'), findsOneWidget);
  });

  testWidgets('the title and both button labels are ExtraBold, the real weight', (tester) async {
    await openSheet(tester, onConfirm: () {});

    for (final text in ['تسجيل الخروج؟', 'تسجيل الخروج', 'إلغاء']) {
      expect(
        tester.widget<Text>(find.text(text)).style!.fontWeight,
        FontWeight.w800,
        reason: text,
      );
    }
    // The explanatory line under the title stays regular.
    expect(
      tester
          .widget<Text>(find.text('هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟'))
          .style!
          .fontWeight,
      FontWeight.w400,
    );
  });

  testWidgets('confirming closes the sheet and runs the callback', (tester) async {
    var confirmed = 0;
    await openSheet(tester, onConfirm: () => confirmed++);

    await tester.tap(find.text('تسجيل الخروج'));
    await tester.pumpAndSettle();

    expect(confirmed, 1);
    expect(find.text('تسجيل الخروج؟'), findsNothing);
  });

  testWidgets('cancelling closes the sheet without running the callback', (tester) async {
    var confirmed = 0;
    await openSheet(tester, onConfirm: () => confirmed++);

    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();

    expect(confirmed, 0);
    expect(find.text('تسجيل الخروج؟'), findsNothing);
  });

  testWidgets('lays out like the design: 392-wide buttons, 56 and 58 tall, 8 apart', (tester) async {
    await openSheet(tester, onConfirm: () {});

    final confirm = tester.getRect(find.widgetWithText(ElevatedButton, 'تسجيل الخروج'));
    final cancel = tester.getRect(find.widgetWithText(OutlinedButton, 'إلغاء'));
    expect(confirm.width, 392);
    expect(confirm.height, 56);
    expect(cancel.width, 392);
    expect(cancel.height, 58);
    expect(cancel.top - confirm.bottom, 8);
    // 40 of clear space under the buttons in the design's 48 bottom padding.
    expect(956 - cancel.bottom, 48);
  });

  testWidgets('tapping the barrier dismisses it too', (tester) async {
    var confirmed = 0;
    await openSheet(tester, onConfirm: () => confirmed++);

    await tester.tapAt(const Offset(220, 100));
    await tester.pumpAndSettle();

    expect(confirmed, 0);
    expect(find.text('تسجيل الخروج؟'), findsNothing);
  });
}
