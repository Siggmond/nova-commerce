import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nova_commerce/domain/entities/product.dart';
import 'package:nova_commerce/domain/entities/variant.dart';
import 'package:nova_commerce/features/home/presentation/home_feed_controller.dart';
import 'package:nova_commerce/features/home/presentation/home_feed_registry.dart';
import 'package:nova_commerce/features/home/presentation/home_viewmodel.dart';

class TestHomeViewModel extends HomeViewModel {
  TestHomeViewModel(super.ref) {
    state = HomeState.data(
      items: _items,
      isRefreshing: false,
      isLoadingMore: false,
      hasMore: false,
    );
  }

  static final List<Product> _items = [
    Product(
      id: 'p-1',
      title: 'Test Product',
      brand: 'Nova',
      price: 42,
      currency: 'USD',
      imageUrls: const [],
      description: 'Test',
      variants: const [Variant(color: 'Black', size: 'M', stock: 3)],
    ),
  ];
  @override
  Future<void> refresh({bool showLoading = false}) async {}
}

 void main() {
  test('Section retry triggers controller update', () {
    final container = ProviderContainer(
      overrides: [
        homeViewModelProvider.overrideWith(
          (ref) => TestHomeViewModel(ref),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(homeFeedControllerProvider.notifier);
    controller.state = [
      for (final section in controller.state)
        if (section.id == HomeSectionId.trendingFeed)
          section.copyWith(status: HomeSectionStatus.error)
        else
          section,
    ];

    controller.retrySection(HomeSectionId.trendingFeed);

    final retrySection = controller.state.firstWhere(
      (section) => section.id == HomeSectionId.trendingFeed,
    );
    expect(retrySection.retryToken, 1);
    expect(retrySection.status, HomeSectionStatus.loading);
  });
}
