import '../../domain/entities/pharmacy_dashboard_stats.dart';

/// Parses `GET /pharmacy/dashboard/stats`. Field names confirmed against a
/// live response — the stats object has no average-rating field, so
/// [PharmacyDashboardRepositoryImpl] derives that separately.
class PharmacyDashboardStatsModel {
  final int totalMedicines;
  final int availableCount;
  final int lowStockCount;
  final int outOfStockCount;
  final int newInquiriesCount;
  final List<PharmacyDashboardLowStockItem> lowStockItems;

  const PharmacyDashboardStatsModel({
    required this.totalMedicines,
    required this.availableCount,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.newInquiriesCount,
    required this.lowStockItems,
  });

  factory PharmacyDashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final lowStockItemsJson = data['low_stock_items'] as List<dynamic>? ?? const [];

    return PharmacyDashboardStatsModel(
      totalMedicines: (data['total_medicines'] as num?)?.toInt() ?? 0,
      availableCount: (data['available_count'] as num?)?.toInt() ?? 0,
      lowStockCount: (data['low_count'] as num?)?.toInt() ?? 0,
      outOfStockCount: (data['out_count'] as num?)?.toInt() ?? 0,
      newInquiriesCount: (data['pending_inquiries'] as num?)?.toInt() ?? 0,
      lowStockItems: lowStockItemsJson.map((item) {
        final itemJson = item as Map<String, dynamic>;
        return PharmacyDashboardLowStockItem(
          pharmacyMedicineId: (itemJson['pharmacy_medicine_id'] as num?)?.toInt() ?? 0,
          tradeName: itemJson['trade_name'] as String? ?? '',
          quantity: (itemJson['quantity'] as num?)?.toInt() ?? 0,
        );
      }).toList(),
    );
  }
}
