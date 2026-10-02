import '../../../../core/helpers/server_timestamp.dart';
import '../../domain/entities/order.dart';

class OrderModel {
  final String orderNumber;
  final String pharmacyName;
  final OrderStatus status;
  final int itemsCount;
  final double price;
  final String address;
  final DateTime createdAt;

  const OrderModel({
    required this.orderNumber,
    required this.pharmacyName,
    required this.status,
    required this.itemsCount,
    required this.price,
    required this.address,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final pharmacy = json['pharmacy'] as Map<String, dynamic>?;
    final address = json['address'] as Map<String, dynamic>?;
    final createdAtRaw = json['created_at'] as String?;

    return OrderModel(
      orderNumber: (json['id'] as num?)?.toInt().toString() ?? '',
      pharmacyName: pharmacy?['name'] as String? ?? '',
      status: OrderStatus.fromApi(json['status'] as String? ?? ''),
      itemsCount: (json['items_count'] as num?)?.toInt() ?? 0,
      price: (json['total'] as num?)?.toDouble() ?? 0,
      address: address?['address'] as String? ?? address?['label'] as String? ?? '',
      createdAt: tryParseServerTimestamp(createdAtRaw) ?? DateTime.now(),
    );
  }

  Order toEntity() => Order(
        orderNumber: orderNumber,
        pharmacyName: pharmacyName,
        status: status,
        itemsCount: itemsCount,
        price: price,
        address: address,
        createdAt: createdAt,
      );
}
