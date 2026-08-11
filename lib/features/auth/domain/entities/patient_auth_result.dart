class PatientAuthResult {
  final String? token;
  final bool isNewAccount;

  const PatientAuthResult({this.token, required this.isNewAccount});
}
