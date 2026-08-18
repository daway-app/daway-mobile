import 'package:flutter/services.dart';

/// Converts Arabic-Indic digits (٠-٩) to their Western equivalents (0-9) and
/// strips anything else that isn't a digit.
///
/// Needed because the app's Arabic locale makes some Android keyboards default
/// numeric input to Arabic-Indic digits, which then fail \d-based validation
/// (Validators.isValidLocalPhone, etc.) since Dart's RegExp \d only matches
/// ASCII digits.
class DigitsOnlyFormatter extends TextInputFormatter {
  static const _arabicIndicDigits = '٠١٢٣٤٥٦٧٨٩';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.split('').map((char) {
      final arabicIndex = _arabicIndicDigits.indexOf(char);
      return arabicIndex != -1 ? arabicIndex.toString() : char;
    }).where((char) => RegExp(r'[0-9]').hasMatch(char)).join();

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
