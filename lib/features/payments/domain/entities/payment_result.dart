sealed class PaymentResult {
  const PaymentResult();
}

class PaymentSuccess extends PaymentResult {
  const PaymentSuccess({required this.orderId});

  final String orderId;
}

class PaymentFailure extends PaymentResult {
  const PaymentFailure({required this.message});

  final String message;
}

class PaymentCanceled extends PaymentResult {
  const PaymentCanceled();
}
