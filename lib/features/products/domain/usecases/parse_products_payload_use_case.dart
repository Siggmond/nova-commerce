import 'package:flutter/foundation.dart';

import 'package:nova_commerce/core/domain/entities/product.dart';

import 'parse_products_payload_isolate.dart';

class ParseProductsPayloadUseCase {
  const ParseProductsPayloadUseCase();

  Future<List<Product>> call(String rawJson) {
    return compute(parseProductsPayloadInIsolate, rawJson);
  }
}
