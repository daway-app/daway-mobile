enum OrderStatus {
  pending,
  confirmed,
  preparing,
  delivered,
  cancelled;

  static OrderStatus fromApi(String value) => switch (value) {
        'pending' => OrderStatus.pending,
        'confirmed' => OrderStatus.confirmed,
        'preparing' => OrderStatus.preparing,
        'delivered' => OrderStatus.delivered,
        'cancelled' => OrderStatus.cancelled,
        _ => OrderStatus.pending,
      };

  bool get isCancelled => this == OrderStatus.cancelled;
  bool get isCompleted => this == OrderStatus.delivered;
  bool get isInProgress => !isCancelled && !isCompleted;

  /// The server only cancels these three (see `POST /patient/orders/{id}/cancel`).
  bool get canCancel =>
      this == OrderStatus.pending ||
      this == OrderStatus.confirmed ||
      this == OrderStatus.preparing;
}

/// A patient's order, as returned by `GET /patient/orders`.
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
