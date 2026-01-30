import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../domain/entities/home_config.dart';
import '../../../domain/entities/product.dart';

final homeConfigProvider = StreamProvider<HomeConfig>((ref) {
  final repo = ref.watch(homeConfigRepositoryProvider);
  return repo.watchHomeConfig().map(HomeConfig.fromMap);
});

final homeSuperDealsProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(homeSuperDealsRepositoryProvider);
  final ids = await repo.fetchSuperDealsProductIds();
  if (ids.isEmpty) return const <Product>[];
  final productRepo = ref.watch(productRepositoryProvider);
  return productRepo.getProductsByIds(ids);
});
