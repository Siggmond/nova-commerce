class SearchCollection {
  const SearchCollection({
    required this.id,
    required this.imageUrl,
    required this.categoryId,
  });

  final String id;
  final String imageUrl;
  final String categoryId;
}

const searchCollections = <SearchCollection>[
  SearchCollection(
    id: 'editorial_1',
    imageUrl: '',
    categoryId: 'groceries',
  ),
  SearchCollection(
    id: 'editorial_2',
    imageUrl: '',
    categoryId: 'restaurants',
  ),
  SearchCollection(
    id: 'editorial_3',
    imageUrl: '',
    categoryId: 'electronics',
  ),
  SearchCollection(
    id: 'editorial_4',
    imageUrl: '',
    categoryId: 'coffee',
  ),
  SearchCollection(
    id: 'editorial_5',
    imageUrl: '',
    categoryId: 'snacks',
  ),
  SearchCollection(
    id: 'editorial_6',
    imageUrl: '',
    categoryId: 'baby',
  ),
];

SearchCollection? searchCollectionById(String id) {
  for (final c in searchCollections) {
    if (c.id == id) return c;
  }
  return null;
}
