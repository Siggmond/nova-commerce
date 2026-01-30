import 'package:flutter/material.dart';

import '../../../domain/entities/order_status.dart';

String orderStatusLabel(OrderStatus status, String raw) {
  switch (status) {
    case OrderStatus.placed:
      return 'Placed';
    case OrderStatus.processing:
      return 'Processing';
    case OrderStatus.shipped:
      return 'Shipped';
    case OrderStatus.delivered:
      return 'Delivered';
    case OrderStatus.cancelled:
      return 'Cancelled';
    case OrderStatus.unknown:
      return raw.trim().isEmpty ? 'Unknown' : raw;
  }
}

IconData orderStatusIcon(OrderStatus status) {
  switch (status) {
    case OrderStatus.placed:
      return Icons.receipt_long;
    case OrderStatus.processing:
      return Icons.inventory_2;
    case OrderStatus.shipped:
      return Icons.local_shipping;
    case OrderStatus.delivered:
      return Icons.check_circle;
    case OrderStatus.cancelled:
      return Icons.cancel;
    case OrderStatus.unknown:
      return Icons.help_outline;
  }
}
