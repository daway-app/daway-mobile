import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// The frame the app is designed in (see `app.dart`) — a phone-sized test
/// viewport makes one logical pixel one design pixel.
const testDesignSize = Size(440, 956);

Future<void> setDesignViewport(WidgetTester tester) async {
  tester.view.physicalSize = testDesignSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Wraps [home] the way the real app does: its design size and an Arabic
/// [MaterialApp] — with the localization delegates, which are what make it
/// right-to-left (a bare `locale: Locale('ar')` alone still lays out LTR, and
/// so would build modal sheets in the overlay LTR).
Widget buildArabicTestApp({required Widget home, RouteFactory? onGenerateRoute}) {
  return ScreenUtilInit(
    designSize: testDesignSize,
    builder: (context, child) => MaterialApp(
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
