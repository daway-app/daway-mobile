import 'dart:math';

/// Great-circle distance between two coordinates, in kilometers — used to
/// sort/label pharmacies on the map client-side, because `GET /pharmacies`
/// answers 500 whenever `latitude`/`longitude` are sent (see
/// reference-backend-quirks memory) even though each row already carries
/// its own lat/lng.
double haversineDistanceKm({
  required double startLatitude,
  required double startLongitude,
  required double endLatitude,
  required double endLongitude,
}) {
  const earthRadiusKm = 6371.0;
  final dLat = _degreesToRadians(endLatitude - startLatitude);
  final dLon = _degreesToRadians(endLongitude - startLongitude);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(startLatitude)) *
          cos(_degreesToRadians(endLatitude)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadiusKm * c;
}

double _degreesToRadians(double degrees) => degrees * pi / 180;
