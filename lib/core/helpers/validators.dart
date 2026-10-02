abstract class Validators {
  static final RegExp _localPhoneRegExp = RegExp(r'^05\d{8}$');

  /// The fewest characters an account password may have — the same floor the
  /// pharmacy sign-up asks for.
  static const int minPasswordLength = 8;

  static bool isValidLocalPhone(String phone) =>
      _localPhoneRegExp.hasMatch(phone);

  static bool isValidPassword(String password) =>
      password.length >= minPasswordLength;
}
