/// A pharmacy from `GET /pharmacies`, shown as a map marker.
class NearbyPharmacy {
  final int id;
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final bool isOpenNow;

  /// Computed client-side (see `haversineDistanceKm`) — the endpoint's own
  /// `distance_km` can't be used, see this entity's repository doc comment.
  final double? distanceKm;

  const NearbyPharmacy({
    required this.id,
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    required this.isOpenNow,
    this.distanceKm,
  });

  NearbyPharmacy copyWith({double? distanceKm}) => NearbyPharmacy(
        id: id,
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
        phoneNumber: phoneNumber,
        isOpenNow: isOpenNow,
        distanceKm: distanceKm ?? this.distanceKm,
      );
}
