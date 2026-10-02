import '../../domain/entities/order.dart';

sealed class OrdersState {
  const OrdersState();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersLoadFailure extends OrdersState {
  final String message;

  const OrdersLoadFailure(this.message);
}

class OrdersLoaded extends OrdersState {
  final List<Order> orders;

  const OrdersLoaded(this.orders);
}
