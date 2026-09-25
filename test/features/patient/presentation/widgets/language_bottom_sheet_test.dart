import 'package:daway_app/features/patient/presentation/widgets/language_bottom_sheet.dart';
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
  Widget buildTestable(void Function(Future<AppLanguage?> result) onOpened, AppLanguage selected) {
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
                onPressed: () => onOpened(LanguageBottomSheet.show(context, selected: selected)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Future<AppLanguage?>> openSheet(
    WidgetTester tester, {
    AppLanguage selected = AppLanguage.arabic,
  }) async {
    await setDesignViewport(tester);
    late Future<AppLanguage?> result;
    await tester.pumpWidget(buildTestable((r) => result = r, selected));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('lists both languages, each with its name and its translation', (tester) async {
    await openSheet(tester);

    expect(find.text('اختر اللغة'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
    expect(find.text('Arabic'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('الإنجليزية'), findsOneWidget);
  });

  testWidgets('the heading and both language names are ExtraBold, the real weight', (tester) async {
    await openSheet(tester);

    for (final text in ['اختر اللغة', 'العربية', 'English']) {
      expect(
        tester.widget<Text>(find.text(text)).style!.fontWeight,
        FontWeight.w800,
        reason: text,
      );
    }
    // The small translation under each name stays regular.
    expect(tester.widget<Text>(find.text('Arabic')).style!.fontWeight, FontWeight.w400);
  });

  testWidgets('tapping a language closes the sheet with it as the result', (tester) async {
    final result = await openSheet(tester);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(await result, AppLanguage.english);
    expect(find.text('اختر اللغة'), findsNothing);
  });

  testWidgets('tapping the language that is already selected returns it too', (tester) async {
    final result = await openSheet(tester);

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();

    expect(await result, AppLanguage.arabic);
  });

  testWidgets('dismissing without choosing returns null', (tester) async {
    final result = await openSheet(tester);

    await tester.tapAt(const Offset(220, 100));
    await tester.pumpAndSettle();

    expect(await result, isNull);
  });

  testWidgets('the selected option is the highlighted 396-wide card, the other is 392 wide', (
    tester,
  ) async {
    await openSheet(tester);

    final selected = tester.getRect(
      find.ancestor(of: find.text('العربية'), matching: find.byType(Container)).first,
    );
    final other = tester.getRect(
      find.ancestor(of: find.text('English'), matching: find.byType(Container)).first,
    );
    expect(selected.width, 396);
    expect(selected.height, 76);
    expect(other.width, 392);
    expect(other.height, 74);
    // The design's 10 between the two cards, and the highlight sticking out
    // 2 past the other card on each side.
    expect(other.top - selected.bottom, 10);
    expect(other.left - selected.left, 2);
    expect(selected.right - other.right, 2);
  });

  testWidgets('lays out right-to-left: names on the right, the radio at the left end', (
    tester,
  ) async {
    await openSheet(tester);

    final card = tester.getRect(
      find.ancestor(of: find.text('العربية'), matching: find.byType(Container)).first,
    );
    final name = tester.getRect(find.text('العربية'));
    final radio = tester.getRect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == const Color(0xFF1C72A6) &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      ),
    );

    // 2 border + 16 padding on each side.
    expect(card.right - name.right, closeTo(18, 1));
    expect(radio.left - card.left, closeTo(18, 1));
    expect(radio.size, const Size(24, 24));
    expect(name.center.dx, greaterThan(radio.center.dx));
  });

  testWidgets('sits 44 below the top of the sheet, sized 278 tall in the design frame', (
    tester,
  ) async {
    await openSheet(tester);

    final title = tester.getRect(find.text('اختر اللغة'));
    final sheetTop = 956 - 278.0;
    // The 28-tall heading box starts 44 below the top edge.
    expect(title.top, closeTo(sheetTop + 44, 0.5));
    expect(title.height, closeTo(28, 0.5));
    final english = tester.getRect(
      find.ancestor(of: find.text('English'), matching: find.byType(Container)).first,
    );
    expect(english.bottom, closeTo(956 - 40, 0.5));
  });
}
