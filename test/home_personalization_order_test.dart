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
    state = HomeState.data(
      items: [_product],
      isRefreshing: false,
      isLoadingMore: false,
      hasMore: false,
    );
  }

  void emitData() {
    state = HomeState.data(
      items: [_product],
      isRefreshing: false,
      isLoadingMore: false,
      hasMore: false,
    );
  }

  static final Product _product = Product(
    id: 'p-1',
    title: 'Test Product',
    brand: 'Nova',
    price: 42,
    currency: 'USD',
    imageUrls: const [],
    description: 'Test',
    variants: const [Variant(color: 'Black', size: 'M', stock: 3)],
  );
}

List<HomeSectionId> _order(ProviderContainer container) {
  return container.read(homeFeedControllerProvider).map((e) => e.id).toList();
}

void _triggerPersonalization(ProviderContainer container) {
  container.read(homeFeedControllerProvider);
  final vm =
      container.read(homeViewModelProvider.notifier) as TestHomeViewModel;
  vm.emitData();
}

ProviderContainer _container({
  required bool personalizationEnabled,
  required Set<String> wishlistIds,
}) {
  return ProviderContainer(
    overrides: [
      homeViewModelProvider.overrideWith((ref) => TestHomeViewModel(ref)),
      homePersonalizationEnabledProvider.overrideWith(
        (ref) => personalizationEnabled,
      ),
      wishlistIdsProvider.overrideWith((ref) => wishlistIds),
      homeUnder50ProductsProvider.overrideWith((ref) => const []),
    ],
  );
}

void main() {
  test('Personalization disabled keeps registry order', () {
    final container = _container(
      personalizationEnabled: false,
      wishlistIds: const {},
    );
    addTearDown(container.dispose);

    _triggerPersonalization(container);

    final ids = _order(container);
    final expected = homeSectionRegistry.map((e) => e.id).toList();
    expect(ids, expected);
  });

  test('Wishlist boosts picked before trending within subset', () {
    final container = _container(
      personalizationEnabled: true,
      wishlistIds: const {'p-1'},
    );
    addTearDown(container.dispose);

    _triggerPersonalization(container);

    final ids = _order(container);
    expect(
      ids
          .indexOf(HomeSectionId.pickedHeader)
          .compareTo(ids.indexOf(HomeSectionId.trendingHeader)),
      lessThan(0),
    );
    expect(
      ids
          .indexOf(HomeSectionId.pickedFeed)
          .compareTo(ids.indexOf(HomeSectionId.trendingFeed)),
      lessThan(0),
    );
  });

  test('Ties preserve registry order within groups', () {
    final container = _container(
      personalizationEnabled: true,
      wishlistIds: const {},
    );
    addTearDown(container.dispose);

    _triggerPersonalization(container);

    final ids = _order(container);
    expect(
      ids
          .indexOf(HomeSectionId.trendingHeader)
          .compareTo(ids.indexOf(HomeSectionId.trendingFeed)),
      lessThan(0),
    );
    expect(
      ids
          .indexOf(HomeSectionId.pickedHeader)
          .compareTo(ids.indexOf(HomeSectionId.pickedFeed)),
      lessThan(0),
    );
    expect(
      ids
          .indexOf(HomeSectionId.underHeader)
          .compareTo(ids.indexOf(HomeSectionId.underFeed)),
      lessThan(0),
    );
  });
}
