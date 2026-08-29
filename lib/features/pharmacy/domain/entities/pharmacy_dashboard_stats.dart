import 'inquiry.dart';

/// A medicine flagged in `low_stock_items` on the dashboard stats response —
/// just enough to surface a low-stock alert without a second fetch.
class PharmacyDashboardLowStockItem {
  final int pharmacyMedicineId;
  final String tradeName;
  final int quantity;

  const PharmacyDashboardLowStockItem({
    required this.pharmacyMedicineId,
    required this.tradeName,
    required this.quantity,
  });
}

/// Aggregated counts shown on the pharmacy home screen. Combines
/// `GET /pharmacy/dashboard/stats` (medicine/inventory/inquiry counts) with
/// `GET /pharmacy/ratings` — the stats endpoint has no pre-computed average
/// rating, so [averageRating] is derived client-side — and a small preview
/// of `GET /pharmacy/inquiries` (see PharmacyDashboardRepositoryImpl).
class PharmacyDashboardStats {
  final int totalMedicines;
  final int availableCount;
  final int lowStockCount;
  final int outOfStockCount;
  final int newInquiriesCount;
  final double? averageRating;
  final int ratingsCount;
  final List<PharmacyDashboardLowStockItem> lowStockItems;
  final List<Inquiry> recentInquiries;

  const PharmacyDashboardStats({
    required this.totalMedicines,
    required this.availableCount,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.newInquiriesCount,
    required this.averageRating,
    required this.ratingsCount,
    required this.lowStockItems,
    required this.recentInquiries,
  });
}
