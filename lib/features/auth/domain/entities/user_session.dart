import 'account_type.dart';

class UserSession {
  final AccountType accountType;
  final String token;

  /// The backend user id (`data.user.id` of the login response); null for a
  /// session saved before it was stored.
  final int? userId;

  const UserSession({required this.accountType, required this.token, this.userId});
}
