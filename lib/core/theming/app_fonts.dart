import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tajawal at a real weight.
///
/// The theme's default font family names only Tajawal's regular file, so a
/// `TextStyle` that just sets `fontWeight` gets the regular glyphs artificially
/// thickened ("faux bold") — every weight from w600 up looks the same, and it
/// reads lighter than the Bold and ExtraBold of the design. [tajawal] asks
/// google_fonts for the actual weight file instead.
abstract class AppFonts {
  /// Turned off by the tests (see `test/flutter_test_config.dart`): they draw
  /// in the test font anyway, and google_fonts downloads over the network and
  /// throws when it cannot.
  static bool useGoogleFonts = true;

  /// The weights the app asks [tajawal] for — keep in step with its callers,
  /// so [preload] warms exactly those.
  static const _preloadedWeights = [FontWeight.w800];

  /// [base] with Tajawal at [weight].
  static TextStyle tajawal(TextStyle base, FontWeight weight) {
    if (!useGoogleFonts) return base.copyWith(fontWeight: weight);
    return GoogleFonts.tajawal(textStyle: base, fontWeight: weight);
  }

  /// Starts downloading the weights above at launch, so the first screen that
  /// needs one does not draw in a fallback font while it loads (google_fonts
  /// keeps them on the device afterwards).
  static void preload() {
    if (!useGoogleFonts) return;
    for (final weight in _preloadedWeights) {
      GoogleFonts.tajawal(fontWeight: weight);
    }
  }
}
