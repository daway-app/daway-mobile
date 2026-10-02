/// An order a patient placed with the pharmacy, as the home screen's "الطلبات"
/// cards show it. There is no orders API yet (the pharmacy endpoints stop at
/// inventory, inquiries and ratings), so nothing constructs a real one — this
/// exists so the populated home is built and tested ahead of that backend,
/// the same way the patient side's `Order` is.
class PharmacyOrder {
  /// Without the leading "#" ("DW-1021").
  final String orderNumber;

  /// In local time — a UTC timestamp from the API has to be converted first:
  /// the card's "منذ 5 د" / "أمس" compares calendar dates, which a UTC value
  /// would put on the wrong day around midnight.
  final DateTime createdAt;
  final int itemsCount;

  /// In shekels.
  final double total;

  /// Where it is going ("غزة - النصر").
  final String area;

  const PharmacyOrder({
    required this.orderNumber,
    required this.createdAt,
    required this.itemsCount,
    required this.total,
    required this.area,
  });
}
