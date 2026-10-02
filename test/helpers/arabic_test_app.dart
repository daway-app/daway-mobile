import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] the same way `DawayApp` does (see lib/app.dart): Arabic
/// locale + the actual localization delegates, inside `ScreenUtilInit` at
/// this app's 440x956 design size.
///
/// A bare `MaterialApp(locale: Locale('ar'))` without the delegates below
/// still lays out left-to-right — [RenderFlex]/`Row` child order ("first
/// child = rightmost", the convention this codebase's RTL rows rely on,
/// e.g. FavoriteMedicineCard) only flips under real RTL `Directionality`,
/// which only these delegates establish. A test that skips this can pass
/// while the same row renders mirrored in the real (RTL) app — exactly
/// what happened with the reminder screen's frequency chips (2026-09-29).
Widget buildArabicTestApp(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(440, 956),
    builder: (context, _) => MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    ),
  );
}

/// This app's design frame (440x956) as the test viewport, so a screenshot
/// pixel and a `.w`/`.h` logical pixel line up 1:1 — same sizing
/// [buildArabicTestApp]'s `ScreenUtilInit` assumes.
Future<void> setDesignViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(440, 956);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
