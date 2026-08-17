import 'working_hours_entry.dart';

class PharmacyProfile {
  final String pharmacyId;
  final String name;
  final String phone;
  final String? logoUrl;
  final double? latitude;
  final double? longitude;
  final String? address;
  final List<WorkingHoursEntry> workingHours;

  const PharmacyProfile({
    required this.pharmacyId,
    required this.name,
    required this.phone,
    this.logoUrl,
    this.latitude,
    this.longitude,
    this.address,
    this.workingHours = const [],
  });
}
