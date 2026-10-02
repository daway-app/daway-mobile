import 'package:daway_app/core/helpers/haversine_distance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the same point is zero km away', () {
    final distance = haversineDistanceKm(
      startLatitude: 31.5016,
      startLongitude: 34.4668,
      endLatitude: 31.5016,
      endLongitude: 34.4668,
    );

    expect(distance, closeTo(0, 0.0001));
  });

  test('Gaza to Nablus is about 110km', () {
    final distance = haversineDistanceKm(
      startLatitude: 31.5016,
      startLongitude: 34.4668,
      endLatitude: 32.2238,
      endLongitude: 35.2627,
    );

    expect(distance, closeTo(110, 2));
  });
}
