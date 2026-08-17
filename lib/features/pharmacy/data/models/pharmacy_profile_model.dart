import '../../domain/entities/pharmacy_profile.dart';
import '../../domain/entities/working_hours_entry.dart';

class PharmacyProfileModel {
  final String pharmacyId;
  final String name;
  final String phone;
  final String? logoUrl;
  final double? latitude;
  final double? longitude;
  final String? address;
  final List<WorkingHoursEntry> workingHours;

  const PharmacyProfileModel({
    required this.pharmacyId,
    required this.name,
    required this.phone,
    this.logoUrl,
    this.latitude,
    this.longitude,
    this.address,
    this.workingHours = const [],
  });

  factory PharmacyProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final workingHoursJson = data['working_hours'] as Map<String, dynamic>? ?? const {};

    return PharmacyProfileModel(
      pharmacyId: data['pharmacy_id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      logoUrl: data['logo_url'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      address: data['address'] as String?,
      workingHours: WeekDay.values.map((day) {
        final dayJson = workingHoursJson[day.name] as Map<String, dynamic>?;
        return WorkingHoursEntry(
          day: day,
          open: dayJson?['open'] as String?,
          close: dayJson?['close'] as String?,
        );
      }).toList(),
    );
  }

  PharmacyProfile toEntity() => PharmacyProfile(
        pharmacyId: pharmacyId,
        name: name,
        phone: phone,
        logoUrl: logoUrl,
        latitude: latitude,
        longitude: longitude,
        address: address,
        workingHours: workingHours,
      );
}
