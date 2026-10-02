sealed class CheckoutState {
  const CheckoutState();
}

class CheckoutIdle extends CheckoutState {
  const CheckoutIdle();
}

class CheckoutInProgress extends CheckoutState {
  const CheckoutInProgress();
}

/// The patient has no saved address yet — the screen should send them to
/// pick a location, then call [CheckoutCubit.submitWithNewAddress].
class CheckoutNeedsAddress extends CheckoutState {
  const CheckoutNeedsAddress();
}

class CheckoutSuccess extends CheckoutState {
  final int orderId;

  const CheckoutSuccess(this.orderId);
}

class CheckoutFailure extends CheckoutState {
  final String message;

  const CheckoutFailure(this.message);
}
