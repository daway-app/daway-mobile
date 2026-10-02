import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/cancel_order_usecase.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final GetOrdersUseCase _getOrdersUseCase;
  final CancelOrderUseCase _cancelOrderUseCase;

  OrdersCubit(this._getOrdersUseCase, this._cancelOrderUseCase)
      : super(const OrdersLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const OrdersLoading());
    final result = await _getOrdersUseCase();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(OrdersLoaded(data));
      case ApiError(:final failure):
        emit(OrdersLoadFailure(failure.message));
    }
  }

  /// Cancels [order] then reloads the list. Returns null on success, or a
  /// user-facing error message.
  Future<String?> cancel(Order order) async {
    final orderId = int.tryParse(order.orderNumber);
    if (orderId == null) return 'تعذر تحديد رقم الطلب';

    final result = await _cancelOrderUseCase(orderId);
    if (isClosed) return null;
    switch (result) {
      case Success():
        await load();
        return null;
      case ApiError(:final failure):
        return failure.message;
    }
  }
}
