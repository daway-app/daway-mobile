import 'package:flutter/widgets.dart';

import '../models/picked_location.dart';
import '../routing/routes.dart';

/// Opens the map picker (with its search bar and "use my location" button),
/// starting at the given place when there is one, and returns what was
/// confirmed — or null if the user backed out.
Future<PickedLocation?> openLocationPicker(
  BuildContext context, {
  double? latitude,
  double? longitude,
  String? address,
}) {
  return Navigator.of(context).pushNamed<PickedLocation>(
    Routes.locationPickerScreen,
    arguments: {
      'latitude': ?latitude,
      'longitude': ?longitude,
      'address': ?address,
    },
  );
}
