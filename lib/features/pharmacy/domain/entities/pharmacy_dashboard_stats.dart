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

enum PharmacyInquiryStatus { newInquiry, answered, closed }

/// Maps the backend's `new`/`answered`/`closed` status string, defaulting
/// unrecognized values to [PharmacyInquiryStatus.answered] (the least
/// attention-grabbing state) rather than crashing on an unexpected string.
PharmacyInquiryStatus pharmacyInquiryStatusFrom(String? raw) {
  return switch (raw) {
    'new' => PharmacyInquiryStatus.newInquiry,
    'closed' => PharmacyInquiryStatus.closed,
    _ => PharmacyInquiryStatus.answered,
  };
}

/// One entry from `GET /pharmacy/inquiries`, trimmed to what the home
/// screen's preview list shows.
class PharmacyDashboardInquiry {
  final int id;
  final String message;
  final PharmacyInquiryStatus status;
  final DateTime createdAt;
  final String patientName;
  final String? medicineName;

  const PharmacyDashboardInquiry({
    required this.id,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.patientName,
    this.medicineName,
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
  final List<PharmacyDashboardInquiry> recentInquiries;

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
