import 'package:daway_app/features/patient/presentation/helpers/pharmacy_availability_label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('one pharmacy reads as "صيدلية واحدة", not the ungrammatical "1 صيدليات"', () {
    expect(pharmaciesAvailabilityLabel(1), 'متوفر في صيدلية واحدة');
  });

  test('two pharmacies use the dual', () {
    expect(pharmaciesAvailabilityLabel(2), 'متوفر في صيدليتين');
  });

  test('3 to 10 use the plural with the number', () {
    expect(pharmaciesAvailabilityLabel(3), 'متوفر في 3 صيدليات');
    expect(pharmaciesAvailabilityLabel(10), 'متوفر في 10 صيدليات');
  });

  test('11 and more use the singular with the number', () {
    expect(pharmaciesAvailabilityLabel(11), 'متوفر في 11 صيدلية');
    expect(pharmaciesAvailabilityLabel(120), 'متوفر في 120 صيدلية');
  });
}
