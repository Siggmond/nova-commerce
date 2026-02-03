import '../entities/offer.dart';

enum OfferSort { recommended, endingSoon, highestDiscount, newest }

class OffersQuery {
  const OffersQuery({
    this.searchText,
    this.tags,
    this.channel,
    this.sort = OfferSort.recommended,
    this.onlyFeatured,
  });

  final String? searchText;
  final List<String>? tags;
  final OfferChannel? channel;
  final OfferSort sort;
  final bool? onlyFeatured;

  OffersQuery copyWith({
    String? searchText,
    List<String>? tags,
    OfferChannel? channel,
    OfferSort? sort,
    bool? onlyFeatured,
  }) {
    return OffersQuery(
      searchText: searchText ?? this.searchText,
      tags: tags ?? this.tags,
      channel: channel ?? this.channel,
      sort: sort ?? this.sort,
      onlyFeatured: onlyFeatured ?? this.onlyFeatured,
    );
  }
}

class OffersPage {
  const OffersPage({required this.items, required this.cursor});

  final List<Offer> items;
  final Object? cursor;
}

abstract class OffersRepository {
  Future<OffersPage> getOffers({
    required OffersQuery query,
    int limit = 20,
    Object? startAfter,
  });

  Future<Offer?> getOfferById(String id);
}
