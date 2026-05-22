import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nova_commerce/app/di/app_providers.dart';
import 'package:nova_commerce/features/home/domain/entities/home_config.dart';
import 'package:nova_commerce/core/domain/entities/product.dart';

final homeConfigProvider = StreamProvider<HomeConfig>((ref) {
  final repo = ref.watch(homeConfigRepositoryProvider);
  return repo.watchHomeConfig().map(HomeConfig.fromMap);
});

final homeSuperDealsProductsProvider = FutureProvider<List<Product>>((
  ref,
) async {
  final repo = ref.watch(homeSuperDealsRepositoryProvider);
  final ids = await repo.fetchSuperDealsProductIds();
  if (ids.isEmpty) return const <Product>[];
  final productRepo = ref.watch(productRepositoryProvider);
  return productRepo.getProductsByIds(ids);
});
