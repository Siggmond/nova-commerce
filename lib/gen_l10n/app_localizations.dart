import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'NovaCommerce'**
  String get appTitle;

  /// No description provided for @brandName.
  ///
  /// In en, this message translates to:
  /// **'Nova'**
  String get brandName;

  /// No description provided for @navShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get navShop;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navAi.
  ///
  /// In en, this message translates to:
  /// **'Concierge'**
  String get navAi;

  /// No description provided for @navOffers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get navOffers;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @aiChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Nova Concierge'**
  String get aiChatTitle;

  /// No description provided for @aiChatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find, compare, and buy faster'**
  String get aiChatSubtitle;

  /// No description provided for @aiChatPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Nova AI replies are generated and may be inaccurate. This demo does not provide citations. Your conversations are saved locally on this device and can be cleared anytime.'**
  String get aiChatPrivacyNote;

  /// No description provided for @aiChatTooltipSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get aiChatTooltipSessions;

  /// No description provided for @aiChatTooltipInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get aiChatTooltipInfo;

  /// No description provided for @aiChatTooltipClearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get aiChatTooltipClearChat;

  /// No description provided for @aiChatTooltipAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get aiChatTooltipAdd;

  /// No description provided for @aiChatTooltipSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get aiChatTooltipSend;

  /// No description provided for @aiChatHint.
  ///
  /// In en, this message translates to:
  /// **'Budget, vibe, use-case…'**
  String get aiChatHint;

  /// No description provided for @aiChatSnackbarChatCleared.
  ///
  /// In en, this message translates to:
  /// **'Chat cleared'**
  String get aiChatSnackbarChatCleared;

  /// No description provided for @aiChatSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get aiChatSessionsTitle;

  /// No description provided for @aiChatNewSessionCta.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get aiChatNewSessionCta;

  /// No description provided for @aiChatSearchSessionsHint.
  ///
  /// In en, this message translates to:
  /// **'Search sessions'**
  String get aiChatSearchSessionsHint;

  /// No description provided for @aiChatNewChatTitle.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get aiChatNewChatTitle;

  /// No description provided for @aiChatSeedAssistantMessage.
  ///
  /// In en, this message translates to:
  /// **'I can help you narrow down fast. Tell me your budget + style + use-case, and I’ll suggest a short set of options.\n\nExample: “black hoodie under \$50, oversized”.'**
  String get aiChatSeedAssistantMessage;

  /// No description provided for @aiChatSnackbarCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get aiChatSnackbarCopied;

  /// No description provided for @aiChatCopyCta.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get aiChatCopyCta;

  /// No description provided for @aiChatRegenerateCta.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get aiChatRegenerateCta;

  /// No description provided for @aiChatPickedForYouTitle.
  ///
  /// In en, this message translates to:
  /// **'Picked for you'**
  String get aiChatPickedForYouTitle;

  /// No description provided for @aiChatInlineAddCta.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get aiChatInlineAddCta;

  /// No description provided for @aiChatSnackbarAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get aiChatSnackbarAddedToCart;

  /// No description provided for @aiChatDefaultOption.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get aiChatDefaultOption;

  /// No description provided for @aiChatLandingGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}'**
  String aiChatLandingGreeting(String name);

  /// No description provided for @aiChatLandingPrompt.
  ///
  /// In en, this message translates to:
  /// **'What can I help you shop for today?'**
  String get aiChatLandingPrompt;

  /// No description provided for @aiChatQuickActionFindDealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Find deals today'**
  String get aiChatQuickActionFindDealsTitle;

  /// No description provided for @aiChatQuickActionPickOutfitTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick an outfit'**
  String get aiChatQuickActionPickOutfitTitle;

  /// No description provided for @aiChatQuickActionGiftIdeasTitle.
  ///
  /// In en, this message translates to:
  /// **'Gift ideas'**
  String get aiChatQuickActionGiftIdeasTitle;

  /// No description provided for @aiChatQuickActionTrackOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Track my order'**
  String get aiChatQuickActionTrackOrderTitle;

  /// No description provided for @aiChatCartItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String aiChatCartItemsCount(int count);

  /// No description provided for @aiChatWishlistSavedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} saved'**
  String aiChatWishlistSavedCount(int count);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @commonComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get commonComingSoon;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @messagesTabOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get messagesTabOrder;

  /// No description provided for @messagesTabActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get messagesTabActivity;

  /// No description provided for @messagesTabPromo.
  ///
  /// In en, this message translates to:
  /// **'Promo'**
  String get messagesTabPromo;

  /// No description provided for @messagesTabNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get messagesTabNews;

  /// No description provided for @trendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get trendsTitle;

  /// No description provided for @homePickedForYouTitle.
  ///
  /// In en, this message translates to:
  /// **'Picked for you'**
  String get homePickedForYouTitle;

  /// No description provided for @homePickedForYouSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick matches based on your taste (demo)'**
  String get homePickedForYouSubtitle;

  /// No description provided for @homePicksLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load picks'**
  String get homePicksLoadErrorTitle;

  /// No description provided for @homeNoPicksTitle.
  ///
  /// In en, this message translates to:
  /// **'No picks yet'**
  String get homeNoPicksTitle;

  /// No description provided for @homeTrendingNowTitle.
  ///
  /// In en, this message translates to:
  /// **'Trending now'**
  String get homeTrendingNowTitle;

  /// No description provided for @homeTrendingNowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ranked by what people are tapping today'**
  String get homeTrendingNowSubtitle;

  /// No description provided for @homeTrendingNowLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load trending now'**
  String get homeTrendingNowLoadErrorTitle;

  /// No description provided for @homeNoTrendingPicksTitle.
  ///
  /// In en, this message translates to:
  /// **'No trending picks yet'**
  String get homeNoTrendingPicksTitle;

  /// No description provided for @homeCuratedTrendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Curated trends'**
  String get homeCuratedTrendsTitle;

  /// No description provided for @homeCuratedTrendsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Editor’s picks — styled, versatile, and easy to pair.'**
  String get homeCuratedTrendsSubtitle;

  /// No description provided for @homeShopByCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop by category'**
  String get homeShopByCategoryTitle;

  /// No description provided for @homeShopByCategorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick entry points'**
  String get homeShopByCategorySubtitle;

  /// No description provided for @homeBadgeNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get homeBadgeNew;

  /// No description provided for @homeUpdatedToday.
  ///
  /// In en, this message translates to:
  /// **'Updated today'**
  String get homeUpdatedToday;

  /// No description provided for @homeCategoryItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String homeCategoryItemsCount(int count);

  /// No description provided for @homeWeekendSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekend Sale'**
  String get homeWeekendSaleTitle;

  /// No description provided for @homeWeekendSaleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Extra 15% off selected items'**
  String get homeWeekendSaleSubtitle;

  /// No description provided for @homeWeekendSaleCta.
  ///
  /// In en, this message translates to:
  /// **'Shop now'**
  String get homeWeekendSaleCta;

  /// No description provided for @homeDeliverToCity.
  ///
  /// In en, this message translates to:
  /// **'Deliver to {city}'**
  String homeDeliverToCity(String city);

  /// No description provided for @homeCityBeirut.
  ///
  /// In en, this message translates to:
  /// **'Beirut'**
  String get homeCityBeirut;

  /// No description provided for @homeCityTripoli.
  ///
  /// In en, this message translates to:
  /// **'Tripoli'**
  String get homeCityTripoli;

  /// No description provided for @homeCitySidon.
  ///
  /// In en, this message translates to:
  /// **'Sidon'**
  String get homeCitySidon;

  /// No description provided for @homeCityTyre.
  ///
  /// In en, this message translates to:
  /// **'Tyre'**
  String get homeCityTyre;

  /// No description provided for @homeCityJounieh.
  ///
  /// In en, this message translates to:
  /// **'Jounieh'**
  String get homeCityJounieh;

  /// No description provided for @homeCityByblos.
  ///
  /// In en, this message translates to:
  /// **'Byblos'**
  String get homeCityByblos;

  /// No description provided for @homeCityZahle.
  ///
  /// In en, this message translates to:
  /// **'Zahle'**
  String get homeCityZahle;

  /// No description provided for @homeCityBaalbek.
  ///
  /// In en, this message translates to:
  /// **'Baalbek'**
  String get homeCityBaalbek;

  /// No description provided for @homeCityNabatieh.
  ///
  /// In en, this message translates to:
  /// **'Nabatieh'**
  String get homeCityNabatieh;

  /// No description provided for @homeCityBatroun.
  ///
  /// In en, this message translates to:
  /// **'Batroun'**
  String get homeCityBatroun;

  /// No description provided for @homeCityBsharri.
  ///
  /// In en, this message translates to:
  /// **'Bsharri'**
  String get homeCityBsharri;

  /// No description provided for @homeCityAley.
  ///
  /// In en, this message translates to:
  /// **'Aley'**
  String get homeCityAley;

  /// No description provided for @homeCategoryGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get homeCategoryGroceries;

  /// No description provided for @homeCategoryRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get homeCategoryRestaurants;

  /// No description provided for @homeCategoryPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get homeCategoryPharmacy;

  /// No description provided for @homeCategoryCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get homeCategoryCoffee;

  /// No description provided for @homeCategoryBakery.
  ///
  /// In en, this message translates to:
  /// **'Bakery'**
  String get homeCategoryBakery;

  /// No description provided for @homeCategoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get homeCategoryElectronics;

  /// No description provided for @homeCategoryFlowers.
  ///
  /// In en, this message translates to:
  /// **'Flowers'**
  String get homeCategoryFlowers;

  /// No description provided for @homeCategoryPetSupplies.
  ///
  /// In en, this message translates to:
  /// **'Pet Supplies'**
  String get homeCategoryPetSupplies;

  /// No description provided for @homeCategoryCosmetics.
  ///
  /// In en, this message translates to:
  /// **'Cosmetics'**
  String get homeCategoryCosmetics;

  /// No description provided for @homeCategorySnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get homeCategorySnacks;

  /// No description provided for @homeCategoryDrinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get homeCategoryDrinks;

  /// No description provided for @homeCategoryBaby.
  ///
  /// In en, this message translates to:
  /// **'Baby'**
  String get homeCategoryBaby;

  /// No description provided for @homeCuratedTrendsLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load curated trends'**
  String get homeCuratedTrendsLoadErrorTitle;

  /// No description provided for @homeCuratedTrendsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No curated picks yet.'**
  String get homeCuratedTrendsEmptyTitle;

  /// No description provided for @homeCuratedTrendsIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'This week’s edit'**
  String get homeCuratedTrendsIntroTitle;

  /// No description provided for @homeCuratedTrendsIntroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A curated selection from our catalog — chosen for style, versatility, and easy pairing. Not a popularity leaderboard.'**
  String get homeCuratedTrendsIntroSubtitle;

  /// No description provided for @homeCuratedTrendsEditorsFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Editor’s favorites'**
  String get homeCuratedTrendsEditorsFavoritesTitle;

  /// No description provided for @homeCuratedTrendsEditorsFavoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Strong picks to start with.'**
  String get homeCuratedTrendsEditorsFavoritesSubtitle;

  /// No description provided for @homeCuratedTrendsWorthALookTitle.
  ///
  /// In en, this message translates to:
  /// **'Worth a look'**
  String get homeCuratedTrendsWorthALookTitle;

  /// No description provided for @homeCuratedTrendsWorthALookSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A few more curated picks for variety.'**
  String get homeCuratedTrendsWorthALookSubtitle;

  /// No description provided for @homeCuratedTrendsMorePicksTitle.
  ///
  /// In en, this message translates to:
  /// **'More curated picks'**
  String get homeCuratedTrendsMorePicksTitle;

  /// No description provided for @homeCuratedTrendsMorePicksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If you want to explore beyond the edit.'**
  String get homeCuratedTrendsMorePicksSubtitle;

  /// No description provided for @homeCuratedTrendsEditorsPickBadge.
  ///
  /// In en, this message translates to:
  /// **'Editor’s pick'**
  String get homeCuratedTrendsEditorsPickBadge;

  /// No description provided for @homeCuratedTrendsHeroPickLabel.
  ///
  /// In en, this message translates to:
  /// **'This week’s hero pick'**
  String get homeCuratedTrendsHeroPickLabel;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @collectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collectionTitle;

  /// No description provided for @collectionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Collection not found.'**
  String get collectionNotFound;

  /// No description provided for @collectionLoadProductsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load products'**
  String get collectionLoadProductsErrorTitle;

  /// No description provided for @collectionLoadProductsErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get collectionLoadProductsErrorSubtitle;

  /// No description provided for @collectionNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get collectionNoResultsTitle;

  /// No description provided for @collectionNoResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword or filters.'**
  String get collectionNoResultsSubtitle;

  /// No description provided for @searchNoResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword.'**
  String get searchNoResultsSubtitle;

  /// No description provided for @searchFeaturedTitle.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get searchFeaturedTitle;

  /// No description provided for @searchCollectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get searchCollectionsTitle;

  /// No description provided for @searchCollectionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Editorial picks designed to inspire your next cart.'**
  String get searchCollectionsSubtitle;

  /// No description provided for @searchBackToShopTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back to Shop'**
  String get searchBackToShopTooltip;

  /// No description provided for @searchHintSearchForProducts.
  ///
  /// In en, this message translates to:
  /// **'Search for products'**
  String get searchHintSearchForProducts;

  /// No description provided for @searchHintSearchInCollection.
  ///
  /// In en, this message translates to:
  /// **'Search in this collection'**
  String get searchHintSearchInCollection;

  /// No description provided for @searchTooltipSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTooltipSearch;

  /// No description provided for @searchTooltipFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get searchTooltipFilters;

  /// No description provided for @searchFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get searchFiltersTitle;

  /// No description provided for @searchFiltersClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get searchFiltersClearAll;

  /// No description provided for @searchFiltersApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get searchFiltersApply;

  /// No description provided for @searchFiltersSortByTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get searchFiltersSortByTitle;

  /// No description provided for @searchFiltersSortRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get searchFiltersSortRecommended;

  /// No description provided for @searchFiltersSortPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get searchFiltersSortPopular;

  /// No description provided for @searchFiltersSortRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get searchFiltersSortRating;

  /// No description provided for @searchFiltersPriceTierTitle.
  ///
  /// In en, this message translates to:
  /// **'Price tier'**
  String get searchFiltersPriceTierTitle;

  /// No description provided for @searchFiltersPriceTierLowest.
  ///
  /// In en, this message translates to:
  /// **'Lowest price'**
  String get searchFiltersPriceTierLowest;

  /// No description provided for @searchFiltersPriceTierMid.
  ///
  /// In en, this message translates to:
  /// **'Mid range'**
  String get searchFiltersPriceTierMid;

  /// No description provided for @searchFiltersPriceTierHigh.
  ///
  /// In en, this message translates to:
  /// **'High end'**
  String get searchFiltersPriceTierHigh;

  /// No description provided for @searchFiltersCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get searchFiltersCategoriesTitle;

  /// No description provided for @searchRecentSearchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get searchRecentSearchesTitle;

  /// No description provided for @searchRecentSearchesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Search for products to see them here.'**
  String get searchRecentSearchesEmptyHint;

  /// No description provided for @searchCollectionsExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get searchCollectionsExplore;

  /// No description provided for @searchCollectionEditorial1Title.
  ///
  /// In en, this message translates to:
  /// **'Editor’s selection'**
  String get searchCollectionEditorial1Title;

  /// No description provided for @searchCollectionEditorial1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Curated finds with premium finishes'**
  String get searchCollectionEditorial1Subtitle;

  /// No description provided for @searchCollectionEditorial2Title.
  ///
  /// In en, this message translates to:
  /// **'Weekend essentials'**
  String get searchCollectionEditorial2Title;

  /// No description provided for @searchCollectionEditorial2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Low effort, high impact staples'**
  String get searchCollectionEditorial2Subtitle;

  /// No description provided for @searchCollectionEditorial3Title.
  ///
  /// In en, this message translates to:
  /// **'Clean tech'**
  String get searchCollectionEditorial3Title;

  /// No description provided for @searchCollectionEditorial3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Minimal + modern picks'**
  String get searchCollectionEditorial3Subtitle;

  /// No description provided for @searchCollectionEditorial4Title.
  ///
  /// In en, this message translates to:
  /// **'Coffee corner'**
  String get searchCollectionEditorial4Title;

  /// No description provided for @searchCollectionEditorial4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Small upgrades that feel expensive'**
  String get searchCollectionEditorial4Subtitle;

  /// No description provided for @searchCollectionEditorial5Title.
  ///
  /// In en, this message translates to:
  /// **'Everyday treats'**
  String get searchCollectionEditorial5Title;

  /// No description provided for @searchCollectionEditorial5Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Snackable favorites'**
  String get searchCollectionEditorial5Subtitle;

  /// No description provided for @searchCollectionEditorial6Title.
  ///
  /// In en, this message translates to:
  /// **'Baby & family'**
  String get searchCollectionEditorial6Title;

  /// No description provided for @searchCollectionEditorial6Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Soft picks, gentle choices'**
  String get searchCollectionEditorial6Subtitle;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get commonSaving;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get commonSignIn;

  /// No description provided for @commonSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get commonSignOut;

  /// No description provided for @commonEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get commonEnabled;

  /// No description provided for @commonDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get commonDisabled;

  /// No description provided for @commonVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get commonVerified;

  /// No description provided for @commonNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get commonNotVerified;

  /// No description provided for @commonSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get commonSeeAll;

  /// No description provided for @languageNameEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageNameEnglish;

  /// No description provided for @languageNameArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageNameArabic;

  /// No description provided for @languageNameFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageNameFrench;

  /// No description provided for @languageNameSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageNameSpanish;

  /// No description provided for @profileThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get profileThemeTitle;

  /// No description provided for @profileThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get profileThemeSystem;

  /// No description provided for @profileThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get profileThemeDark;

  /// No description provided for @profileSignOutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get profileSignOutDialogTitle;

  /// No description provided for @profileSignOutDialogBody.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in anytime.'**
  String get profileSignOutDialogBody;

  /// No description provided for @profileSnackbarSignInToAccess.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access {feature}.'**
  String profileSnackbarSignInToAccess(String feature);

  /// No description provided for @profileNotAvailableYet.
  ///
  /// In en, this message translates to:
  /// **'{feature} is not available yet.'**
  String profileNotAvailableYet(String feature);

  /// No description provided for @profileSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileSectionAccount;

  /// No description provided for @profileSectionMyShopping.
  ///
  /// In en, this message translates to:
  /// **'My Shopping'**
  String get profileSectionMyShopping;

  /// No description provided for @profileSectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSectionSupport;

  /// No description provided for @profileSectionApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get profileSectionApp;

  /// No description provided for @profileSectionAuth.
  ///
  /// In en, this message translates to:
  /// **'Auth'**
  String get profileSectionAuth;

  /// No description provided for @profileAccountDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get profileAccountDetailsTitle;

  /// No description provided for @profileAccountDetailsTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Profile info and verification'**
  String get profileAccountDetailsTileSubtitle;

  /// No description provided for @profileAccountDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your profile & verification'**
  String get profileAccountDetailsSubtitle;

  /// No description provided for @profileAddressesTitle.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get profileAddressesTitle;

  /// No description provided for @profileAddressesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery addresses'**
  String get profileAddressesSubtitle;

  /// No description provided for @profilePaymentMethodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get profilePaymentMethodsTitle;

  /// No description provided for @profilePaymentMethodsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cards and wallets'**
  String get profilePaymentMethodsSubtitle;

  /// No description provided for @profileOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get profileOrdersTitle;

  /// No description provided for @profileOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track purchases and delivery'**
  String get profileOrdersSubtitle;

  /// No description provided for @profileWishlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get profileWishlistTitle;

  /// No description provided for @profileWishlistSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Saved items'**
  String get profileWishlistSubtitle;

  /// No description provided for @profileCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get profileCartTitle;

  /// No description provided for @profileCartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Items ready for checkout'**
  String get profileCartSubtitle;

  /// No description provided for @profileMessagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get profileMessagesTitle;

  /// No description provided for @profileHelpCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get profileHelpCenterTitle;

  /// No description provided for @profileHelpCenterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Answers to common questions'**
  String get profileHelpCenterSubtitle;

  /// No description provided for @profileContactSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get profileContactSupportTitle;

  /// No description provided for @profileContactSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We’re here to help'**
  String get profileContactSupportSubtitle;

  /// No description provided for @profileBuildStatusTelemetryTitle.
  ///
  /// In en, this message translates to:
  /// **'Telemetry'**
  String get profileBuildStatusTelemetryTitle;

  /// No description provided for @profileBuildStatusPersonalizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get profileBuildStatusPersonalizationTitle;

  /// No description provided for @profileBuildStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set by build configuration'**
  String get profileBuildStatusSubtitle;

  /// No description provided for @profileSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock orders sync and messages'**
  String get profileSignInSubtitle;

  /// No description provided for @profileSignOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in anytime'**
  String get profileSignOutSubtitle;

  /// No description provided for @profileFeatureOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get profileFeatureOrders;

  /// No description provided for @profileFeatureMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get profileFeatureMessages;

  /// No description provided for @profileGuestLabel.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profileGuestLabel;

  /// No description provided for @profileMemberLabel.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get profileMemberLabel;

  /// No description provided for @profileGuestInitial.
  ///
  /// In en, this message translates to:
  /// **'G'**
  String get profileGuestInitial;

  /// No description provided for @profileAccountConnected.
  ///
  /// In en, this message translates to:
  /// **'Account connected'**
  String get profileAccountConnected;

  /// No description provided for @profileSignInToUnlockBenefits.
  ///
  /// In en, this message translates to:
  /// **'Sign in to unlock benefits'**
  String get profileSignInToUnlockBenefits;

  /// No description provided for @profileSignInBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync orders and access messages across devices.'**
  String get profileSignInBannerBody;

  /// No description provided for @profileGoldPoints.
  ///
  /// In en, this message translates to:
  /// **'{value} Gold'**
  String profileGoldPoints(int value);

  /// No description provided for @goldTitle.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get goldTitle;

  /// No description provided for @goldInfoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get goldInfoTooltip;

  /// No description provided for @goldTierRulesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tier rules are not available yet.'**
  String get goldTierRulesPlaceholder;

  /// No description provided for @goldRetentionMonthPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'this month'**
  String get goldRetentionMonthPlaceholder;

  /// No description provided for @goldRetentionMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete {remaining} more orders this month to maintain Gold in {month}.'**
  String goldRetentionMessage(int remaining, String month);

  /// No description provided for @goldPointsLabel.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get goldPointsLabel;

  /// No description provided for @goldPointsHistoryCta.
  ///
  /// In en, this message translates to:
  /// **'Points History'**
  String get goldPointsHistoryCta;

  /// No description provided for @goldOrdersCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} order(s)'**
  String goldOrdersCompletedLabel(int count);

  /// No description provided for @goldOrdersOutOfLabel.
  ///
  /// In en, this message translates to:
  /// **'out of {count}'**
  String goldOrdersOutOfLabel(int count);

  /// No description provided for @goldNoticeSimplifiedPoints.
  ///
  /// In en, this message translates to:
  /// **'We’ve simplified the way loyalty points are earned and redeemed. The value stays the same.'**
  String get goldNoticeSimplifiedPoints;

  /// No description provided for @goldDiscountsAndOffersTitle.
  ///
  /// In en, this message translates to:
  /// **'Discounts and offers'**
  String get goldDiscountsAndOffersTitle;

  /// No description provided for @goldRewardsUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Rewards are not available yet.'**
  String get goldRewardsUnavailableBody;

  /// No description provided for @goldPointsHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Points history'**
  String get goldPointsHistoryTitle;

  /// No description provided for @goldPointsHistoryUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Points history is not available yet.'**
  String get goldPointsHistoryUnavailableBody;

  /// No description provided for @goldRewardDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reward details'**
  String get goldRewardDetailsTitle;

  /// No description provided for @goldClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get goldClose;

  /// No description provided for @goldRewardDetailsPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get goldRewardDetailsPlaceholderTitle;

  /// No description provided for @goldRewardDetailsPlaceholderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This reward is not available yet.'**
  String get goldRewardDetailsPlaceholderSubtitle;

  /// No description provided for @goldRewardPointsChip.
  ///
  /// In en, this message translates to:
  /// **'Or {points} Pts'**
  String goldRewardPointsChip(int points);

  /// No description provided for @goldRewardTermsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Terms and eligibility are not available yet.'**
  String get goldRewardTermsPlaceholder;

  /// No description provided for @goldClaimRewardCta.
  ///
  /// In en, this message translates to:
  /// **'Claim reward'**
  String get goldClaimRewardCta;

  /// No description provided for @profileSignInRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get profileSignInRequiredTitle;

  /// No description provided for @profileSignInRequiredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view and update your account details.'**
  String get profileSignInRequiredSubtitle;

  /// No description provided for @profileSectionDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get profileSectionDisplayName;

  /// No description provided for @profileSectionEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileSectionEmail;

  /// No description provided for @profileSectionPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get profileSectionPhoneNumber;

  /// No description provided for @profileFieldNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileFieldNameLabel;

  /// No description provided for @profileFieldNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get profileFieldNameHint;

  /// No description provided for @profileAnonymousEditBlocked.
  ///
  /// In en, this message translates to:
  /// **'Sign in to edit your profile.'**
  String get profileAnonymousEditBlocked;

  /// No description provided for @profileNoEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get profileNoEmail;

  /// No description provided for @profileVerifyEmailCta.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get profileVerifyEmailCta;

  /// No description provided for @profileAnonymousEmailBlocked.
  ///
  /// In en, this message translates to:
  /// **'Sign in to verify your email.'**
  String get profileAnonymousEmailBlocked;

  /// No description provided for @profileAnonymousPhoneBlocked.
  ///
  /// In en, this message translates to:
  /// **'Sign in to verify your phone.'**
  String get profileAnonymousPhoneBlocked;

  /// No description provided for @profileNoPhoneLinked.
  ///
  /// In en, this message translates to:
  /// **'No phone linked'**
  String get profileNoPhoneLinked;

  /// No description provided for @profileFieldPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get profileFieldPhoneLabel;

  /// No description provided for @profileFieldPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+12025550123'**
  String get profileFieldPhoneHint;

  /// No description provided for @profileSendCodeCta.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get profileSendCodeCta;

  /// No description provided for @profileFieldSmsCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'SMS code'**
  String get profileFieldSmsCodeLabel;

  /// No description provided for @profileVerifyPhoneCta.
  ///
  /// In en, this message translates to:
  /// **'Verify phone'**
  String get profileVerifyPhoneCta;

  /// No description provided for @profileSnackbarNameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated'**
  String get profileSnackbarNameUpdated;

  /// No description provided for @profileSnackbarVerificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get profileSnackbarVerificationEmailSent;

  /// No description provided for @profileSnackbarSmsCodeSent.
  ///
  /// In en, this message translates to:
  /// **'SMS code sent'**
  String get profileSnackbarSmsCodeSent;

  /// No description provided for @profileSnackbarPhoneVerified.
  ///
  /// In en, this message translates to:
  /// **'Phone verified'**
  String get profileSnackbarPhoneVerified;

  /// No description provided for @profileSnackbarPleaseSignInToEditName.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to edit your name.'**
  String get profileSnackbarPleaseSignInToEditName;

  /// No description provided for @profileSnackbarNoEmailAttached.
  ///
  /// In en, this message translates to:
  /// **'No email attached to this account.'**
  String get profileSnackbarNoEmailAttached;

  /// No description provided for @profileSnackbarPleaseSignInToVerifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to verify a phone number.'**
  String get profileSnackbarPleaseSignInToVerifyPhone;

  /// No description provided for @profileSnackbarEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a phone number'**
  String get profileSnackbarEnterPhone;

  /// No description provided for @profileSnackbarStartPhoneVerificationFirst.
  ///
  /// In en, this message translates to:
  /// **'Start phone verification first.'**
  String get profileSnackbarStartPhoneVerificationFirst;

  /// No description provided for @profileSnackbarEnterSmsCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the SMS code'**
  String get profileSnackbarEnterSmsCode;

  /// No description provided for @profileVerifiedCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count}/2 verified'**
  String profileVerifiedCountLabel(int count);

  /// No description provided for @profileSectionProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileSectionProfileTitle;

  /// No description provided for @profileSectionProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your account info up to date.'**
  String get profileSectionProfileSubtitle;

  /// No description provided for @profileSectionEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileSectionEmailTitle;

  /// No description provided for @profileSectionEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verify to unlock order syncing.'**
  String get profileSectionEmailSubtitle;

  /// No description provided for @profileSectionPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profileSectionPhoneTitle;

  /// No description provided for @profileSectionPhoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verify for account recovery and delivery updates.'**
  String get profileSectionPhoneSubtitle;

  /// No description provided for @profileResendAvailableInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Resend available in {seconds}s'**
  String profileResendAvailableInSeconds(int seconds);

  /// No description provided for @profileGuestSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest session'**
  String get profileGuestSessionTitle;

  /// No description provided for @profileYourAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get profileYourAccountTitle;

  /// No description provided for @profileAnonymousSyncHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync across devices.'**
  String get profileAnonymousSyncHint;

  /// No description provided for @profileSignedInLabel.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get profileSignedInLabel;

  /// No description provided for @profileAnonymousSyncAndVerifyHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync and verify your account.'**
  String get profileAnonymousSyncAndVerifyHint;

  /// No description provided for @profileDemoBadgeLabel.
  ///
  /// In en, this message translates to:
  /// **'DEMO'**
  String get profileDemoBadgeLabel;

  /// No description provided for @offersTitle.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offersTitle;

  /// No description provided for @offersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Exclusive deals curated for you'**
  String get offersSubtitle;

  /// No description provided for @offersTooltipFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get offersTooltipFilters;

  /// No description provided for @offersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search offers'**
  String get offersSearchHint;

  /// No description provided for @offersLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load offers'**
  String get offersLoadErrorTitle;

  /// No description provided for @offersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No offers found'**
  String get offersEmptyTitle;

  /// No description provided for @offersEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different filter or search.'**
  String get offersEmptySubtitle;

  /// No description provided for @offersQuickAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get offersQuickAll;

  /// No description provided for @offersQuickNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get offersQuickNew;

  /// No description provided for @offersQuickPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get offersQuickPopular;

  /// No description provided for @offersQuickExpiring.
  ///
  /// In en, this message translates to:
  /// **'Expiring'**
  String get offersQuickExpiring;

  /// No description provided for @offersQuickOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get offersQuickOnline;

  /// No description provided for @offersQuickInStore.
  ///
  /// In en, this message translates to:
  /// **'In-store'**
  String get offersQuickInStore;

  /// No description provided for @offersFeaturedDealBadge.
  ///
  /// In en, this message translates to:
  /// **'Featured Deal'**
  String get offersFeaturedDealBadge;

  /// No description provided for @offersFeaturedShopDeal.
  ///
  /// In en, this message translates to:
  /// **'Shop deal'**
  String get offersFeaturedShopDeal;

  /// No description provided for @offersFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get offersFiltersTitle;

  /// No description provided for @offersFiltersClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get offersFiltersClearAll;

  /// No description provided for @offersFiltersSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get offersFiltersSortBy;

  /// No description provided for @offersFiltersPriceTier.
  ///
  /// In en, this message translates to:
  /// **'Price tier'**
  String get offersFiltersPriceTier;

  /// No description provided for @offersFiltersChannel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get offersFiltersChannel;

  /// No description provided for @offersFiltersCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get offersFiltersCategories;

  /// No description provided for @offersFiltersApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get offersFiltersApply;

  /// No description provided for @offersSortRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get offersSortRecommended;

  /// No description provided for @offersSortEndingSoon.
  ///
  /// In en, this message translates to:
  /// **'Ending soon'**
  String get offersSortEndingSoon;

  /// No description provided for @offersSortHighestDiscount.
  ///
  /// In en, this message translates to:
  /// **'Highest discount'**
  String get offersSortHighestDiscount;

  /// No description provided for @offersSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get offersSortNewest;

  /// No description provided for @offersPriceUnder25.
  ///
  /// In en, this message translates to:
  /// **'Under \$25'**
  String get offersPriceUnder25;

  /// No description provided for @offersPriceUnder50.
  ///
  /// In en, this message translates to:
  /// **'Under \$50'**
  String get offersPriceUnder50;

  /// No description provided for @offersPriceHighValue.
  ///
  /// In en, this message translates to:
  /// **'High value'**
  String get offersPriceHighValue;

  /// No description provided for @offersChannelAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get offersChannelAll;

  /// No description provided for @offersChannelOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get offersChannelOnline;

  /// No description provided for @offersChannelInStore.
  ///
  /// In en, this message translates to:
  /// **'In-store'**
  String get offersChannelInStore;

  /// No description provided for @offersCategoryFashion.
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get offersCategoryFashion;

  /// No description provided for @offersCategoryShoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get offersCategoryShoes;

  /// No description provided for @offersCategoryBeauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get offersCategoryBeauty;

  /// No description provided for @offersCategoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get offersCategoryElectronics;

  /// No description provided for @offersCategoryHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get offersCategoryHome;

  /// No description provided for @offersCategoryGrocery.
  ///
  /// In en, this message translates to:
  /// **'Grocery'**
  String get offersCategoryGrocery;

  /// No description provided for @offersCategoryFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get offersCategoryFitness;

  /// No description provided for @offersBadgePercentOff.
  ///
  /// In en, this message translates to:
  /// **'{value}% OFF'**
  String offersBadgePercentOff(String value);

  /// No description provided for @offersBadgeAmountOff.
  ///
  /// In en, this message translates to:
  /// **'\${value} OFF'**
  String offersBadgeAmountOff(String value);

  /// No description provided for @offersBadgeBogo.
  ///
  /// In en, this message translates to:
  /// **'BOGO'**
  String get offersBadgeBogo;

  /// No description provided for @offersBadgeDeal.
  ///
  /// In en, this message translates to:
  /// **'DEAL'**
  String get offersBadgeDeal;

  /// No description provided for @offersPillCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get offersPillCode;

  /// No description provided for @offersPillFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get offersPillFeatured;

  /// No description provided for @offersViewDealCta.
  ///
  /// In en, this message translates to:
  /// **'View deal'**
  String get offersViewDealCta;

  /// No description provided for @offerDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer details'**
  String get offerDetailsTitle;

  /// No description provided for @offerLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load offer'**
  String get offerLoadErrorTitle;

  /// No description provided for @offerNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer not found'**
  String get offerNotFoundTitle;

  /// No description provided for @offerExpiresExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get offerExpiresExpired;

  /// No description provided for @offerExpiresEndsSoon.
  ///
  /// In en, this message translates to:
  /// **'Ends soon'**
  String get offerExpiresEndsSoon;

  /// No description provided for @offerExpiresEndsInDays.
  ///
  /// In en, this message translates to:
  /// **'Ends in {days}d'**
  String offerExpiresEndsInDays(int days);

  /// No description provided for @offerExpiresEndsInHours.
  ///
  /// In en, this message translates to:
  /// **'Ends in {hours}h'**
  String offerExpiresEndsInHours(int hours);

  /// No description provided for @offerPromoCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Promo code copied'**
  String get offerPromoCodeCopied;

  /// No description provided for @offerRedeemTitle.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get offerRedeemTitle;

  /// No description provided for @offerTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get offerTerms;

  /// No description provided for @offerCopyCodeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get offerCopyCodeTooltip;

  /// No description provided for @offerUseCodeAtCheckout.
  ///
  /// In en, this message translates to:
  /// **'Use this code at checkout.'**
  String get offerUseCodeAtCheckout;

  /// No description provided for @offerNoPromoCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'No promo code required.'**
  String get offerNoPromoCodeRequired;

  /// No description provided for @offerShopProductsInThisOffer.
  ///
  /// In en, this message translates to:
  /// **'Shop products in this offer'**
  String get offerShopProductsInThisOffer;

  /// No description provided for @productItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get productItemTitle;

  /// No description provided for @productClearSelectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get productClearSelectionTooltip;

  /// No description provided for @productRemoveFromWishlistTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove from wishlist'**
  String get productRemoveFromWishlistTooltip;

  /// No description provided for @productSaveToWishlistTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save to wishlist'**
  String get productSaveToWishlistTooltip;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get commonRequired;

  /// No description provided for @commonSomethingWentWrongTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonSomethingWentWrongTryAgain;

  /// No description provided for @authWelcomeBackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back — sign in to continue'**
  String get authWelcomeBackSubtitle;

  /// No description provided for @authSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInTitle;

  /// No description provided for @authSignInBody.
  ///
  /// In en, this message translates to:
  /// **'Use your email and password to access your account.'**
  String get authSignInBody;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get authPasswordHint;

  /// No description provided for @authEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get authEmailRequired;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get authPasswordRequired;

  /// No description provided for @authInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get authInvalidEmail;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authPasswordResetUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Password reset is not available yet.'**
  String get authPasswordResetUnavailable;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get authContinueAsGuest;

  /// No description provided for @trustSecure.
  ///
  /// In en, this message translates to:
  /// **'Secure'**
  String get trustSecure;

  /// No description provided for @trustFastDelivery.
  ///
  /// In en, this message translates to:
  /// **'Fast delivery'**
  String get trustFastDelivery;

  /// No description provided for @trustSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get trustSupport;

  /// No description provided for @wishlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlistTitle;

  /// No description provided for @wishlistLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load wishlist'**
  String get wishlistLoadErrorTitle;

  /// No description provided for @wishlistEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved items yet'**
  String get wishlistEmptyTitle;

  /// No description provided for @wishlistEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a product to save it here.'**
  String get wishlistEmptySubtitle;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartTitle;

  /// No description provided for @cartSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get cartSelectAll;

  /// No description provided for @cartDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get cartDeselectAll;

  /// No description provided for @cartLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load your cart'**
  String get cartLoadErrorTitle;

  /// No description provided for @cartSyncNotice.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync this cart across devices. Until then, it stays on this device.'**
  String get cartSyncNotice;

  /// No description provided for @cartYouMightLikeTitle.
  ///
  /// In en, this message translates to:
  /// **'You might like'**
  String get cartYouMightLikeTitle;

  /// No description provided for @cartYouMightLikeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional add-ons. Tap to view details.'**
  String get cartYouMightLikeSubtitle;

  /// No description provided for @cartFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get cartFilterAll;

  /// No description provided for @cartFilterHotDeals.
  ///
  /// In en, this message translates to:
  /// **'Hot Deals'**
  String get cartFilterHotDeals;

  /// No description provided for @cartFilterFrequentFavorites.
  ///
  /// In en, this message translates to:
  /// **'Frequent Favorites'**
  String get cartFilterFrequentFavorites;

  /// No description provided for @cartSelectionAllSelectedMessage.
  ///
  /// In en, this message translates to:
  /// **'All items are selected for checkout. Uncheck items to keep them in your bag.'**
  String get cartSelectionAllSelectedMessage;

  /// No description provided for @cartSelectionSomeSelectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Checkout will include selected items only. Unselected items stay in your bag.'**
  String get cartSelectionSomeSelectedMessage;

  /// No description provided for @cartSelectionNoneSelectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Select items to continue to checkout.'**
  String get cartSelectionNoneSelectedMessage;

  /// No description provided for @cartSubtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get cartSubtotalLabel;

  /// No description provided for @cartSelectedSubtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected subtotal'**
  String get cartSelectedSubtotalLabel;

  /// No description provided for @cartTaxesAndShippingNote.
  ///
  /// In en, this message translates to:
  /// **'Taxes and shipping are calculated at checkout.'**
  String get cartTaxesAndShippingNote;

  /// No description provided for @cartSelectItemsToContinue.
  ///
  /// In en, this message translates to:
  /// **'Select items to continue'**
  String get cartSelectItemsToContinue;

  /// No description provided for @cartProceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to checkout'**
  String get cartProceedToCheckout;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptySubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Add items you want to buy, then review them here before checkout.'**
  String get cartEmptySubtitle1;

  /// No description provided for @cartEmptySubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Add items from any product page, then come back here to review and checkout.'**
  String get cartEmptySubtitle2;

  /// No description provided for @cartContinueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue shopping'**
  String get cartContinueShopping;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @checkoutShippingTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get checkoutShippingTitle;

  /// No description provided for @checkoutShippingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter delivery details to place your order.'**
  String get checkoutShippingSubtitle;

  /// No description provided for @checkoutHintSelectItems.
  ///
  /// In en, this message translates to:
  /// **'Select items in cart to continue'**
  String get checkoutHintSelectItems;

  /// No description provided for @checkoutHintSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to place your order'**
  String get checkoutHintSignIn;

  /// No description provided for @checkoutPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get checkoutPlaceOrder;

  /// No description provided for @checkoutPlacingOrder.
  ///
  /// In en, this message translates to:
  /// **'Placing order…'**
  String get checkoutPlacingOrder;

  /// No description provided for @checkoutDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get checkoutDeliveryTitle;

  /// No description provided for @checkoutFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get checkoutFullNameLabel;

  /// No description provided for @checkoutPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get checkoutPhoneLabel;

  /// No description provided for @checkoutAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get checkoutAddressLabel;

  /// No description provided for @checkoutCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get checkoutCityLabel;

  /// No description provided for @checkoutStateLabel.
  ///
  /// In en, this message translates to:
  /// **'State/Region'**
  String get checkoutStateLabel;

  /// No description provided for @checkoutPostalCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get checkoutPostalCodeLabel;

  /// No description provided for @checkoutCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get checkoutCountryLabel;

  /// No description provided for @checkoutSubtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get checkoutSubtotalLabel;

  /// No description provided for @checkoutShippingFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get checkoutShippingFeeLabel;

  /// No description provided for @checkoutFreeShipping.
  ///
  /// In en, this message translates to:
  /// **'Free shipping'**
  String get checkoutFreeShipping;

  /// No description provided for @checkoutTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get checkoutTotalLabel;

  /// No description provided for @paymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentsTitle;

  /// No description provided for @paymentsChooseMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose a payment method'**
  String get paymentsChooseMethod;

  /// No description provided for @paymentsContinueCta.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get paymentsContinueCta;

  /// No description provided for @paymentsConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm payment'**
  String get paymentsConfirmTitle;

  /// No description provided for @paymentsSelectedMethod.
  ///
  /// In en, this message translates to:
  /// **'You selected: {method}'**
  String paymentsSelectedMethod(String method);

  /// No description provided for @paymentsPayCta.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get paymentsPayCta;

  /// No description provided for @paymentsSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment success'**
  String get paymentsSuccessTitle;

  /// No description provided for @paymentsSuccessHeadline.
  ///
  /// In en, this message translates to:
  /// **'Payment completed'**
  String get paymentsSuccessHeadline;

  /// No description provided for @paymentsOrderIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Order ID: {orderId}'**
  String paymentsOrderIdLabel(String orderId);

  /// No description provided for @paymentsViewOrderCta.
  ///
  /// In en, this message translates to:
  /// **'View order'**
  String get paymentsViewOrderCta;

  /// No description provided for @paymentsViewOrdersCta.
  ///
  /// In en, this message translates to:
  /// **'View orders'**
  String get paymentsViewOrdersCta;

  /// No description provided for @paymentsContinueShoppingCta.
  ///
  /// In en, this message translates to:
  /// **'Continue shopping'**
  String get paymentsContinueShoppingCta;

  /// No description provided for @paymentsFailureTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get paymentsFailureTitle;

  /// No description provided for @paymentsFailureBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t complete your payment. Please try again.'**
  String get paymentsFailureBody;

  /// No description provided for @paymentsSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get paymentsSummaryTitle;

  /// No description provided for @paymentsSummaryItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get paymentsSummaryItems;

  /// No description provided for @paymentsSummarySubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get paymentsSummarySubtotal;

  /// No description provided for @paymentsSummaryShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get paymentsSummaryShipping;

  /// No description provided for @paymentsSummaryFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get paymentsSummaryFree;

  /// No description provided for @paymentsSummaryTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get paymentsSummaryTotal;

  /// No description provided for @paymentsMethodStripe.
  ///
  /// In en, this message translates to:
  /// **'Stripe'**
  String get paymentsMethodStripe;

  /// No description provided for @paymentsMethodStripeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get paymentsMethodStripeSubtitle;

  /// No description provided for @paymentsMethodPaypal.
  ///
  /// In en, this message translates to:
  /// **'PayPal'**
  String get paymentsMethodPaypal;

  /// No description provided for @paymentsMethodPaypalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PayPal checkout'**
  String get paymentsMethodPaypalSubtitle;

  /// No description provided for @checkoutCartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty.'**
  String get checkoutCartEmpty;

  /// No description provided for @checkoutSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue.'**
  String get checkoutSignInRequired;

  /// No description provided for @checkoutInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get checkoutInvalidPhone;

  /// No description provided for @checkoutAddressSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get checkoutAddressSearching;

  /// No description provided for @checkoutAddressSuggestionsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Address suggestions unavailable — you can enter manually.'**
  String get checkoutAddressSuggestionsUnavailable;

  /// No description provided for @checkoutUseManualEntry.
  ///
  /// In en, this message translates to:
  /// **'Use manual entry'**
  String get checkoutUseManualEntry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
