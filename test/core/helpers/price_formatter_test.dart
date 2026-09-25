import 'package:daway_app/core/helpers/price_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a whole amount has no decimals', () {
    expect(formatPrice(60), '60');
    expect(formatPrice(60.0), '60');
    expect(formatPrice(0), '0');
  });

  test('a fractional amount keeps its two decimals instead of being rounded away', () {
    expect(formatPrice(12.5), '12.50');
    expect(formatPrice(19.9), '19.90');
    expect(formatPrice(0.4), '0.40');
    expect(formatPrice(7.25), '7.25');
  });

  test('a price that is a whole amount once rounded to two decimals shows as whole', () {
    expect(formatPrice(99.999), '100');
    expect(formatPrice(12.001), '12');
  });
}
