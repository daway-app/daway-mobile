import 'package:daway_app/core/widgets/app_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> setDesignViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // RTL like the real app: a stock Switch would mirror here, this one must not.
  Widget buildTestable(bool value) {
    return ScreenUtilInit(
      designSize: const Size(440, 956),
      builder: (context, child) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: Center(child: AppToggleSwitch(value: value))),
        ),
      ),
    );
  }

  Finder thumbFinder() => find.descendant(
        of: find.byType(AppToggleSwitch),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is DecoratedBox &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).shape == BoxShape.circle,
        ),
      );

  Finder trackFinder() => find.descendant(
        of: find.byType(AppToggleSwitch),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is DecoratedBox &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).borderRadius != null,
        ),
      );

  testWidgets('is a 50x28 track holding a 22 thumb', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestable(true));

    expect(tester.getSize(trackFinder()), const Size(50, 28));
    expect(tester.getSize(thumbFinder()), const Size(22, 22));
  });

  testWidgets('on: the thumb sits at the right end and the track is the app teal', (tester) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestable(true));

    final track = tester.getRect(trackFinder());
    final thumb = tester.getRect(thumbFinder());
    expect(track.right - thumb.right, closeTo(3, 0.5));
    expect(thumb.left - track.left, greaterThan(20));
    final decoration = tester.widget<DecoratedBox>(trackFinder()).decoration as BoxDecoration;
    expect(decoration.color, const Color(0xFF1C72A6));
  });

  testWidgets('off: the thumb sits at the left end, still left-to-right inside an RTL app', (
    tester,
  ) async {
    await setDesignViewport(tester);

    await tester.pumpWidget(buildTestable(false));

    final track = tester.getRect(trackFinder());
    final thumb = tester.getRect(thumbFinder());
    expect(thumb.left - track.left, closeTo(3, 0.5));
    expect(track.right - thumb.right, greaterThan(20));
  });

  testWidgets('animates the thumb across when the value flips', (tester) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(buildTestable(false));
    final before = tester.getRect(thumbFinder()).center.dx;

    await tester.pumpWidget(buildTestable(true));
    await tester.pumpAndSettle();

    expect(tester.getRect(thumbFinder()).center.dx, greaterThan(before + 15));
  });

  testWidgets('exposes its state to accessibility', (tester) async {
    await setDesignViewport(tester);
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(buildTestable(true));

    expect(
      tester.getSemantics(find.byType(AppToggleSwitch)),
      matchesSemantics(hasToggledState: true, isToggled: true),
    );
    handle.dispose();
  });
}
