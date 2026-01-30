class CheckoutCartEmptyException implements Exception {
  const CheckoutCartEmptyException();
}

class CheckoutSignInRequiredException implements Exception {
  const CheckoutSignInRequiredException();
}

class CheckoutProductNotFoundException implements Exception {
  const CheckoutProductNotFoundException();
}

class CheckoutValidationException implements Exception {
  const CheckoutValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CheckoutServerException implements Exception {
  const CheckoutServerException();
}

class CheckoutOutOfStockException implements Exception {
  const CheckoutOutOfStockException(this.message);

  final String message;

  @override
  String toString() => message;
}
