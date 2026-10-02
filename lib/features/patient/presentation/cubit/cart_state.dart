import '../../domain/entities/cart_item.dart';

sealed class CartState {
  const CartState();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoadFailure extends CartState {
  final String message;

  const CartLoadFailure(this.message);
}

class CartLoaded extends CartState {
  final List<CartItem> items;

  /// Ids with a quantity update in flight — disables that row's steppers so
  /// a fast double-tap can't fire two overlapping writes.
  final Set<int> updatingIds;

  const CartLoaded(this.items, {this.updatingIds = const {}});

  double get total => items.fold(0, (sum, item) => sum + item.lineTotal);

  CartLoaded copyWith({List<CartItem>? items, Set<int>? updatingIds}) {
    return CartLoaded(items ?? this.items, updatingIds: updatingIds ?? this.updatingIds);
  }
}
