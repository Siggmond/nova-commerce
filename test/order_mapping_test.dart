import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nova_commerce/features/orders/data/dto/order_dto.dart';
import 'package:nova_commerce/features/orders/data/mappers/order_mapper.dart';

void main() {
  test(
    'OrderDto.fromJson tolerates missing/invalid fields and normalizes items list',
    () {
      final dto = OrderDto.fromJson(
        id: 'o1',
        json: {
          'uid': 'u',
          'deviceId': 'd',
          'status': 'created',
          'currency': 'USD',
          'subtotal': 10,
          'shippingFee': 0,
          'total': 10,
          'shipping': {'fullName': 'A'},
          'items': [
            {
              'productId': 'p1',
              'title': 'T',
              'price': 10,
              'quantity': 1,
              'selectedColor': 'Black',
              'selectedSize': 'M',
            },
            'invalid',
            123,
            {'productId': 'p2'},
          ],
          'createdAt': Timestamp.fromDate(DateTime.utc(2025, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime.utc(2025, 1, 2)),
        },
      );

      expect(dto.items.length, 2);
      expect(dto.items.first['productId'], 'p1');
    },
  );

  test('OrderMapper maps timestamps to UTC DateTime', () {
    final dto = OrderDto.fromJson(
      id: 'o1',
      json: {
        'uid': 'u',
        'deviceId': 'd',
        'status': 'created',
        'currency': 'USD',
        'subtotal': 10,
        'shippingFee': 0,
        'total': 10,
        'shipping': {'fullName': 'A'},
        'items': [
          {
            'productId': 'p1',
            'title': 'T',
            'price': 10,
            'quantity': 1,
            'selectedColor': 'Black',
            'selectedSize': 'M',
          },
        ],
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1, 10, 0)),
        'updatedAt': Timestamp.fromDate(DateTime(2025, 1, 2, 10, 0)),
      },
    );

    final order = OrderMapper.toDomain(dto);
    expect(order.createdAt, isNotNull);
    expect(order.createdAt!.isUtc, isTrue);
    expect(order.updatedAt!.isUtc, isTrue);
  });
}
