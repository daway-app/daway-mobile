class PatientAuthResult {
  final String? token;
  final bool isNewAccount;
  final int? userId;

  const PatientAuthResult({this.token, required this.isNewAccount, this.userId});
}
