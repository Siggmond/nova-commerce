// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'NovaCommerce';

  @override
  String get brandName => 'Nova';

  @override
  String get navShop => 'Boutique';

  @override
  String get navSearch => 'Recherche';

  @override
  String get navAi => 'Concierge';

  @override
  String get navOffers => 'Offres';

  @override
  String get navCart => 'Panier';

  @override
  String get navAccount => 'Compte';

  @override
  String get aiChatTitle => 'Concierge Nova';

  @override
  String get aiChatSubtitle => 'Trouvez, comparez et achetez plus vite';

  @override
  String get aiChatPrivacyNote =>
      'Les réponses de Nova IA sont générées et peuvent être inexactes. Cette démo ne fournit pas de citations. Vos conversations sont enregistrées localement sur cet appareil et peuvent être effacées à tout moment.';

  @override
  String get aiChatTooltipSessions => 'Sessions';

  @override
  String get aiChatTooltipInfo => 'Infos';

  @override
  String get aiChatTooltipClearChat => 'Effacer la discussion';

  @override
  String get aiChatTooltipAdd => 'Ajouter';

  @override
  String get aiChatTooltipSend => 'Envoyer';

  @override
  String get aiChatHint => 'Budget, style, usage…';

  @override
  String get aiChatSnackbarChatCleared => 'Discussion effacée';

  @override
  String get aiChatSessionsTitle => 'Sessions';

  @override
  String get aiChatNewSessionCta => 'Nouveau';

  @override
  String get aiChatSearchSessionsHint => 'Rechercher des sessions';

  @override
  String get aiChatNewChatTitle => 'Nouvelle discussion';

  @override
  String get aiChatSeedAssistantMessage =>
      'Je peux vous aider à affiner rapidement. Dites-moi votre budget + style + usage, et je vous proposerai une courte sélection d’options.\n\nExemple : \"hoodie noir à moins de \$50, oversize\".';

  @override
  String get aiChatSnackbarCopied => 'Copié';

  @override
  String get aiChatCopyCta => 'Copier';

  @override
  String get aiChatRegenerateCta => 'Régénérer';

  @override
  String get aiChatPickedForYouTitle => 'Sélectionné pour vous';

  @override
  String get aiChatInlineAddCta => 'Ajouter';

  @override
  String get aiChatSnackbarAddedToCart => 'Ajouté au panier';

  @override
  String get aiChatDefaultOption => 'Par défaut';

  @override
  String aiChatLandingGreeting(String name) {
    return 'Salut $name';
  }

  @override
  String get aiChatLandingPrompt =>
      'Que puis-je vous aider à acheter aujourd’hui ?';

  @override
  String get aiChatQuickActionFindDealsTitle =>
      'Trouver des offres aujourd’hui';

  @override
  String get aiChatQuickActionPickOutfitTitle => 'Composer une tenue';

  @override
  String get aiChatQuickActionGiftIdeasTitle => 'Idées cadeaux';

  @override
  String get aiChatQuickActionTrackOrderTitle => 'Suivre ma commande';

  @override
  String aiChatCartItemsCount(int count) {
    return '$count articles';
  }

  @override
  String aiChatWishlistSavedCount(int count) {
    return '$count enregistrés';
  }

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Par défaut du système';

  @override
  String get commonComingSoon => 'Bientôt disponible';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get messagesTabOrder => 'Commande';

  @override
  String get messagesTabActivity => 'Activité';

  @override
  String get messagesTabPromo => 'Promo';

  @override
  String get messagesTabNews => 'Actualités';

  @override
  String get trendsTitle => 'Tendances';

  @override
  String get homePickedForYouTitle => 'Sélectionné pour vous';

  @override
  String get homePickedForYouSubtitle =>
      'Des correspondances rapides selon vos goûts (démo)';

  @override
  String get homePicksLoadErrorTitle => 'Impossible de charger les sélections';

  @override
  String get homeNoPicksTitle => 'Aucune sélection pour le moment';

  @override
  String get homeTrendingNowTitle => 'Tendances du moment';

  @override
  String get homeTrendingNowSubtitle =>
      'Classé selon ce que les gens consultent aujourd’hui';

  @override
  String get homeTrendingNowLoadErrorTitle =>
      'Impossible de charger les tendances';

  @override
  String get homeNoTrendingPicksTitle => 'Aucune tendance pour le moment';

  @override
  String get homeCuratedTrendsTitle => 'Tendances sélectionnées';

  @override
  String get homeCuratedTrendsSubtitle =>
      'Sélections de l’éditeur — stylées, polyvalentes et faciles à associer.';

  @override
  String get homeShopByCategoryTitle => 'Acheter par catégorie';

  @override
  String get homeShopByCategorySubtitle => 'Accès rapides';

  @override
  String get homeBadgeNew => 'Nouveau';

  @override
  String get homeUpdatedToday => 'Mis à jour aujourd’hui';

  @override
  String homeCategoryItemsCount(int count) {
    return '$count articles';
  }

  @override
  String get homeWeekendSaleTitle => 'Soldes du week-end';

  @override
  String get homeWeekendSaleSubtitle =>
      '-15 % supplémentaires sur une sélection d’articles';

  @override
  String get homeWeekendSaleCta => 'Acheter maintenant';

  @override
  String homeDeliverToCity(String city) {
    return 'Livrer à $city';
  }

  @override
  String get homeCityBeirut => 'Beyrouth';

  @override
  String get homeCityTripoli => 'Tripoli';

  @override
  String get homeCitySidon => 'Saïda';

  @override
  String get homeCityTyre => 'Tyr';

  @override
  String get homeCityJounieh => 'Jounieh';

  @override
  String get homeCityByblos => 'Byblos';

  @override
  String get homeCityZahle => 'Zahlé';

  @override
  String get homeCityBaalbek => 'Baalbek';

  @override
  String get homeCityNabatieh => 'Nabatiyé';

  @override
  String get homeCityBatroun => 'Batroun';

  @override
  String get homeCityBsharri => 'Bcharré';

  @override
  String get homeCityAley => 'Aley';

  @override
  String get homeCategoryGroceries => 'Épicerie';

  @override
  String get homeCategoryRestaurants => 'Restaurants';

  @override
  String get homeCategoryPharmacy => 'Pharmacie';

  @override
  String get homeCategoryCoffee => 'Café';

  @override
  String get homeCategoryBakery => 'Boulangerie';

  @override
  String get homeCategoryElectronics => 'Électronique';

  @override
  String get homeCategoryFlowers => 'Fleurs';

  @override
  String get homeCategoryPetSupplies => 'Animaux';

  @override
  String get homeCategoryCosmetics => 'Cosmétiques';

  @override
  String get homeCategorySnacks => 'Snacks';

  @override
  String get homeCategoryDrinks => 'Boissons';

  @override
  String get homeCategoryBaby => 'Bébé';

  @override
  String get homeCuratedTrendsLoadErrorTitle =>
      'Impossible de charger les tendances sélectionnées';

  @override
  String get homeCuratedTrendsEmptyTitle => 'Aucune sélection pour le moment.';

  @override
  String get homeCuratedTrendsIntroTitle => 'La sélection de la semaine';

  @override
  String get homeCuratedTrendsIntroSubtitle =>
      'Une sélection de notre catalogue — choisie pour le style, la polyvalence et la facilité d’assortiment. Ce n’est pas un classement de popularité.';

  @override
  String get homeCuratedTrendsEditorsFavoritesTitle =>
      'Les favoris de l’éditeur';

  @override
  String get homeCuratedTrendsEditorsFavoritesSubtitle =>
      'Des choix solides pour commencer.';

  @override
  String get homeCuratedTrendsWorthALookTitle => 'À voir';

  @override
  String get homeCuratedTrendsWorthALookSubtitle =>
      'Encore quelques choix pour varier.';

  @override
  String get homeCuratedTrendsMorePicksTitle => 'Plus de sélections';

  @override
  String get homeCuratedTrendsMorePicksSubtitle =>
      'Pour aller au-delà de la sélection.';

  @override
  String get homeCuratedTrendsEditorsPickBadge => 'Choix de l’éditeur';

  @override
  String get homeCuratedTrendsHeroPickLabel => 'Le choix phare de la semaine';

  @override
  String get commonBack => 'Retour';

  @override
  String get collectionTitle => 'Collection';

  @override
  String get collectionNotFound => 'Collection introuvable.';

  @override
  String get collectionLoadProductsErrorTitle =>
      'Impossible de charger les produits';

  @override
  String get collectionLoadProductsErrorSubtitle =>
      'Vérifiez votre connexion et réessayez.';

  @override
  String get collectionNoResultsTitle => 'Aucun résultat';

  @override
  String get collectionNoResultsSubtitle =>
      'Essayez un autre mot-clé ou des filtres.';

  @override
  String get searchNoResultsSubtitle => 'Essayez un autre mot-clé.';

  @override
  String get searchFeaturedTitle => 'En vedette';

  @override
  String get searchCollectionsTitle => 'Collections';

  @override
  String get searchCollectionsSubtitle =>
      'Sélections éditoriales pour inspirer votre prochain panier.';

  @override
  String get searchBackToShopTooltip => 'Retour à la boutique';

  @override
  String get searchHintSearchForProducts => 'Rechercher des produits';

  @override
  String get searchHintSearchInCollection => 'Rechercher dans cette collection';

  @override
  String get searchTooltipSearch => 'Rechercher';

  @override
  String get searchTooltipFilters => 'Filtres';

  @override
  String get searchFiltersTitle => 'Filtres';

  @override
  String get searchFiltersClearAll => 'Tout effacer';

  @override
  String get searchFiltersApply => 'Appliquer';

  @override
  String get searchFiltersSortByTitle => 'Trier par';

  @override
  String get searchFiltersSortRecommended => 'Recommandé';

  @override
  String get searchFiltersSortPopular => 'Populaire';

  @override
  String get searchFiltersSortRating => 'Note';

  @override
  String get searchFiltersPriceTierTitle => 'Gamme de prix';

  @override
  String get searchFiltersPriceTierLowest => 'Prix le plus bas';

  @override
  String get searchFiltersPriceTierMid => 'Milieu de gamme';

  @override
  String get searchFiltersPriceTierHigh => 'Haut de gamme';

  @override
  String get searchFiltersCategoriesTitle => 'Catégories';

  @override
  String get searchRecentSearchesTitle => 'Recherches récentes';

  @override
  String get searchRecentSearchesEmptyHint =>
      'Recherchez des produits pour les voir ici.';

  @override
  String get searchCollectionsExplore => 'Explorer';

  @override
  String get searchCollectionEditorial1Title => 'Sélection de l’éditeur';

  @override
  String get searchCollectionEditorial1Subtitle =>
      'Trouvailles sélectionnées avec des finitions premium';

  @override
  String get searchCollectionEditorial2Title => 'Essentiels du week-end';

  @override
  String get searchCollectionEditorial2Subtitle =>
      'Peu d’effort, beaucoup d’impact';

  @override
  String get searchCollectionEditorial3Title => 'Tech épurée';

  @override
  String get searchCollectionEditorial3Subtitle =>
      'Choix minimalistes et modernes';

  @override
  String get searchCollectionEditorial4Title => 'Coin café';

  @override
  String get searchCollectionEditorial4Subtitle =>
      'Petites améliorations qui font premium';

  @override
  String get searchCollectionEditorial5Title => 'Petits plaisirs';

  @override
  String get searchCollectionEditorial5Subtitle => 'Snacks favoris';

  @override
  String get searchCollectionEditorial6Title => 'Bébé & famille';

  @override
  String get searchCollectionEditorial6Subtitle => 'Choix doux et délicats';

  @override
  String get commonClear => 'Effacer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonSaving => 'Enregistrement…';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonRefresh => 'Actualiser';

  @override
  String get commonSignIn => 'Se connecter';

  @override
  String get commonSignOut => 'Se déconnecter';

  @override
  String get commonEnabled => 'Activé';

  @override
  String get commonDisabled => 'Désactivé';

  @override
  String get commonVerified => 'Vérifié';

  @override
  String get commonNotVerified => 'Non vérifié';

  @override
  String get commonSeeAll => 'Voir tout';

  @override
  String get languageNameEnglish => 'English';

  @override
  String get languageNameArabic => 'العربية';

  @override
  String get languageNameFrench => 'Français';

  @override
  String get languageNameSpanish => 'Español';

  @override
  String get profileThemeTitle => 'Thème';

  @override
  String get profileThemeSystem => 'Système';

  @override
  String get profileThemeLight => 'Clair';

  @override
  String get profileThemeDark => 'Sombre';

  @override
  String get profileSignOutDialogTitle => 'Se déconnecter ?';

  @override
  String get profileSignOutDialogBody =>
      'Vous pouvez vous reconnecter à tout moment.';

  @override
  String profileSnackbarSignInToAccess(String feature) {
    return 'Connectez-vous pour accéder à $feature.';
  }

  @override
  String profileNotAvailableYet(String feature) {
    return '$feature n’est pas encore disponible.';
  }

  @override
  String get profileSectionAccount => 'Compte';

  @override
  String get profileSectionMyShopping => 'Mes achats';

  @override
  String get profileSectionSupport => 'Assistance';

  @override
  String get profileSectionApp => 'Application';

  @override
  String get profileSectionAuth => 'Authentification';

  @override
  String get profileAccountDetailsTitle => 'Détails du compte';

  @override
  String get profileAccountDetailsTileSubtitle => 'Profil et vérification';

  @override
  String get profileAccountDetailsSubtitle =>
      'Gérez votre profil et la vérification';

  @override
  String get profileAddressesTitle => 'Adresses';

  @override
  String get profileAddressesSubtitle => 'Adresses de livraison';

  @override
  String get profilePaymentMethodsTitle => 'Moyens de paiement';

  @override
  String get profilePaymentMethodsSubtitle => 'Cartes et portefeuilles';

  @override
  String get profileOrdersTitle => 'Commandes';

  @override
  String get profileOrdersSubtitle => 'Suivre les achats et la livraison';

  @override
  String get profileWishlistTitle => 'Liste de souhaits';

  @override
  String get profileWishlistSubtitle => 'Articles enregistrés';

  @override
  String get profileCartTitle => 'Panier';

  @override
  String get profileCartSubtitle => 'Articles prêts pour le paiement';

  @override
  String get profileMessagesTitle => 'Messages';

  @override
  String get profileHelpCenterTitle => 'Centre d’aide';

  @override
  String get profileHelpCenterSubtitle => 'Réponses aux questions courantes';

  @override
  String get profileContactSupportTitle => 'Contacter l’assistance';

  @override
  String get profileContactSupportSubtitle => 'Nous sommes là pour aider';

  @override
  String get profileBuildStatusTelemetryTitle => 'Télémétrie';

  @override
  String get profileBuildStatusPersonalizationTitle => 'Personnalisation';

  @override
  String get profileBuildStatusSubtitle =>
      'Défini par la configuration de build';

  @override
  String get profileSignInSubtitle =>
      'Débloquez la synchro des commandes et les messages';

  @override
  String get profileSignOutSubtitle =>
      'Vous pouvez vous reconnecter à tout moment';

  @override
  String get profileFeatureOrders => 'Commandes';

  @override
  String get profileFeatureMessages => 'Messages';

  @override
  String get profileGuestLabel => 'Invité';

  @override
  String get profileMemberLabel => 'Membre';

  @override
  String get profileGuestInitial => 'I';

  @override
  String get profileAccountConnected => 'Compte connecté';

  @override
  String get profileSignInToUnlockBenefits =>
      'Connectez-vous pour débloquer des avantages';

  @override
  String get profileSignInBannerBody =>
      'Connectez-vous pour synchroniser les commandes et accéder aux messages sur plusieurs appareils.';

  @override
  String profileGoldPoints(int value) {
    return '$value Gold';
  }

  @override
  String get goldTitle => 'Gold';

  @override
  String get goldInfoTooltip => 'Infos';

  @override
  String get goldTierRulesPlaceholder =>
      'Les règles du niveau ne sont pas encore disponibles.';

  @override
  String get goldRetentionMonthPlaceholder => 'ce mois-ci';

  @override
  String goldRetentionMessage(int remaining, String month) {
    return 'Effectuez encore $remaining commandes ce mois-ci pour conserver le niveau Gold en $month.';
  }

  @override
  String get goldPointsLabel => 'Points';

  @override
  String get goldPointsHistoryCta => 'Historique des points';

  @override
  String goldOrdersCompletedLabel(int count) {
    return '$count commande(s)';
  }

  @override
  String goldOrdersOutOfLabel(int count) {
    return 'sur $count';
  }

  @override
  String get goldNoticeSimplifiedPoints =>
      'Nous avons simplifié la façon dont les points de fidélité sont gagnés et utilisés… la valeur reste la même.';

  @override
  String get goldDiscountsAndOffersTitle => 'Réductions et offres';

  @override
  String get goldRewardsUnavailableBody =>
      'Les récompenses ne sont pas encore disponibles.';

  @override
  String get goldPointsHistoryTitle => 'Historique des points';

  @override
  String get goldPointsHistoryUnavailableBody =>
      'L’historique des points n’est pas encore disponible.';

  @override
  String get goldRewardDetailsTitle => 'Détails de la récompense';

  @override
  String get goldClose => 'Fermer';

  @override
  String get goldRewardDetailsPlaceholderTitle => 'Récompense';

  @override
  String get goldRewardDetailsPlaceholderSubtitle =>
      'Cette récompense n’est pas encore disponible.';

  @override
  String goldRewardPointsChip(int points) {
    return 'Ou $points pts';
  }

  @override
  String get goldRewardTermsPlaceholder =>
      'Les conditions et l’éligibilité ne sont pas encore disponibles.';

  @override
  String get goldClaimRewardCta => 'Utiliser la récompense';

  @override
  String get profileSignInRequiredTitle => 'Connexion requise';

  @override
  String get profileSignInRequiredSubtitle =>
      'Connectez-vous pour consulter et mettre à jour les détails de votre compte.';

  @override
  String get profileSectionDisplayName => 'Nom affiché';

  @override
  String get profileSectionEmail => 'E-mail';

  @override
  String get profileSectionPhoneNumber => 'Numéro de téléphone';

  @override
  String get profileFieldNameLabel => 'Nom';

  @override
  String get profileFieldNameHint => 'Votre nom';

  @override
  String get profileAnonymousEditBlocked =>
      'Connectez-vous pour modifier votre profil.';

  @override
  String get profileNoEmail => 'Aucun e-mail';

  @override
  String get profileVerifyEmailCta => 'Vérifier l’e-mail';

  @override
  String get profileAnonymousEmailBlocked =>
      'Connectez-vous pour vérifier votre e-mail.';

  @override
  String get profileAnonymousPhoneBlocked =>
      'Connectez-vous pour vérifier votre téléphone.';

  @override
  String get profileNoPhoneLinked => 'Aucun téléphone associé';

  @override
  String get profileFieldPhoneLabel => 'Numéro de téléphone';

  @override
  String get profileFieldPhoneHint => '+12025550123';

  @override
  String get profileSendCodeCta => 'Envoyer le code';

  @override
  String get profileFieldSmsCodeLabel => 'Code SMS';

  @override
  String get profileVerifyPhoneCta => 'Vérifier le téléphone';

  @override
  String get profileSnackbarNameUpdated => 'Nom mis à jour';

  @override
  String get profileSnackbarVerificationEmailSent =>
      'E-mail de vérification envoyé';

  @override
  String get profileSnackbarSmsCodeSent => 'Code SMS envoyé';

  @override
  String get profileSnackbarPhoneVerified => 'Téléphone vérifié';

  @override
  String get profileSnackbarPleaseSignInToEditName =>
      'Veuillez vous connecter pour modifier votre nom.';

  @override
  String get profileSnackbarNoEmailAttached =>
      'Aucun e-mail associé à ce compte.';

  @override
  String get profileSnackbarPleaseSignInToVerifyPhone =>
      'Veuillez vous connecter pour vérifier un numéro de téléphone.';

  @override
  String get profileSnackbarEnterPhone => 'Saisissez un numéro de téléphone';

  @override
  String get profileSnackbarStartPhoneVerificationFirst =>
      'Commencez d’abord la vérification du téléphone.';

  @override
  String get profileSnackbarEnterSmsCode => 'Saisissez le code SMS';

  @override
  String profileVerifiedCountLabel(int count) {
    return '$count/2 vérifiés';
  }

  @override
  String get profileSectionProfileTitle => 'Profil';

  @override
  String get profileSectionProfileSubtitle =>
      'Gardez les informations de votre compte à jour.';

  @override
  String get profileSectionEmailTitle => 'E-mail';

  @override
  String get profileSectionEmailSubtitle =>
      'Vérifiez pour activer la synchro des commandes.';

  @override
  String get profileSectionPhoneTitle => 'Téléphone';

  @override
  String get profileSectionPhoneSubtitle =>
      'Vérifiez pour la récupération de compte et les mises à jour de livraison.';

  @override
  String profileResendAvailableInSeconds(int seconds) {
    return 'Renvoi disponible dans ${seconds}s';
  }

  @override
  String get profileGuestSessionTitle => 'Session invité';

  @override
  String get profileYourAccountTitle => 'Votre compte';

  @override
  String get profileAnonymousSyncHint =>
      'Connectez-vous pour synchroniser sur plusieurs appareils.';

  @override
  String get profileSignedInLabel => 'Connecté';

  @override
  String get profileAnonymousSyncAndVerifyHint =>
      'Connectez-vous pour synchroniser et vérifier votre compte.';

  @override
  String get profileDemoBadgeLabel => 'DÉMO';

  @override
  String get offersTitle => 'Offres';

  @override
  String get offersSubtitle =>
      'Des bons plans exclusifs sélectionnés pour vous';

  @override
  String get offersTooltipFilters => 'Filtres';

  @override
  String get offersSearchHint => 'Rechercher des offres';

  @override
  String get offersLoadErrorTitle => 'Impossible de charger les offres';

  @override
  String get offersEmptyTitle => 'Aucune offre trouvée';

  @override
  String get offersEmptySubtitle =>
      'Essayez un autre filtre ou une autre recherche.';

  @override
  String get offersQuickAll => 'Tous';

  @override
  String get offersQuickNew => 'Nouveau';

  @override
  String get offersQuickPopular => 'Populaire';

  @override
  String get offersQuickExpiring => 'Expire bientôt';

  @override
  String get offersQuickOnline => 'En ligne';

  @override
  String get offersQuickInStore => 'En magasin';

  @override
  String get offersFeaturedDealBadge => 'Offre en vedette';

  @override
  String get offersFeaturedShopDeal => 'Voir l’offre';

  @override
  String get offersFiltersTitle => 'Filtres';

  @override
  String get offersFiltersClearAll => 'Tout effacer';

  @override
  String get offersFiltersSortBy => 'Trier par';

  @override
  String get offersFiltersPriceTier => 'Gamme de prix';

  @override
  String get offersFiltersChannel => 'Canal';

  @override
  String get offersFiltersCategories => 'Catégories';

  @override
  String get offersFiltersApply => 'Appliquer';

  @override
  String get offersSortRecommended => 'Recommandé';

  @override
  String get offersSortEndingSoon => 'Se termine bientôt';

  @override
  String get offersSortHighestDiscount => 'Meilleure réduction';

  @override
  String get offersSortNewest => 'Le plus récent';

  @override
  String get offersPriceUnder25 => 'Moins de 25\$';

  @override
  String get offersPriceUnder50 => 'Moins de 50\$';

  @override
  String get offersPriceHighValue => 'Bon rapport qualité/prix';

  @override
  String get offersChannelAll => 'Tous';

  @override
  String get offersChannelOnline => 'En ligne';

  @override
  String get offersChannelInStore => 'En magasin';

  @override
  String get offersCategoryFashion => 'Mode';

  @override
  String get offersCategoryShoes => 'Chaussures';

  @override
  String get offersCategoryBeauty => 'Beauté';

  @override
  String get offersCategoryElectronics => 'Électronique';

  @override
  String get offersCategoryHome => 'Maison';

  @override
  String get offersCategoryGrocery => 'Épicerie';

  @override
  String get offersCategoryFitness => 'Fitness';

  @override
  String offersBadgePercentOff(String value) {
    return '-$value%';
  }

  @override
  String offersBadgeAmountOff(String value) {
    return '-$value\$';
  }

  @override
  String get offersBadgeBogo => '1+1';

  @override
  String get offersBadgeDeal => 'BON PLAN';

  @override
  String get offersPillCode => 'Code';

  @override
  String get offersPillFeatured => 'À la une';

  @override
  String get offersViewDealCta => 'Voir l’offre';

  @override
  String get offerDetailsTitle => 'Détails de l’offre';

  @override
  String get offerLoadErrorTitle => 'Impossible de charger l’offre';

  @override
  String get offerNotFoundTitle => 'Offre introuvable';

  @override
  String get offerExpiresExpired => 'Expiré';

  @override
  String get offerExpiresEndsSoon => 'Se termine bientôt';

  @override
  String offerExpiresEndsInDays(int days) {
    return 'Se termine dans $days j';
  }

  @override
  String offerExpiresEndsInHours(int hours) {
    return 'Se termine dans $hours h';
  }

  @override
  String get offerPromoCodeCopied => 'Code promo copié';

  @override
  String get offerRedeemTitle => 'Utiliser';

  @override
  String get offerTerms => 'Conditions';

  @override
  String get offerCopyCodeTooltip => 'Copier le code';

  @override
  String get offerUseCodeAtCheckout => 'Utilisez ce code au paiement.';

  @override
  String get offerNoPromoCodeRequired => 'Aucun code promo requis.';

  @override
  String get offerShopProductsInThisOffer => 'Voir les produits de cette offre';

  @override
  String get productItemTitle => 'Article';

  @override
  String get productClearSelectionTooltip => 'Effacer la sélection';

  @override
  String get productRemoveFromWishlistTooltip => 'Retirer des favoris';

  @override
  String get productSaveToWishlistTooltip => 'Ajouter aux favoris';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonRequired => 'Requis';

  @override
  String get commonSomethingWentWrongTryAgain =>
      'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get authWelcomeBackSubtitle =>
      'Bon retour — connectez-vous pour continuer';

  @override
  String get authSignInTitle => 'Se connecter';

  @override
  String get authSignInBody =>
      'Utilisez votre e-mail et votre mot de passe pour accéder à votre compte.';

  @override
  String get authEmailLabel => 'E-mail';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authPasswordLabel => 'Mot de passe';

  @override
  String get authPasswordHint => '••••••••';

  @override
  String get authEmailRequired => 'L’e-mail est requis';

  @override
  String get authPasswordRequired => 'Le mot de passe est requis';

  @override
  String get authInvalidEmail => 'Saisissez une adresse e-mail valide';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authPasswordResetUnavailable =>
      'La réinitialisation du mot de passe n’est pas encore disponible.';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authContinueWithGoogle => 'Continuer avec Google';

  @override
  String get authContinueAsGuest => 'Continuer en invité';

  @override
  String get trustSecure => 'Sécurisé';

  @override
  String get trustFastDelivery => 'Livraison rapide';

  @override
  String get trustSupport => 'Support';

  @override
  String get wishlistTitle => 'Favoris';

  @override
  String get wishlistLoadErrorTitle => 'Impossible de charger les favoris';

  @override
  String get wishlistEmptyTitle => 'Aucun article enregistré';

  @override
  String get wishlistEmptySubtitle =>
      'Appuyez sur le cœur d’un produit pour l’enregistrer ici.';

  @override
  String get cartTitle => 'Panier';

  @override
  String get cartSelectAll => 'Tout sélectionner';

  @override
  String get cartDeselectAll => 'Tout désélectionner';

  @override
  String get cartLoadErrorTitle => 'Impossible de charger votre panier';

  @override
  String get cartSyncNotice =>
      'Connectez-vous pour synchroniser ce panier sur vos appareils. Sinon, il reste sur cet appareil.';

  @override
  String get cartYouMightLikeTitle => 'Vous aimerez peut-être';

  @override
  String get cartYouMightLikeSubtitle =>
      'Ajouts optionnels. Appuyez pour voir les détails.';

  @override
  String get cartFilterAll => 'Tous';

  @override
  String get cartFilterHotDeals => 'Bons plans';

  @override
  String get cartFilterFrequentFavorites => 'Favoris fréquents';

  @override
  String get cartSelectionAllSelectedMessage =>
      'Tous les articles sont sélectionnés pour le paiement. Décochez des articles pour les garder dans votre sac.';

  @override
  String get cartSelectionSomeSelectedMessage =>
      'Le paiement inclura uniquement les articles sélectionnés. Les articles non sélectionnés restent dans votre sac.';

  @override
  String get cartSelectionNoneSelectedMessage =>
      'Sélectionnez des articles pour continuer vers le paiement.';

  @override
  String get cartSubtotalLabel => 'Sous-total';

  @override
  String get cartSelectedSubtotalLabel => 'Sous-total sélectionné';

  @override
  String get cartTaxesAndShippingNote =>
      'Les taxes et la livraison sont calculées au paiement.';

  @override
  String get cartSelectItemsToContinue =>
      'Sélectionnez des articles pour continuer';

  @override
  String get cartProceedToCheckout => 'Passer au paiement';

  @override
  String get cartEmptyTitle => 'Votre panier est vide';

  @override
  String get cartEmptySubtitle1 =>
      'Ajoutez des articles que vous souhaitez acheter, puis vérifiez-les ici avant de payer.';

  @override
  String get cartEmptySubtitle2 =>
      'Ajoutez des articles depuis n’importe quelle page produit, puis revenez ici pour les vérifier et payer.';

  @override
  String get cartContinueShopping => 'Continuer vos achats';

  @override
  String get checkoutTitle => 'Paiement';

  @override
  String get checkoutShippingTitle => 'Livraison';

  @override
  String get checkoutShippingSubtitle =>
      'Saisissez les détails de livraison pour passer votre commande.';

  @override
  String get checkoutHintSelectItems =>
      'Sélectionnez des articles du panier pour continuer';

  @override
  String get checkoutHintSignIn => 'Connectez-vous pour passer la commande';

  @override
  String get checkoutPlaceOrder => 'Passer la commande';

  @override
  String get checkoutPlacingOrder => 'Commande en cours…';

  @override
  String get checkoutDeliveryTitle => 'Adresse de livraison';

  @override
  String get checkoutFullNameLabel => 'Nom complet';

  @override
  String get checkoutPhoneLabel => 'Téléphone';

  @override
  String get checkoutAddressLabel => 'Adresse';

  @override
  String get checkoutCityLabel => 'Ville';

  @override
  String get checkoutStateLabel => 'État/Région';

  @override
  String get checkoutPostalCodeLabel => 'Code postal';

  @override
  String get checkoutCountryLabel => 'Pays';

  @override
  String get checkoutSubtotalLabel => 'Sous-total';

  @override
  String get checkoutShippingFeeLabel => 'Livraison';

  @override
  String get checkoutFreeShipping => 'Livraison gratuite';

  @override
  String get checkoutTotalLabel => 'Total';

  @override
  String get paymentsTitle => 'Paiement';

  @override
  String get paymentsChooseMethod => 'Choisissez un moyen de paiement';

  @override
  String get paymentsContinueCta => 'Continuer';

  @override
  String get paymentsConfirmTitle => 'Confirmer le paiement';

  @override
  String paymentsSelectedMethod(String method) {
    return 'Vous avez choisi : $method';
  }

  @override
  String get paymentsPayCta => 'Payer';

  @override
  String get paymentsSuccessTitle => 'Paiement réussi';

  @override
  String get paymentsSuccessHeadline => 'Paiement effectué';

  @override
  String paymentsOrderIdLabel(String orderId) {
    return 'ID de commande : $orderId';
  }

  @override
  String get paymentsViewOrderCta => 'Voir la commande';

  @override
  String get paymentsViewOrdersCta => 'Voir les commandes';

  @override
  String get paymentsContinueShoppingCta => 'Continuer vos achats';

  @override
  String get paymentsFailureTitle => 'Échec du paiement';

  @override
  String get paymentsFailureBody =>
      'Nous n’avons pas pu finaliser votre paiement. Veuillez réessayer.';

  @override
  String get paymentsSummaryTitle => 'Récapitulatif';

  @override
  String get paymentsSummaryItems => 'Articles';

  @override
  String get paymentsSummarySubtotal => 'Sous-total';

  @override
  String get paymentsSummaryShipping => 'Livraison';

  @override
  String get paymentsSummaryFree => 'Gratuit';

  @override
  String get paymentsSummaryTotal => 'Total';

  @override
  String get paymentsMethodStripe => 'Stripe';

  @override
  String get paymentsMethodStripeSubtitle => 'Carte';

  @override
  String get paymentsMethodPaypal => 'PayPal';

  @override
  String get paymentsMethodPaypalSubtitle => 'Paiement PayPal';

  @override
  String get checkoutCartEmpty => 'Votre panier est vide.';

  @override
  String get checkoutSignInRequired =>
      'Veuillez vous connecter pour continuer.';

  @override
  String get checkoutInvalidPhone => 'Numéro de téléphone invalide';

  @override
  String get checkoutAddressSearching => 'Recherche…';

  @override
  String get checkoutAddressSuggestionsUnavailable =>
      'Suggestions d’adresse indisponibles — vous pouvez saisir manuellement.';

  @override
  String get checkoutUseManualEntry => 'Saisie manuelle';
}
