import '../../../../domain/entities/order.dart';
import '../../../../domain/entities/order_item.dart';
import '../../../../domain/entities/order_status.dart';
import '../dto/order_dto.dart';

class OrderMapper {
  static Order toDomain(OrderDto dto) {
    final items = <OrderItem>[];
    for (final e in dto.items) {
      items.add(OrderItem.fromJson(e));
    }

    return Order(
      id: dto.id,
      uid: dto.uid,
      deviceId: dto.deviceId,
      status: parseOrderStatus(dto.status),
      statusRaw: dto.status,
      currency: dto.currency,
      subtotal: dto.subtotal,
      shippingFee: dto.shippingFee,
      total: dto.total,
      shipping: dto.shipping,
      items: items,
      createdAt: dto.createdAt?.toDate().toUtc(),
      updatedAt: dto.updatedAt?.toDate().toUtc(),
    );
  }
}
