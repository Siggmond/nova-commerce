import 'package:nova_commerce/features/offers/domain/entities/offer.dart';
import 'package:nova_commerce/features/offers/domain/repositories/offers_repository.dart';

class FakeOffersRepository implements OffersRepository {
  FakeOffersRepository({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  late final List<Offer> _offers = _seed();

  @override
  Future<OffersPage> getOffers({
    required OffersQuery query,
    int limit = 20,
    Object? startAfter,
  }) async {
    final start = startAfter is int ? startAfter : 0;

    Iterable<Offer> filtered = _offers;

    final onlyFeatured = query.onlyFeatured;
    if (onlyFeatured == true) {
      filtered = filtered.where((o) => o.isFeatured);
    }

    final channel = query.channel;
    if (channel != null) {
      filtered = filtered.where((o) => o.channels.contains(channel));
    }

    final tags = query.tags;
    if (tags != null && tags.isNotEmpty) {
      final set = tags
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toSet();
      if (set.isNotEmpty) {
        filtered = filtered.where((o) {
          final offerTags = o.tags.map((e) => e.toLowerCase()).toSet();
          return offerTags.intersection(set).isNotEmpty;
        });
      }
    }

    final text = query.searchText?.trim().toLowerCase();
    if (text != null && text.isNotEmpty) {
      filtered = filtered.where((o) {
        return o.title.toLowerCase().contains(text) ||
            o.brandName.toLowerCase().contains(text) ||
            o.description.toLowerCase().contains(text);
      });
    }

    final list = filtered.toList(growable: false);

    list.sort((a, b) {
      switch (query.sort) {
        case OfferSort.endingSoon:
          return a.endAt.compareTo(b.endAt);
        case OfferSort.highestDiscount:
          return b.discountValue.compareTo(a.discountValue);
        case OfferSort.newest:
          return b.startAt.compareTo(a.startAt);
        case OfferSort.recommended:
          final f = (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0);
          if (f != 0) return f;
          return b.startAt.compareTo(a.startAt);
      }
    });

    if (start >= list.length) {
      return const OffersPage(items: <Offer>[], cursor: null);
    }

    final slice = list.skip(start).take(limit).toList(growable: false);
    final nextCursor = (start + slice.length) >= list.length
        ? null
        : start + slice.length;
    return OffersPage(items: slice, cursor: nextCursor);
  }

  @override
  Future<Offer?> getOfferById(String id) async {
    for (final o in _offers) {
      if (o.id == id) return o;
    }
    return null;
  }

  List<Offer> _seed() {
    final now = _now();
    final brands = <String>[
      'Nova',
      'Orbit',
      'Pulse',
      'Aster',
      'Vertex',
      'Lumen',
      'Sable',
    ];
    final images = <String>[''];

    OfferDiscountType typeFor(int i) {
      if (i % 9 == 0) return OfferDiscountType.bogo;
      if (i % 3 == 0) return OfferDiscountType.amount;
      if (i % 2 == 0) return OfferDiscountType.percent;
      return OfferDiscountType.other;
    }

    List<OfferChannel> channelsFor(int i) {
      if (i % 5 == 0) return const [OfferChannel.inStore];
      if (i % 4 == 0) return const [OfferChannel.online, OfferChannel.inStore];
      return const [OfferChannel.online];
    }

    List<String> tagsFor(int i) {
      final out = <String>['all'];
      if (i % 2 == 0) out.add('popular');
      if (i % 3 == 0) out.add('new');
      if (i % 4 == 0) out.add('expiring');
      if (i % 7 == 0) out.add('featured');
      return out;
    }

    final list = <Offer>[];
    for (var i = 0; i < 36; i++) {
      final brand = brands[i % brands.length];
      final type = typeFor(i);
      final value = switch (type) {
        OfferDiscountType.percent => 10 + (i % 6) * 5,
        OfferDiscountType.amount => 5 + (i % 10) * 2,
        OfferDiscountType.bogo => 1,
        OfferDiscountType.other => 0,
      };

      final startAt = now.subtract(Duration(days: (i % 6) * 2));
      final endAt = now.add(Duration(hours: 6 + (i % 12) * 10));
      final isFeatured = i % 7 == 0 || i % 11 == 0;

      final promoCode = (i % 3 == 0) ? 'NOVA${100 + i}' : null;

      list.add(
        Offer(
          id: 'offer_$i',
          title: switch (type) {
            OfferDiscountType.percent => '$value% off selected items',
            OfferDiscountType.amount => '\$$value off your next order',
            OfferDiscountType.bogo => 'Buy 1 get 1 free',
            OfferDiscountType.other => 'Limited-time deal',
          },
          description: 'Limited availability. Terms apply.',
          brandName: brand,
          imageUrl: images[i % images.length],
          discountType: type,
          discountValue: value.toDouble(),
          startAt: startAt,
          endAt: endAt,
          tags: tagsFor(i),
          channels: channelsFor(i),
          promoCode: promoCode,
          termsUrl: 'https://example.com/terms',
          isFeatured: isFeatured,
        ),
      );
    }

    return list;
  }
}
