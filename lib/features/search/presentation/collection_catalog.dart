class SearchCollection {
  const SearchCollection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.category,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String category;
}

const searchCollections = <SearchCollection>[
  SearchCollection(
    id: 'editorial_1',
    title: 'Editor’s selection',
    subtitle: 'Curated finds with premium finishes',
    imageUrl:
        'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=1200&q=70',
    category: 'Groceries',
  ),
  SearchCollection(
    id: 'editorial_2',
    title: 'Weekend essentials',
    subtitle: 'Low effort, high impact staples',
    imageUrl:
        'https://images.unsplash.com/photo-1520975693416-35a0d50c1bb9?auto=format&fit=crop&w=1200&q=70',
    category: 'Restaurants',
  ),
  SearchCollection(
    id: 'editorial_3',
    title: 'Clean tech',
    subtitle: 'Minimal + modern picks',
    imageUrl:
        'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=1200&q=70',
    category: 'Electronics',
  ),
  SearchCollection(
    id: 'editorial_4',
    title: 'Coffee corner',
    subtitle: 'Small upgrades that feel expensive',
    imageUrl:
        'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=1200&q=70',
    category: 'Coffee',
  ),
  SearchCollection(
    id: 'editorial_5',
    title: 'Everyday treats',
    subtitle: 'Snackable favorites',
    imageUrl:
        'https://images.unsplash.com/photo-1584270354949-1d52f0d8c2d0?auto=format&fit=crop&w=1200&q=70',
    category: 'Snacks',
  ),
  SearchCollection(
    id: 'editorial_6',
    title: 'Baby & family',
    subtitle: 'Soft picks, gentle choices',
    imageUrl:
        'https://images.unsplash.com/photo-1588072432836-10c7f2d9c1f2?auto=format&fit=crop&w=1200&q=70',
    category: 'Baby',
  ),
];

SearchCollection? searchCollectionById(String id) {
  for (final c in searchCollections) {
    if (c.id == id) return c;
  }
  return null;
}
