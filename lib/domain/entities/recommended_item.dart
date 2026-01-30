class RecommendedItem {
  const RecommendedItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.soldCount,
    required this.tags,
  });

  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final double rating;
  final int soldCount;
  final List<String> tags;
}

enum RecommendedFilter { all, hotDeals, frequentFavorites }
