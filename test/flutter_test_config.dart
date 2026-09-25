import 'dart:async';

import 'package:daway_app/core/theming/app_fonts.dart';

/// Runs around every test file (flutter_test picks this file up by name).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Tests draw in the test font, so no Google font is wanted (or reachable).
  AppFonts.useGoogleFonts = false;
  await testMain();
}
