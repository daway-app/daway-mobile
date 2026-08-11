abstract class Validators {
  static final RegExp _localPhoneRegExp = RegExp(r'^05\d{8}$');

  static bool isValidLocalPhone(String phone) =>
      _localPhoneRegExp.hasMatch(phone);
}
