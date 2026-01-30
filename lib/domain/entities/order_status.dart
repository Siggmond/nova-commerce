enum OrderStatus {
  placed,
  processing,
  shipped,
  delivered,
  cancelled,
  unknown,
}

OrderStatus parseOrderStatus(String? raw) {
  final value = (raw ?? '').trim().toLowerCase();
  switch (value) {
    case 'created':
    case 'placed':
      return OrderStatus.placed;
    case 'paid':
    case 'processing':
      return OrderStatus.processing;
    case 'shipped':
      return OrderStatus.shipped;
    case 'fulfilled':
    case 'delivered':
      return OrderStatus.delivered;
    case 'cancelled':
    case 'canceled':
      return OrderStatus.cancelled;
    default:
      return OrderStatus.unknown;
  }
}
