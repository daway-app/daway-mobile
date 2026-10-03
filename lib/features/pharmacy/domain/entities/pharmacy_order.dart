/// An order a patient placed with the pharmacy, as the home screen's "الطلبات"
/// cards and the order-details screen show it. There is no orders API yet (the
/// pharmacy endpoints stop at inventory, inquiries and ratings), so nothing
/// constructs a real one — this exists so the populated screens are built and
/// tested ahead of that backend, the same way the patient side's `Order` is.
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

  /// What was ordered. The list cards only need [itemsCount], so an order
  /// without its lines (a list response that leaves them out) is still valid.
  final List<PharmacyOrderItem> items;

  /// The street line of the delivery address ("شارع الجلاء، مبنى رقم 14، شقة 3").
  final String? deliveryStreet;

  /// Null when the order carries no payment information.
  final PharmacyOrderPayment? payment;

  const PharmacyOrder({
    required this.orderNumber,
    required this.createdAt,
    required this.itemsCount,
    required this.total,
    required this.area,
    this.items = const [],
    this.deliveryStreet,
    this.payment,
  });
}

/// One medicine on an order.
class PharmacyOrderItem {
  final String name;

  /// In shekels.
  final double price;
  final String? imageUrl;

  /// Whether the pharmacy has it in stock right now.
  final bool isAvailable;

  const PharmacyOrderItem({
    required this.name,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
  });
}

/// How an order is paid, and whether it already has been.
class PharmacyOrderPayment {
  /// "محفظة إلكترونية".
  final String method;

  /// Extra line under the method ("فوري باي · ****4827"), when there is one.
  final String? detail;
  final bool isPaid;

  const PharmacyOrderPayment({required this.method, this.detail, required this.isPaid});
}
