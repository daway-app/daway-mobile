enum AccountType {
  patient,
  pharmacy,
}

extension AccountTypeX on AccountType {
  bool get isPatient => this == AccountType.patient;
  bool get isPharmacy => this == AccountType.pharmacy;
}