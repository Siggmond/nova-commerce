import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nova_commerce/domain/entities/product.dart';
import 'package:nova_commerce/domain/entities/variant.dart';
import 'package:nova_commerce/features/home/presentation/home_feed_controller.dart';
import 'package:nova_commerce/features/home/presentation/home_feed_registry.dart';
import 'package:nova_commerce/features/home/presentation/home_filters.dart';
import 'package:nova_commerce/features/home/presentation/home_viewmodel.dart';
import 'package:nova_commerce/features/wishlist/presentation/wishlist_viewmodel.dart';

class TestHomeViewModel extends HomeViewModel {
  TestHomeViewModel(super.ref) {
    state = const HomeState.loading();
  }

  @override
  Future<void> refresh({bool showLoading = false}) async {
    // no-op for tests
  }

  void emitLoading() {
    state = const HomeState.loading();
  }

  void emitData(List<Product> items) {
    state = HomeState.data(
      items: items,
      isRefreshing: false,
      isLoadingMore: false,
      hasMore: false,
    );
  }

  void emitRefreshing(List<Product> items) {
    state = HomeState.data(
      items: items,
      isRefreshing: true,
      isLoadingMore: false,
      hasMore: false,
    );
  }
}

HomeSectionStatus _status(ProviderContainer c, HomeSectionId id) {
  final sections = c.read(homeFeedControllerProvider);
  return sections.firstWhere((s) => s.id == id).status;
}

final Product _product = Product(
  id: 'p-1',
  title: 'Test Product',
  brand: 'Nova',
  price: 42,
  currency: 'USD',
  imageUrls: const [],
  description: 'Test',
  variants: const [Variant(color: 'Black', size: 'M', stock: 3)],
);

void main() {
  test('Refresh intermediate empty does not flip ready sections to empty', () {
    final browseState = StateProvider<List<Product>>(
      (ref) => const <Product>[],
    );
    final underState = StateProvider<List<Product>>((ref) => const <Product>[]);

    final container = ProviderContainer(
      overrides: [
        homeViewModelProvider.overrideWith((ref) => TestHomeViewModel(ref)),
        homePersonalizationEnabledProvider.overrideWith((ref) => false),
        wishlistIdsProvider.overrideWith((ref) => const {}),
        homeFilteredProductsProvider.overrideWith(
          (ref) => ref.watch(browseState),
        ),
        homeUnder50ProductsProvider.overrideWith(
          (ref) => ref.watch(underState),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Initialize controller listeners.
    container.read(homeFeedControllerProvider);

    final vm =
        container.read(homeViewModelProvider.notifier) as TestHomeViewModel;

    // Initial loaded state (sections have items).
    container.read(browseState.notifier).state = [_product];
    container.read(underState.notifier).state = [_product];
    vm.emitData([_product]);

    expect(
      _status(container, HomeSectionId.browseResults),
      HomeSectionStatus.ready,
    );
    expect(
      _status(container, HomeSectionId.underFeed),
      HomeSectionStatus.ready,
    );

    // Refresh starts; derived providers blink empty.
    vm.emitRefreshing([_product]);
    container.read(browseState.notifier).state = const <Product>[];
    container.read(underState.notifier).state = const <Product>[];

    // Must not show EmptyState mid-refresh.
    expect(
      _status(container, HomeSectionId.browseResults),
      HomeSectionStatus.ready,
    );
    expect(
      _status(container, HomeSectionId.underFeed),
      HomeSectionStatus.ready,
    );

    // Refresh completes with data; lists recover.
    container.read(browseState.notifier).state = [_product];
    container.read(underState.notifier).state = [_product];
    vm.emitData([_product]);

    expect(
      _status(container, HomeSectionId.browseResults),
      HomeSectionStatus.ready,
    );
    expect(
      _status(container, HomeSectionId.underFeed),
      HomeSectionStatus.ready,
    );
  });

  test(
    'EmptyState allowed only after refresh completes and final result is empty',
    () {
      final browseState = StateProvider<List<Product>>(
        (ref) => const <Product>[],
      );
      final underState = StateProvider<List<Product>>(
        (ref) => const <Product>[],
      );

      final container = ProviderContainer(
        overrides: [
          homeViewModelProvider.overrideWith((ref) => TestHomeViewModel(ref)),
          homePersonalizationEnabledProvider.overrideWith((ref) => false),
          wishlistIdsProvider.overrideWith((ref) => const {}),
          homeFilteredProductsProvider.overrideWith(
            (ref) => ref.watch(browseState),
          ),
          homeUnder50ProductsProvider.overrideWith(
            (ref) => ref.watch(underState),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(homeFeedControllerProvider);

      final vm =
          container.read(homeViewModelProvider.notifier) as TestHomeViewModel;

      // Initial loaded state (sections have items).
      container.read(browseState.notifier).state = [_product];
      container.read(underState.notifier).state = [_product];
      vm.emitData([_product]);

      // Refresh starts; lists blink empty.
      vm.emitRefreshing([_product]);
      container.read(browseState.notifier).state = const <Product>[];
      container.read(underState.notifier).state = const <Product>[];

      expect(
        _status(container, HomeSectionId.browseResults),
        HomeSectionStatus.ready,
      );
      expect(
        _status(container, HomeSectionId.underFeed),
        HomeSectionStatus.ready,
      );

      // Refresh completes but final result is empty.
      container.read(browseState.notifier).state = <Product>[];
      container.read(underState.notifier).state = <Product>[];
      vm.emitData([_product]);

      expect(
        _status(container, HomeSectionId.browseResults),
        HomeSectionStatus.empty,
      );
      expect(
        _status(container, HomeSectionId.underFeed),
        HomeSectionStatus.empty,
      );
    },
  );
}
