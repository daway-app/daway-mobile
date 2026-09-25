import 'package:daway_app/core/theming/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // flutter_test_config.dart turns google_fonts off for every test, so these
  // check the style plumbing without any network.
  test('the test config has google_fonts switched off', () {
    expect(AppFonts.useGoogleFonts, isFalse);
  });

  test('tajawal keeps the base style and applies the requested weight', () {
    const base = TextStyle(fontSize: 18, height: 1.5, color: Colors.red);

    final style = AppFonts.tajawal(base, FontWeight.w800);

    expect(style.fontWeight, FontWeight.w800);
    expect(style.fontSize, 18);
    expect(style.height, 1.5);
    expect(style.color, Colors.red);
  });

  test('preload does nothing (and does not throw) while google_fonts is off', () {
    expect(AppFonts.preload, returnsNormally);
  });
}
