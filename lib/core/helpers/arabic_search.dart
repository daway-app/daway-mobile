/// Folds the spellings Arabic users interchange so a search matches either
/// way: hamza forms of alef (أ إ آ) to ا, ى to ي, ة to ه, and drops
/// diacritics and tatweel. Also lower-cases Latin letters.
String normalizeArabic(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    if (rune == 0x0640 || (rune >= 0x064B && rune <= 0x065F) || rune == 0x0670) continue;
    switch (rune) {
      case 0x0623: // أ
      case 0x0625: // إ
      case 0x0622: // آ
        buffer.writeCharCode(0x0627); // ا
      case 0x0649: // ى
        buffer.writeCharCode(0x064A); // ي
      case 0x0629: // ة
        buffer.writeCharCode(0x0647); // ه
      default:
        buffer.writeCharCode(rune);
    }
  }
  return buffer.toString().toLowerCase();
}

/// True when [text] contains [query] ignoring the spelling variants above.
bool arabicContains(String text, String query) =>
    normalizeArabic(text).contains(normalizeArabic(query));
