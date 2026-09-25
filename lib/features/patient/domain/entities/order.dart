enum OrderStatus { completed, inProgress, cancelled }

/// A patient's order. There is no checkout/orders backend yet (no cart, no
/// orders API), so nothing currently constructs a real one — this exists so
/// the "طلباتي" screen's populated-state UI (status tabs, order cards) is
/// fully built and tested ahead of that backend landing.
class Order {
  final String orderNumber;
  final String pharmacyName;
  final OrderStatus status;
  final int itemsCount;
  final double price;
  final String address;
  final DateTime createdAt;

  const Order({
    required this.orderNumber,
    required this.pharmacyName,
    required this.status,
    required this.itemsCount,
    required this.price,
    required this.address,
    required this.createdAt,
  });
}
