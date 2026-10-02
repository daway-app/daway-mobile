import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// The frame the app is designed in (see `app.dart`) — a phone-sized test
/// viewport makes one logical pixel one design pixel.
const testDesignSize = Size(440, 956);

/// This app's design frame (440x956) as the test viewport, so a screenshot
/// pixel and a `.w`/`.h` logical pixel line up 1:1.
Future<void> setDesignViewport(WidgetTester tester) async {
  tester.view.physicalSize = testDesignSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Wraps the screen the way `DawayApp` does (see lib/app.dart): Arabic locale +
/// the actual localization delegates, inside `ScreenUtilInit` at the design
/// size. 
///
/// A bare `MaterialApp(locale: Locale('ar'))` without the delegates still lays
/// out left-to-right — `Row` child order ("first child = rightmost", the
/// convention this codebase's RTL rows rely on) only flips under real RTL
/// `Directionality`, which only these delegates establish.
Widget buildArabicTestApp({
  required Widget home,
  RouteFactory? onGenerateRoute,
}) {
  return ScreenUtilInit(
    designSize: testDesignSize,
    builder: (context, _) => MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      onGenerateRoute: onGenerateRoute,
      home: home,
    ),
  );
}
