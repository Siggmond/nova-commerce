enum HomeSectionId {
  browseResults,
  trendingHeader,
  trendingFeed,
  pickedHeader,
  pickedFeed,
  underHeader,
  underFeed,
}

class HomeSectionDefinition {
  const HomeSectionDefinition(this.id);

  final HomeSectionId id;
}

const homeSectionRegistry = <HomeSectionDefinition>[
  HomeSectionDefinition(HomeSectionId.trendingHeader),
  HomeSectionDefinition(HomeSectionId.trendingFeed),
  HomeSectionDefinition(HomeSectionId.pickedHeader),
  HomeSectionDefinition(HomeSectionId.pickedFeed),
  HomeSectionDefinition(HomeSectionId.underHeader),
  HomeSectionDefinition(HomeSectionId.underFeed),
  HomeSectionDefinition(HomeSectionId.browseResults),
];
