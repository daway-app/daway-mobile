import 'account_type.dart';

class UserSession {
  final AccountType accountType;
  final String token;

  const UserSession({required this.accountType, required this.token});
}
