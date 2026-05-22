// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NovaCommerce';

  @override
  String get brandName => 'Nova';

  @override
  String get navShop => 'Shop';

  @override
  String get navSearch => 'Search';

  @override
  String get navAi => 'Concierge';

  @override
  String get navOffers => 'Offers';

  @override
  String get navCart => 'Cart';

  @override
  String get navAccount => 'Account';

  @override
  String get aiChatTitle => 'Nova Concierge';

  @override
  String get aiChatSubtitle => 'Find, compare, and buy faster';

  @override
  String get aiChatPrivacyNote =>
      'Nova AI replies are generated and may be inaccurate. This demo does not provide citations. Your conversations are saved locally on this device and can be cleared anytime.';

  @override
  String get aiChatTooltipSessions => 'Sessions';

  @override
  String get aiChatTooltipInfo => 'Info';

  @override
  String get aiChatTooltipClearChat => 'Clear chat';

  @override
  String get aiChatTooltipAdd => 'Add';

  @override
  String get aiChatTooltipSend => 'Send';

  @override
  String get aiChatHint => 'Budget, vibe, use-case…';

  @override
  String get aiChatSnackbarChatCleared => 'Chat cleared';

  @override
  String get aiChatSessionsTitle => 'Sessions';

  @override
  String get aiChatNewSessionCta => 'New';

  @override
  String get aiChatSearchSessionsHint => 'Search sessions';

  @override
  String get aiChatNewChatTitle => 'New chat';

  @override
  String get aiChatSeedAssistantMessage =>
      'I can help you narrow down fast. Tell me your budget + style + use-case, and I’ll suggest a short set of options.\n\nExample: “black hoodie under \$50, oversized”.';

  @override
  String get aiChatSnackbarCopied => 'Copied';

  @override
  String get aiChatCopyCta => 'Copy';

  @override
  String get aiChatRegenerateCta => 'Regenerate';

  @override
  String get aiChatPickedForYouTitle => 'Picked for you';

  @override
  String get aiChatInlineAddCta => 'Add';

  @override
  String get aiChatSnackbarAddedToCart => 'Added to cart';

  @override
  String get aiChatDefaultOption => 'Default';

  @override
  String aiChatLandingGreeting(String name) {
    return 'Hi $name';
  }

  @override
  String get aiChatLandingPrompt => 'What can I help you shop for today?';

  @override
  String get aiChatQuickActionFindDealsTitle => 'Find deals today';

  @override
  String get aiChatQuickActionPickOutfitTitle => 'Pick an outfit';

  @override
  String get aiChatQuickActionGiftIdeasTitle => 'Gift ideas';

  @override
  String get aiChatQuickActionTrackOrderTitle => 'Track my order';

  @override
  String aiChatCartItemsCount(int count) {
    return '$count items';
  }

  @override
  String aiChatWishlistSavedCount(int count) {
    return '$count saved';
  }

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get commonComingSoon => 'Coming soon';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get messagesTabOrder => 'Order';

  @override
  String get messagesTabActivity => 'Activity';

  @override
  String get messagesTabPromo => 'Promo';

  @override
  String get messagesTabNews => 'News';

  @override
  String get trendsTitle => 'Trends';

  @override
  String get homePickedForYouTitle => 'Picked for you';

  @override
  String get homePickedForYouSubtitle =>
      'Quick matches based on your taste (demo)';

  @override
  String get homePicksLoadErrorTitle => 'Could not load picks';

  @override
  String get homeNoPicksTitle => 'No picks yet';

  @override
  String get homeTrendingNowTitle => 'Trending now';

  @override
  String get homeTrendingNowSubtitle =>
      'Ranked by what people are tapping today';

  @override
  String get homeTrendingNowLoadErrorTitle => 'Could not load trending now';

  @override
  String get homeNoTrendingPicksTitle => 'No trending picks yet';

  @override
  String get homeCuratedTrendsTitle => 'Curated trends';

  @override
  String get homeCuratedTrendsSubtitle =>
      'Editor’s picks — styled, versatile, and easy to pair.';

  @override
  String get homeShopByCategoryTitle => 'Shop by category';

  @override
  String get homeShopByCategorySubtitle => 'Quick entry points';

  @override
  String get homeBadgeNew => 'New';

  @override
  String get homeUpdatedToday => 'Updated today';

  @override
  String homeCategoryItemsCount(int count) {
    return '$count items';
  }

  @override
  String get homeWeekendSaleTitle => 'Weekend Sale';

  @override
  String get homeWeekendSaleSubtitle => 'Extra 15% off selected items';

  @override
  String get homeWeekendSaleCta => 'Shop now';

  @override
  String homeDeliverToCity(String city) {
    return 'Deliver to $city';
  }

  @override
  String get homeCityBeirut => 'Beirut';

  @override
  String get homeCityTripoli => 'Tripoli';

  @override
  String get homeCitySidon => 'Sidon';

  @override
  String get homeCityTyre => 'Tyre';

  @override
  String get homeCityJounieh => 'Jounieh';

  @override
  String get homeCityByblos => 'Byblos';

  @override
  String get homeCityZahle => 'Zahle';

  @override
  String get homeCityBaalbek => 'Baalbek';

  @override
  String get homeCityNabatieh => 'Nabatieh';

  @override
  String get homeCityBatroun => 'Batroun';

  @override
  String get homeCityBsharri => 'Bsharri';

  @override
  String get homeCityAley => 'Aley';

  @override
  String get homeCategoryGroceries => 'Groceries';

  @override
  String get homeCategoryRestaurants => 'Restaurants';

  @override
  String get homeCategoryPharmacy => 'Pharmacy';

  @override
  String get homeCategoryCoffee => 'Coffee';

  @override
  String get homeCategoryBakery => 'Bakery';

  @override
  String get homeCategoryElectronics => 'Electronics';

  @override
  String get homeCategoryFlowers => 'Flowers';

  @override
  String get homeCategoryPetSupplies => 'Pet Supplies';

  @override
  String get homeCategoryCosmetics => 'Cosmetics';

  @override
  String get homeCategorySnacks => 'Snacks';

  @override
  String get homeCategoryDrinks => 'Drinks';

  @override
  String get homeCategoryBaby => 'Baby';

  @override
  String get homeCuratedTrendsLoadErrorTitle => 'Could not load curated trends';

  @override
  String get homeCuratedTrendsEmptyTitle => 'No curated picks yet.';

  @override
  String get homeCuratedTrendsIntroTitle => 'This week’s edit';

  @override
  String get homeCuratedTrendsIntroSubtitle =>
      'A curated selection from our catalog — chosen for style, versatility, and easy pairing. Not a popularity leaderboard.';

  @override
  String get homeCuratedTrendsEditorsFavoritesTitle => 'Editor’s favorites';

  @override
  String get homeCuratedTrendsEditorsFavoritesSubtitle =>
      'Strong picks to start with.';

  @override
  String get homeCuratedTrendsWorthALookTitle => 'Worth a look';

  @override
  String get homeCuratedTrendsWorthALookSubtitle =>
      'A few more curated picks for variety.';

  @override
  String get homeCuratedTrendsMorePicksTitle => 'More curated picks';

  @override
  String get homeCuratedTrendsMorePicksSubtitle =>
      'If you want to explore beyond the edit.';

  @override
  String get homeCuratedTrendsEditorsPickBadge => 'Editor’s pick';

  @override
  String get homeCuratedTrendsHeroPickLabel => 'This week’s hero pick';

  @override
  String get commonBack => 'Back';

  @override
  String get collectionTitle => 'Collection';

  @override
  String get collectionNotFound => 'Collection not found.';

  @override
  String get collectionLoadProductsErrorTitle => 'Could not load products';

  @override
  String get collectionLoadProductsErrorSubtitle =>
      'Please check your connection and try again.';

  @override
  String get collectionNoResultsTitle => 'No results';

  @override
  String get collectionNoResultsSubtitle =>
      'Try a different keyword or filters.';

  @override
  String get searchNoResultsSubtitle => 'Try a different keyword.';

  @override
  String get searchFeaturedTitle => 'Featured';

  @override
  String get searchCollectionsTitle => 'Collections';

  @override
  String get searchCollectionsSubtitle =>
      'Editorial picks designed to inspire your next cart.';

  @override
  String get searchBackToShopTooltip => 'Back to Shop';

  @override
  String get searchHintSearchForProducts => 'Search for products';

  @override
  String get searchHintSearchInCollection => 'Search in this collection';

  @override
  String get searchTooltipSearch => 'Search';

  @override
  String get searchTooltipFilters => 'Filters';

  @override
  String get searchFiltersTitle => 'Filters';

  @override
  String get searchFiltersClearAll => 'Clear all';

  @override
  String get searchFiltersApply => 'Apply';

  @override
  String get searchFiltersSortByTitle => 'Sort by';

  @override
  String get searchFiltersSortRecommended => 'Recommended';

  @override
  String get searchFiltersSortPopular => 'Popular';

  @override
  String get searchFiltersSortRating => 'Rating';

  @override
  String get searchFiltersPriceTierTitle => 'Price tier';

  @override
  String get searchFiltersPriceTierLowest => 'Lowest price';

  @override
  String get searchFiltersPriceTierMid => 'Mid range';

  @override
  String get searchFiltersPriceTierHigh => 'High end';

  @override
  String get searchFiltersCategoriesTitle => 'Categories';

  @override
  String get searchRecentSearchesTitle => 'Recent searches';

  @override
  String get searchRecentSearchesEmptyHint =>
      'Search for products to see them here.';

  @override
  String get searchCollectionsExplore => 'Explore';

  @override
  String get searchCollectionEditorial1Title => 'Editor’s selection';

  @override
  String get searchCollectionEditorial1Subtitle =>
      'Curated finds with premium finishes';

  @override
  String get searchCollectionEditorial2Title => 'Weekend essentials';

  @override
  String get searchCollectionEditorial2Subtitle =>
      'Low effort, high impact staples';

  @override
  String get searchCollectionEditorial3Title => 'Clean tech';

  @override
  String get searchCollectionEditorial3Subtitle => 'Minimal + modern picks';

  @override
  String get searchCollectionEditorial4Title => 'Coffee corner';

  @override
  String get searchCollectionEditorial4Subtitle =>
      'Small upgrades that feel expensive';

  @override
  String get searchCollectionEditorial5Title => 'Everyday treats';

  @override
  String get searchCollectionEditorial5Subtitle => 'Snackable favorites';

  @override
  String get searchCollectionEditorial6Title => 'Baby & family';

  @override
  String get searchCollectionEditorial6Subtitle => 'Soft picks, gentle choices';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSaving => 'Saving…';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonSignIn => 'Sign in';

  @override
  String get commonSignOut => 'Sign out';

  @override
  String get commonEnabled => 'Enabled';

  @override
  String get commonDisabled => 'Disabled';

  @override
  String get commonVerified => 'Verified';

  @override
  String get commonNotVerified => 'Not verified';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get languageNameEnglish => 'English';

  @override
  String get languageNameArabic => 'العربية';

  @override
  String get languageNameFrench => 'Français';

  @override
  String get languageNameSpanish => 'Español';

  @override
  String get profileThemeTitle => 'Theme';

  @override
  String get profileThemeSystem => 'System';

  @override
  String get profileThemeLight => 'Light';

  @override
  String get profileThemeDark => 'Dark';

  @override
  String get profileSignOutDialogTitle => 'Sign out?';

  @override
  String get profileSignOutDialogBody => 'You can sign back in anytime.';

  @override
  String profileSnackbarSignInToAccess(String feature) {
    return 'Sign in to access $feature.';
  }

  @override
  String profileNotAvailableYet(String feature) {
    return '$feature is not available yet.';
  }

  @override
  String get profileSectionAccount => 'Account';

  @override
  String get profileSectionMyShopping => 'My Shopping';

  @override
  String get profileSectionSupport => 'Support';

  @override
  String get profileSectionApp => 'App';

  @override
  String get profileSectionAuth => 'Auth';

  @override
  String get profileAccountDetailsTitle => 'Account details';

  @override
  String get profileAccountDetailsTileSubtitle =>
      'Profile info and verification';

  @override
  String get profileAccountDetailsSubtitle =>
      'Manage your profile & verification';

  @override
  String get profileAddressesTitle => 'Addresses';

  @override
  String get profileAddressesSubtitle => 'Delivery addresses';

  @override
  String get profilePaymentMethodsTitle => 'Payment methods';

  @override
  String get profilePaymentMethodsSubtitle => 'Cards and wallets';

  @override
  String get profileOrdersTitle => 'Orders';

  @override
  String get profileOrdersSubtitle => 'Track purchases and delivery';

  @override
  String get profileWishlistTitle => 'Wishlist';

  @override
  String get profileWishlistSubtitle => 'Saved items';

  @override
  String get profileCartTitle => 'Cart';

  @override
  String get profileCartSubtitle => 'Items ready for checkout';

  @override
  String get profileMessagesTitle => 'Messages';

  @override
  String get profileHelpCenterTitle => 'Help Center';

  @override
  String get profileHelpCenterSubtitle => 'Answers to common questions';

  @override
  String get profileContactSupportTitle => 'Contact support';

  @override
  String get profileContactSupportSubtitle => 'We’re here to help';

  @override
  String get profileBuildStatusTelemetryTitle => 'Telemetry';

  @override
  String get profileBuildStatusPersonalizationTitle => 'Personalization';

  @override
  String get profileBuildStatusSubtitle => 'Set by build configuration';

  @override
  String get profileSignInSubtitle => 'Unlock orders sync and messages';

  @override
  String get profileSignOutSubtitle => 'You can sign back in anytime';

  @override
  String get profileFeatureOrders => 'Orders';

  @override
  String get profileFeatureMessages => 'Messages';

  @override
  String get profileGuestLabel => 'Guest';

  @override
  String get profileMemberLabel => 'Member';

  @override
  String get profileGuestInitial => 'G';

  @override
  String get profileAccountConnected => 'Account connected';

  @override
  String get profileSignInToUnlockBenefits => 'Sign in to unlock benefits';

  @override
  String get profileSignInBannerBody =>
      'Sign in to sync orders and access messages across devices.';

  @override
  String profileGoldPoints(int value) {
    return '$value Gold';
  }

  @override
  String get goldTitle => 'Gold';

  @override
  String get goldInfoTooltip => 'Info';

  @override
  String get goldTierRulesPlaceholder => 'Tier rules are not available yet.';

  @override
  String get goldRetentionMonthPlaceholder => 'this month';

  @override
  String goldRetentionMessage(int remaining, String month) {
    return 'Complete $remaining more orders this month to maintain Gold in $month.';
  }

  @override
  String get goldPointsLabel => 'Points';

  @override
  String get goldPointsHistoryCta => 'Points History';

  @override
  String goldOrdersCompletedLabel(int count) {
    return '$count order(s)';
  }

  @override
  String goldOrdersOutOfLabel(int count) {
    return 'out of $count';
  }

  @override
  String get goldNoticeSimplifiedPoints =>
      'We’ve simplified the way loyalty points are earned and redeemed. The value stays the same.';

  @override
  String get goldDiscountsAndOffersTitle => 'Discounts and offers';

  @override
  String get goldRewardsUnavailableBody => 'Rewards are not available yet.';

  @override
  String get goldPointsHistoryTitle => 'Points history';

  @override
  String get goldPointsHistoryUnavailableBody =>
      'Points history is not available yet.';

  @override
  String get goldRewardDetailsTitle => 'Reward details';

  @override
  String get goldClose => 'Close';

  @override
  String get goldRewardDetailsPlaceholderTitle => 'Reward';

  @override
  String get goldRewardDetailsPlaceholderSubtitle =>
      'This reward is not available yet.';

  @override
  String goldRewardPointsChip(int points) {
    return 'Or $points Pts';
  }

  @override
  String get goldRewardTermsPlaceholder =>
      'Terms and eligibility are not available yet.';

  @override
  String get goldClaimRewardCta => 'Claim reward';

  @override
  String get profileSignInRequiredTitle => 'Sign in required';

  @override
  String get profileSignInRequiredSubtitle =>
      'Sign in to view and update your account details.';

  @override
  String get profileSectionDisplayName => 'Display name';

  @override
  String get profileSectionEmail => 'Email';

  @override
  String get profileSectionPhoneNumber => 'Phone number';

  @override
  String get profileFieldNameLabel => 'Name';

  @override
  String get profileFieldNameHint => 'Your name';

  @override
  String get profileAnonymousEditBlocked => 'Sign in to edit your profile.';

  @override
  String get profileNoEmail => 'No email';

  @override
  String get profileVerifyEmailCta => 'Verify email';

  @override
  String get profileAnonymousEmailBlocked => 'Sign in to verify your email.';

  @override
  String get profileAnonymousPhoneBlocked => 'Sign in to verify your phone.';

  @override
  String get profileNoPhoneLinked => 'No phone linked';

  @override
  String get profileFieldPhoneLabel => 'Phone number';

  @override
  String get profileFieldPhoneHint => '+12025550123';

  @override
  String get profileSendCodeCta => 'Send code';

  @override
  String get profileFieldSmsCodeLabel => 'SMS code';

  @override
  String get profileVerifyPhoneCta => 'Verify phone';

  @override
  String get profileSnackbarNameUpdated => 'Name updated';

  @override
  String get profileSnackbarVerificationEmailSent => 'Verification email sent';

  @override
  String get profileSnackbarSmsCodeSent => 'SMS code sent';

  @override
  String get profileSnackbarPhoneVerified => 'Phone verified';

  @override
  String get profileSnackbarPleaseSignInToEditName =>
      'Please sign in to edit your name.';

  @override
  String get profileSnackbarNoEmailAttached =>
      'No email attached to this account.';

  @override
  String get profileSnackbarPleaseSignInToVerifyPhone =>
      'Please sign in to verify a phone number.';

  @override
  String get profileSnackbarEnterPhone => 'Enter a phone number';

  @override
  String get profileSnackbarStartPhoneVerificationFirst =>
      'Start phone verification first.';

  @override
  String get profileSnackbarEnterSmsCode => 'Enter the SMS code';

  @override
  String profileVerifiedCountLabel(int count) {
    return '$count/2 verified';
  }

  @override
  String get profileSectionProfileTitle => 'Profile';

  @override
  String get profileSectionProfileSubtitle =>
      'Keep your account info up to date.';

  @override
  String get profileSectionEmailTitle => 'Email';

  @override
  String get profileSectionEmailSubtitle => 'Verify to unlock order syncing.';

  @override
  String get profileSectionPhoneTitle => 'Phone';

  @override
  String get profileSectionPhoneSubtitle =>
      'Verify for account recovery and delivery updates.';

  @override
  String profileResendAvailableInSeconds(int seconds) {
    return 'Resend available in ${seconds}s';
  }

  @override
  String get profileGuestSessionTitle => 'Guest session';

  @override
  String get profileYourAccountTitle => 'Your account';

  @override
  String get profileAnonymousSyncHint => 'Sign in to sync across devices.';

  @override
  String get profileSignedInLabel => 'Signed in';

  @override
  String get profileAnonymousSyncAndVerifyHint =>
      'Sign in to sync and verify your account.';

  @override
  String get profileDemoBadgeLabel => 'DEMO';

  @override
  String get offersTitle => 'Offers';

  @override
  String get offersSubtitle => 'Exclusive deals curated for you';

  @override
  String get offersTooltipFilters => 'Filters';

  @override
  String get offersSearchHint => 'Search offers';

  @override
  String get offersLoadErrorTitle => 'Could not load offers';

  @override
  String get offersEmptyTitle => 'No offers found';

  @override
  String get offersEmptySubtitle => 'Try a different filter or search.';

  @override
  String get offersQuickAll => 'All';

  @override
  String get offersQuickNew => 'New';

  @override
  String get offersQuickPopular => 'Popular';

  @override
  String get offersQuickExpiring => 'Expiring';

  @override
  String get offersQuickOnline => 'Online';

  @override
  String get offersQuickInStore => 'In-store';

  @override
  String get offersFeaturedDealBadge => 'Featured Deal';

  @override
  String get offersFeaturedShopDeal => 'Shop deal';

  @override
  String get offersFiltersTitle => 'Filters';

  @override
  String get offersFiltersClearAll => 'Clear all';

  @override
  String get offersFiltersSortBy => 'Sort by';

  @override
  String get offersFiltersPriceTier => 'Price tier';

  @override
  String get offersFiltersChannel => 'Channel';

  @override
  String get offersFiltersCategories => 'Categories';

  @override
  String get offersFiltersApply => 'Apply';

  @override
  String get offersSortRecommended => 'Recommended';

  @override
  String get offersSortEndingSoon => 'Ending soon';

  @override
  String get offersSortHighestDiscount => 'Highest discount';

  @override
  String get offersSortNewest => 'Newest';

  @override
  String get offersPriceUnder25 => 'Under \$25';

  @override
  String get offersPriceUnder50 => 'Under \$50';

  @override
  String get offersPriceHighValue => 'High value';

  @override
  String get offersChannelAll => 'All';

  @override
  String get offersChannelOnline => 'Online';

  @override
  String get offersChannelInStore => 'In-store';

  @override
  String get offersCategoryFashion => 'Fashion';

  @override
  String get offersCategoryShoes => 'Shoes';

  @override
  String get offersCategoryBeauty => 'Beauty';

  @override
  String get offersCategoryElectronics => 'Electronics';

  @override
  String get offersCategoryHome => 'Home';

  @override
  String get offersCategoryGrocery => 'Grocery';

  @override
  String get offersCategoryFitness => 'Fitness';

  @override
  String offersBadgePercentOff(String value) {
    return '$value% OFF';
  }

  @override
  String offersBadgeAmountOff(String value) {
    return '\$$value OFF';
  }

  @override
  String get offersBadgeBogo => 'BOGO';

  @override
  String get offersBadgeDeal => 'DEAL';

  @override
  String get offersPillCode => 'Code';

  @override
  String get offersPillFeatured => 'Featured';

  @override
  String get offersViewDealCta => 'View deal';

  @override
  String get offerDetailsTitle => 'Offer details';

  @override
  String get offerLoadErrorTitle => 'Could not load offer';

  @override
  String get offerNotFoundTitle => 'Offer not found';

  @override
  String get offerExpiresExpired => 'Expired';

  @override
  String get offerExpiresEndsSoon => 'Ends soon';

  @override
  String offerExpiresEndsInDays(int days) {
    return 'Ends in ${days}d';
  }

  @override
  String offerExpiresEndsInHours(int hours) {
    return 'Ends in ${hours}h';
  }

  @override
  String get offerPromoCodeCopied => 'Promo code copied';

  @override
  String get offerRedeemTitle => 'Redeem';

  @override
  String get offerTerms => 'Terms';

  @override
  String get offerCopyCodeTooltip => 'Copy code';

  @override
  String get offerUseCodeAtCheckout => 'Use this code at checkout.';

  @override
  String get offerNoPromoCodeRequired => 'No promo code required.';

  @override
  String get offerShopProductsInThisOffer => 'Shop products in this offer';

  @override
  String get productItemTitle => 'Item';

  @override
  String get productClearSelectionTooltip => 'Clear selection';

  @override
  String get productRemoveFromWishlistTooltip => 'Remove from wishlist';

  @override
  String get productSaveToWishlistTooltip => 'Save to wishlist';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonRequired => 'Required';

  @override
  String get commonSomethingWentWrongTryAgain =>
      'Something went wrong. Please try again.';

  @override
  String get authWelcomeBackSubtitle => 'Welcome back — sign in to continue';

  @override
  String get authSignInTitle => 'Sign in';

  @override
  String get authSignInBody =>
      'Use your email and password to access your account.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => '••••••••';

  @override
  String get authEmailRequired => 'Email is required';

  @override
  String get authPasswordRequired => 'Password is required';

  @override
  String get authInvalidEmail => 'Enter a valid email address';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authPasswordResetUnavailable =>
      'Password reset is not available yet.';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authContinueAsGuest => 'Continue as guest';

  @override
  String get trustSecure => 'Secure';

  @override
  String get trustFastDelivery => 'Fast delivery';

  @override
  String get trustSupport => 'Support';

  @override
  String get wishlistTitle => 'Wishlist';

  @override
  String get wishlistLoadErrorTitle => 'Could not load wishlist';

  @override
  String get wishlistEmptyTitle => 'No saved items yet';

  @override
  String get wishlistEmptySubtitle =>
      'Tap the heart on a product to save it here.';

  @override
  String get cartTitle => 'Cart';

  @override
  String get cartSelectAll => 'Select all';

  @override
  String get cartDeselectAll => 'Deselect all';

  @override
  String get cartLoadErrorTitle => 'Could not load your cart';

  @override
  String get cartSyncNotice =>
      'Sign in to sync this cart across devices. Until then, it stays on this device.';

  @override
  String get cartYouMightLikeTitle => 'You might like';

  @override
  String get cartYouMightLikeSubtitle =>
      'Optional add-ons. Tap to view details.';

  @override
  String get cartFilterAll => 'All';

  @override
  String get cartFilterHotDeals => 'Hot Deals';

  @override
  String get cartFilterFrequentFavorites => 'Frequent Favorites';

  @override
  String get cartSelectionAllSelectedMessage =>
      'All items are selected for checkout. Uncheck items to keep them in your bag.';

  @override
  String get cartSelectionSomeSelectedMessage =>
      'Checkout will include selected items only. Unselected items stay in your bag.';

  @override
  String get cartSelectionNoneSelectedMessage =>
      'Select items to continue to checkout.';

  @override
  String get cartSubtotalLabel => 'Subtotal';

  @override
  String get cartSelectedSubtotalLabel => 'Selected subtotal';

  @override
  String get cartTaxesAndShippingNote =>
      'Taxes and shipping are calculated at checkout.';

  @override
  String get cartSelectItemsToContinue => 'Select items to continue';

  @override
  String get cartProceedToCheckout => 'Proceed to checkout';

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartEmptySubtitle1 =>
      'Add items you want to buy, then review them here before checkout.';

  @override
  String get cartEmptySubtitle2 =>
      'Add items from any product page, then come back here to review and checkout.';

  @override
  String get cartContinueShopping => 'Continue shopping';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutShippingTitle => 'Shipping';

  @override
  String get checkoutShippingSubtitle =>
      'Enter delivery details to place your order.';

  @override
  String get checkoutHintSelectItems => 'Select items in cart to continue';

  @override
  String get checkoutHintSignIn => 'Sign in to place your order';

  @override
  String get checkoutPlaceOrder => 'Place order';

  @override
  String get checkoutPlacingOrder => 'Placing order…';

  @override
  String get checkoutDeliveryTitle => 'Delivery';

  @override
  String get checkoutFullNameLabel => 'Full name';

  @override
  String get checkoutPhoneLabel => 'Phone';

  @override
  String get checkoutAddressLabel => 'Address';

  @override
  String get checkoutCityLabel => 'City';

  @override
  String get checkoutStateLabel => 'State/Region';

  @override
  String get checkoutPostalCodeLabel => 'Postal code';

  @override
  String get checkoutCountryLabel => 'Country';

  @override
  String get checkoutSubtotalLabel => 'Subtotal';

  @override
  String get checkoutShippingFeeLabel => 'Shipping';

  @override
  String get checkoutFreeShipping => 'Free shipping';

  @override
  String get checkoutTotalLabel => 'Total';

  @override
  String get paymentsTitle => 'Payment';

  @override
  String get paymentsChooseMethod => 'Choose a payment method';

  @override
  String get paymentsContinueCta => 'Continue';

  @override
  String get paymentsConfirmTitle => 'Confirm payment';

  @override
  String paymentsSelectedMethod(String method) {
    return 'You selected: $method';
  }

  @override
  String get paymentsPayCta => 'Pay';

  @override
  String get paymentsSuccessTitle => 'Payment success';

  @override
  String get paymentsSuccessHeadline => 'Payment completed';

  @override
  String paymentsOrderIdLabel(String orderId) {
    return 'Order ID: $orderId';
  }

  @override
  String get paymentsViewOrderCta => 'View order';

  @override
  String get paymentsViewOrdersCta => 'View orders';

  @override
  String get paymentsContinueShoppingCta => 'Continue shopping';

  @override
  String get paymentsFailureTitle => 'Payment failed';

  @override
  String get paymentsFailureBody =>
      'We couldn’t complete your payment. Please try again.';

  @override
  String get paymentsSummaryTitle => 'Order summary';

  @override
  String get paymentsSummaryItems => 'Items';

  @override
  String get paymentsSummarySubtotal => 'Subtotal';

  @override
  String get paymentsSummaryShipping => 'Shipping';

  @override
  String get paymentsSummaryFree => 'Free';

  @override
  String get paymentsSummaryTotal => 'Total';

  @override
  String get paymentsMethodStripe => 'Stripe';

  @override
  String get paymentsMethodStripeSubtitle => 'Card';

  @override
  String get paymentsMethodPaypal => 'PayPal';

  @override
  String get paymentsMethodPaypalSubtitle => 'PayPal checkout';

  @override
  String get checkoutCartEmpty => 'Your cart is empty.';

  @override
  String get checkoutSignInRequired => 'Please sign in to continue.';

  @override
  String get checkoutInvalidPhone => 'Invalid phone number';

  @override
  String get checkoutAddressSearching => 'Searching…';

  @override
  String get checkoutAddressSuggestionsUnavailable =>
      'Address suggestions unavailable — you can enter manually.';

  @override
  String get checkoutUseManualEntry => 'Use manual entry';
}
