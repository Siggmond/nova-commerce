enum HomeSectionId {
  heroCarousel,
  categoriesGrid,
  editorialBanner,
  trendsEditorial,
  browseResults,
  trendingHeader,
  trendingFeed,
  pickedHeader,
  pickedFeed,
}

class HomeSectionDefinition {
  const HomeSectionDefinition(this.id);

  final HomeSectionId id;
}

const homeSectionRegistry = <HomeSectionDefinition>[
  HomeSectionDefinition(HomeSectionId.heroCarousel),
  HomeSectionDefinition(HomeSectionId.categoriesGrid),
  HomeSectionDefinition(HomeSectionId.editorialBanner),
  HomeSectionDefinition(HomeSectionId.trendsEditorial),
  HomeSectionDefinition(HomeSectionId.trendingHeader),
  HomeSectionDefinition(HomeSectionId.trendingFeed),
  HomeSectionDefinition(HomeSectionId.pickedHeader),
  HomeSectionDefinition(HomeSectionId.pickedFeed),
  HomeSectionDefinition(HomeSectionId.browseResults),
];
