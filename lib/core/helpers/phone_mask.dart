/// A local phone number with all but its last two digits hidden, as a page
/// shows the number a code was sent to without showing it whole:
/// "0591234529" becomes "+970 XXX XXX X29".
///
/// Takes a number that passed `Validators.isValidLocalPhone`; the country code
/// is the Palestinian +970 the app's numbers use.
String maskLocalPhone(String phone) {
  final lastTwo = phone.length >= 2 ? phone.substring(phone.length - 2) : phone;
  return '+970 XXX XXX X$lastTwo';
}
