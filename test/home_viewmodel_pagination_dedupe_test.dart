import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nova_commerce/core/config/providers.dart';
import 'package:nova_commerce/domain/entities/product.dart';
import 'package:nova_commerce/domain/entities/variant.dart';
import 'package:nova_commerce/domain/repositories/product_repository.dart';
import 'package:nova_commerce/features/home/presentation/home_viewmodel.dart';

class _OverlappingPageRepo implements ProductRepository {
  @override
  Future<FeaturedProductsPage> getFeaturedProducts({
    int limit = 20,
    Object? startAfter,
  }) async {
    // Page 1: p1..p20 (must match HomeViewModel page size so hasMore becomes true)
    if (startAfter == null) {
      final items = List<Product>.generate(
        limit,
        (i) => _p('p${i + 1}'),
        growable: false,
      );
      return FeaturedProductsPage(items: items, cursor: 'p$limit');
    }

    // Page 2 overlaps by 1 item (p20) then continues: p21..p39
    final items = <Product>[_p('p20')];
    for (var i = 21; i <= 39; i++) {
      items.add(_p('p$i'));
    }
    return FeaturedProductsPage(items: items, cursor: 'p39');
  }

  @override
  Future<Product?> getProductById(String id) async {
    return null;
  }

  @override
  Future<List<Product>> getProductsByIds(Iterable<String> ids) async {
    return const [];
  }

  Product _p(String id) {
    return Product(
      id: id,
      title: 'T$id',
      brand: 'B',
      price: 10,
      currency: 'USD',
      imageUrls: const <String>[],
      description: 'd',
      variants: const [Variant(color: 'Black', size: 'M', stock: 1)],
    );
  }
}

void main() {
  test('HomeViewModel does not duplicate items when pages overlap', () async {
    final repo = _OverlappingPageRepo();

    final container = ProviderContainer(
      overrides: [productRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final vm = container.read(homeViewModelProvider.notifier);

    // Ensure initial fetch completed.
    await vm.refresh();

    final initial = container.read(homeViewModelProvider);
    expect(initial is HomeData, isTrue);

    final initialItems = (initial as HomeData).items;
    expect(initialItems.length, 20);
    expect(initialItems.first.id, 'p1');
    expect(initialItems.last.id, 'p20');

    await vm.loadMore();

    final after = container.read(homeViewModelProvider);
    expect(after is HomeData, isTrue);

    final afterItems = (after as HomeData).items;
    expect(afterItems.length, 39);
    expect(afterItems.first.id, 'p1');
    expect(afterItems.last.id, 'p39');

    final ids = afterItems.map((e) => e.id).toList();
    expect(ids.toSet().length, ids.length);
  });
}
