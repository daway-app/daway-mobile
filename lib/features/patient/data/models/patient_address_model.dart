import '../../domain/entities/patient_address.dart';

class PatientAddressModel {
  final int id;
  final String label;
  final String recipientName;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const PatientAddressModel({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  factory PatientAddressModel.fromJson(Map<String, dynamic> json) {
    return PatientAddressModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: json['label'] as String? ?? '',
      recipientName: json['recipient_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  PatientAddress toEntity() => PatientAddress(
        id: id,
        label: label,
        recipientName: recipientName,
        phone: phone,
        address: address,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );
}
