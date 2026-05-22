enum OfferDiscountType { percent, amount, bogo, other }

enum OfferChannel { online, inStore, other }

class Offer {
  const Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.brandName,
    required this.imageUrl,
    required this.discountType,
    required this.discountValue,
    required this.startAt,
    required this.endAt,
    required this.tags,
    required this.channels,
    required this.isFeatured,
    this.promoCode,
    this.termsUrl,
  });

  final String id;
  final String title;
  final String description;
  final String brandName;
  final String imageUrl;

  final OfferDiscountType discountType;
  final double discountValue;

  final DateTime startAt;
  final DateTime endAt;

  final List<String> tags;
  final List<OfferChannel> channels;

  final String? promoCode;
  final String? termsUrl;
  final bool isFeatured;
}
