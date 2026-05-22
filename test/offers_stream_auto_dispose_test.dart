import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nova_commerce/app/di/app_providers.dart';
import 'package:nova_commerce/features/offers/domain/entities/offer.dart';
import 'package:nova_commerce/features/offers/domain/repositories/offers_repository.dart';
import 'package:nova_commerce/features/offers/presentation/offers_viewmodel.dart';

class _CachingTrackingOffersRepository implements OffersRepository {
  _CachingTrackingOffersRepository(this._offers);

  final List<Offer> _offers;
  final Map<String, OffersPage> _pageCache = <String, OffersPage>{};
  final Map<String, Offer?> _offerByIdCache = <String, Offer?>{};

  int pageRequests = 0;
  int pageRemoteReads = 0;
  int offerByIdRequests = 0;
  int offerByIdRemoteReads = 0;

  @override
  Future<OffersPage> getOffers({
    required OffersQuery query,
    int limit = 20,
    Object? startAfter,
  }) async {
    pageRequests += 1;
    final cacheKey = '${query.hashCode}|$limit|${startAfter ?? 'root'}';
    final cached = _pageCache[cacheKey];
    if (cached != null) {
      return cached;
    }

    pageRemoteReads += 1;
    final start = startAfter is int ? startAfter : 0;
    if (start >= _offers.length) {
      const page = OffersPage(items: <Offer>[], cursor: null);
      _pageCache[cacheKey] = page;
      return page;
    }

    final items = _offers.skip(start).take(limit).toList(growable: false);
    final cursor = (start + items.length) >= _offers.length
        ? null
        : start + items.length;
    final page = OffersPage(items: items, cursor: cursor);
    _pageCache[cacheKey] = page;
    for (final offer in items) {
      _offerByIdCache[offer.id] = offer;
    }
    return page;
  }

  @override
  Future<Offer?> getOfferById(String id) async {
    offerByIdRequests += 1;
    if (_offerByIdCache.containsKey(id)) {
      return _offerByIdCache[id];
    }

    offerByIdRemoteReads += 1;
    Offer? matched;
    for (final offer in _offers) {
      if (offer.id == id) {
        matched = offer;
        break;
      }
    }
    _offerByIdCache[id] = matched;
    return matched;
  }
}

void main() {
  test(
    'Offers first page uses repository cache across provider invalidation',
    () async {
      final repo = _CachingTrackingOffersRepository(<Offer>[
        _offer(
          id: 'offer_1',
          title: '10% Off',
          brandName: 'Nova',
          discountType: OfferDiscountType.percent,
          discountValue: 10,
        ),
      ]);
      final container = ProviderContainer(
        overrides: [offersRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final first = await container.read(offersFirstPageProvider.future);
      expect(first.items.length, 1);
      expect(repo.pageRequests, 1);
      expect(repo.pageRemoteReads, 1);

      container.invalidate(offersFirstPageProvider);
      final second = await container.read(offersFirstPageProvider.future);
      expect(second.items.length, 1);
      expect(repo.pageRequests, 2);
      expect(
        repo.pageRemoteReads,
        1,
        reason:
            'second fetch should hit session cache, not trigger new remote read',
      );
    },
  );

  test(
    'Offer details uses repository cache across provider invalidation',
    () async {
      final repo = _CachingTrackingOffersRepository(<Offer>[
        _offer(
          id: 'offer_1',
          title: '15% Off',
          brandName: 'Orbit',
          discountType: OfferDiscountType.percent,
          discountValue: 15,
        ),
      ]);
      final container = ProviderContainer(
        overrides: [offersRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final first = await container.read(offerByIdProvider('offer_1').future);
      expect(first?.id, 'offer_1');
      expect(repo.offerByIdRequests, 1);
      expect(repo.offerByIdRemoteReads, 1);

      container.invalidate(offerByIdProvider('offer_1'));
      final second = await container.read(offerByIdProvider('offer_1').future);
      expect(second?.id, 'offer_1');
      expect(repo.offerByIdRequests, 2);
      expect(
        repo.offerByIdRemoteReads,
        1,
        reason: 'second details fetch should reuse session cache',
      );
    },
  );
}

Offer _offer({
  required String id,
  required String title,
  required String brandName,
  required OfferDiscountType discountType,
  required double discountValue,
}) {
  return Offer(
    id: id,
    title: title,
    description: 'desc',
    brandName: brandName,
    imageUrl: '',
    discountType: discountType,
    discountValue: discountValue,
    startAt: DateTime(2026, 1, 1),
    endAt: DateTime(2026, 12, 31),
    tags: const <String>[],
    channels: const <OfferChannel>[OfferChannel.online],
    isFeatured: false,
  );
}
