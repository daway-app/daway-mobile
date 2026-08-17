import '../../domain/entities/patient_profile.dart';

class PatientProfileModel {
  final String name;
  final String phone;
  final String? avatarUrl;
  final String? birthDate;
  final double? latitude;
  final double? longitude;
  final String? address;

  const PatientProfileModel({
    required this.name,
    required this.phone,
    this.avatarUrl,
    this.birthDate,
    this.latitude,
    this.longitude,
    this.address,
  });

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return PatientProfileModel(
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      avatarUrl: data['avatar_url'] as String?,
      birthDate: data['birth_date'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      address: data['address'] as String?,
    );
  }

  PatientProfile toEntity() => PatientProfile(
        name: name,
        phone: phone,
        avatarUrl: avatarUrl,
        birthDate: birthDate,
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
}
