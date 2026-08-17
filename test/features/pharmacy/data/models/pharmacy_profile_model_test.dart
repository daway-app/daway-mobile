import 'package:daway_app/features/pharmacy/data/models/pharmacy_profile_model.dart';
import 'package:daway_app/features/pharmacy/domain/entities/working_hours_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson parses a real GET /profile/pharmacy response', () {
    final model = PharmacyProfileModel.fromJson({
      'success': true,
      'data': {
        'type': 'pharmacy',
        'pharmacy_id': 'PH-1234',
        'name': 'صيدلية الأمل',
        'phone': '+970591234567',
        'logo_url': null,
        'latitude': 31.5016,
        'longitude': 34.4668,
        'address': 'غزة، شارع الوحدة',
        'working_hours': {
          'sat': {'open': '09:00', 'close': '22:00'},
          'sun': {'open': '09:00', 'close': '22:00'},
          'mon': null,
          'tue': null,
          'wed': null,
          'thu': null,
          'fri': null,
        },
      },
    });

    expect(model.pharmacyId, 'PH-1234');
    expect(model.name, 'صيدلية الأمل');
    expect(model.phone, '+970591234567');
    expect(model.logoUrl, isNull);
    expect(model.latitude, 31.5016);
    expect(model.longitude, 34.4668);
    expect(model.workingHours.length, 7);
    expect(model.workingHours[0].day, WeekDay.sat);
    expect(model.workingHours[0].open, '09:00');
    expect(model.workingHours[0].close, '22:00');
    expect(model.workingHours[0].isOpen, isTrue);
    final monday = model.workingHours.firstWhere((e) => e.day == WeekDay.mon);
    expect(monday.isOpen, isFalse);
  });

  test('fromJson handles a brand-new pharmacy with everything unset', () {
    final model = PharmacyProfileModel.fromJson({
      'success': true,
      'data': {
        'type': 'pharmacy',
        'pharmacy_id': 'PH-9999',
        'name': 'New Pharmacy',
        'phone': '+970591234567',
        'logo_url': null,
        'latitude': null,
        'longitude': null,
        'address': null,
      },
    });

    expect(model.latitude, isNull);
    expect(model.longitude, isNull);
    expect(model.workingHours, hasLength(7));
    expect(model.workingHours.every((e) => !e.isOpen), isTrue);
  });
}
