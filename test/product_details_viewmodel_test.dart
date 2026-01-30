import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nova_commerce/core/config/providers.dart';
import 'package:nova_commerce/domain/entities/product.dart';
import 'package:nova_commerce/domain/entities/variant.dart';
import 'package:nova_commerce/domain/repositories/product_repository.dart';
import 'package:nova_commerce/domain/repositories/recently_viewed_repository.dart';
import 'package:nova_commerce/features/product/presentation/product_details_viewmodel.dart';

class _SingleVariantProductRepo implements ProductRepository {
  @override
  Future<Product?> getProductById(String id) async {
    return const Product(
      id: 'p_single',
      title: 'T',
      brand: 'B',
      price: 10,
      currency: 'USD',
      imageUrls: <String>[],
      description: 'd',
      variants: [
        // exactly one in-stock variant: should auto-select
        Variant(color: 'Black', size: 'M', stock: 1),
      ],
    );
  }

  @override
  Future<FeaturedProductsPage> getFeaturedProducts({
    int limit = 20,
    Object? startAfter,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Product>> getProductsByIds(Iterable<String> ids) {
    throw UnimplementedError();
  }
}

class _NoopRecentlyViewedRepository implements RecentlyViewedRepository {
  @override
  Future<List<String>> loadIds() async => const [];

  @override
  Future<void> saveIds(List<String> ids) async {}
}

void main() {
  test(
    'ProductDetailsViewModel auto-selects when exactly one in-stock variant',
    () async {
      final repo = _SingleVariantProductRepo();

      final container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(repo),
          recentlyViewedRepositoryProvider.overrideWithValue(
            _NoopRecentlyViewedRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Provider is lazy; read triggers creation
      final state = container.read(productDetailsViewModelProvider('p_single'));
      expect(state, isA<ProductDetailsLoading>());

      // wait for async load
      await Future<void>.delayed(Duration.zero);

      final after = container.read(productDetailsViewModelProvider('p_single'));
      expect(after, isA<ProductDetailsData>());
      final data = after as ProductDetailsData;
      expect(data.selectedColor, 'Black');
      expect(data.selectedSize, 'M');
      expect(data.canAdd, isTrue);
    },
  );

  test(
    'ProductDetailsData never hides options; disabled sets are relative to current selection',
    () {
      const p = Product(
        id: 'p',
        title: 't',
        brand: 'b',
        price: 10,
        currency: 'USD',
        imageUrls: <String>[],
        description: 'd',
        variants: [
          Variant(color: 'Black', size: 'S', stock: 1),
          Variant(color: 'Black', size: 'M', stock: 1),
          Variant(color: 'White', size: 'S', stock: 1),
          // out of stock combination should not enable options
          Variant(color: 'White', size: 'M', stock: 0),
        ],
      );

      // Selecting a color should NOT remove any sizes; it should disable invalid ones
      final data = ProductDetailsData(
        product: p,
        selectedColor: 'White',
        selectedSize: null,
      );
      expect(data.availableSizes, ['M', 'S']);
      expect(data.disabledSizes, {'M'});

      // Selecting a size should NOT remove any colors; it should disable invalid ones
      final data2 = ProductDetailsData(
        product: p,
        selectedColor: null,
        selectedSize: 'M',
      );
      expect(data2.availableColors, ['Black', 'White']);
      expect(data2.disabledColors, {'White'});
    },
  );
}
