/// A location picked on the map — shared by any feature that lets the user
/// choose a place (patient/pharmacy profile editing, etc.), not owned by
/// any single feature.
class PickedLocation {
  final double latitude;
  final double longitude;
  final String address;

  const PickedLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}
