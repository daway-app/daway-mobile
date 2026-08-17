class PatientProfile {
  final String name;
  final String phone;
  final String? avatarUrl;
  final String? birthDate;
  final double latitude;
  final double longitude;
  final String address;

  const PatientProfile({
    required this.name,
    required this.phone,
    this.avatarUrl,
    this.birthDate,
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}
