import 'package:flutter/material.dart';

final RegExp _latinLetter = RegExp(r'[A-Za-z]');

/// Catalog trade names imported as all-caps Latin text (e.g. "KAARAL BLONDE
/// ELEVATION...") read as shouting and wrap awkwardly at a normal title
/// size, so callers render them smaller. Arabic names have no letter case,
/// so this only ever fires for Latin script — and only when the *whole*
/// name is uppercase, so a normal mixed-case name like "Panadol" isn't
/// affected.
bool isShoutyLatinName(String text) {
  final letters = text.replaceAll(RegExp(r'[^A-Za-z]'), '');
  return letters.isNotEmpty && letters == letters.toUpperCase();
}

/// Latin text (trade names imported from an English catalog) needs its own
/// ltr run so truncation ellipsizes on its natural trailing edge instead of
/// the leading edge the surrounding rtl layout would put it on.
///
/// This only checks for *any* Latin letter, so a mixed-script string (e.g.
/// an Arabic name with an embedded Latin qualifier) is still forced fully
/// ltr — a known limitation shared by every caller, not fixed here since it
/// needs a real bidi-run-aware approach rather than a single direction flag.
TextDirection textDirectionFor(String text) =>
    _latinLetter.hasMatch(text) ? TextDirection.ltr : TextDirection.rtl;
