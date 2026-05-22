import 'package:nova_commerce/features/offers/domain/entities/offer.dart';

const String _winterSaleAssetPath = 'assets/images/winter-sale.png';

String? offerFallbackImagePath(Offer offer) {
  final title = offer.title.toLowerCase();
  final isWinterSale = title.contains('winter') && title.contains('sale');
  if (!isWinterSale) {
    return null;
  }
  return _winterSaleAssetPath;
}
