import 'package:daway_app/features/pharmacy/domain/entities/pharmacy_dashboard_stats.dart';
import 'package:flutter_test/flutter_test.dart';

PharmacyDashboardStats _statsWith({required int totalMedicines}) {
  return PharmacyDashboardStats(
    totalMedicines: totalMedicines,
    availableCount: 0,
    lowStockCount: 0,
    outOfStockCount: 0,
    newInquiriesCount: 0,
    averageRating: null,
    ratingsCount: 0,
    lowStockItems: const [],
    recentInquiries: const [],
  );
}

void main() {
  test('a pharmacy with no medicines has none', () {
    expect(_statsWith(totalMedicines: 0).hasMedicines, isFalse);
  });

  test('a pharmacy with a single medicine has medicines', () {
    expect(_statsWith(totalMedicines: 1).hasMedicines, isTrue);
  });
}
