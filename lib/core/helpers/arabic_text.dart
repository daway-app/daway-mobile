final RegExp _arabicCharPattern = RegExp(r'[؀-ۿ]');

/// True if [text] contains any Arabic-script character — used to validate
/// trade-name fields the backend requires to be English-only (rejects
/// Arabic with a 422 on both `POST /pharmacy/medicines/by-name` and
/// `PUT /pharmacy/medicines/{id}`).
bool containsArabicChars(String text) => _arabicCharPattern.hasMatch(text);
