/// A saved delivery address (`/patient/addresses`). Only what checkout needs
/// to read and create is wired up so far — [PatientAddressesScreen]'s own
/// full address-book UI (edit/delete/multiple named addresses) is a
/// separate, not-yet-started task.
class PatientAddress {
  final int id;
  final String label;
  final String recipientName;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const PatientAddress({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });
}
