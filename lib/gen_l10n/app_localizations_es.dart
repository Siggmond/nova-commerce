// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'NovaCommerce';

  @override
  String get brandName => 'Nova';

  @override
  String get navShop => 'Tienda';

  @override
  String get navSearch => 'Buscar';

  @override
  String get navAi => 'Conserje';

  @override
  String get navOffers => 'Ofertas';

  @override
  String get navCart => 'Carrito';

  @override
  String get navAccount => 'Cuenta';

  @override
  String get aiChatTitle => 'Conserje Nova';

  @override
  String get aiChatSubtitle => 'Encuentra, compara y compra más rápido';

  @override
  String get aiChatPrivacyNote =>
      'Las respuestas de Nova IA se generan y pueden ser inexactas. Esta demo no proporciona citas. Tus conversaciones se guardan localmente en este dispositivo y se pueden borrar en cualquier momento.';

  @override
  String get aiChatTooltipSessions => 'Sesiones';

  @override
  String get aiChatTooltipInfo => 'Info';

  @override
  String get aiChatTooltipClearChat => 'Borrar chat';

  @override
  String get aiChatTooltipAdd => 'Añadir';

  @override
  String get aiChatTooltipSend => 'Enviar';

  @override
  String get aiChatHint => 'Presupuesto, estilo, uso…';

  @override
  String get aiChatSnackbarChatCleared => 'Chat borrado';

  @override
  String get aiChatSessionsTitle => 'Sesiones';

  @override
  String get aiChatNewSessionCta => 'Nuevo';

  @override
  String get aiChatSearchSessionsHint => 'Buscar sesiones';

  @override
  String get aiChatNewChatTitle => 'Chat nuevo';

  @override
  String get aiChatSeedAssistantMessage =>
      'Puedo ayudarte a acotar rápido. Dime tu presupuesto + estilo + uso, y te sugeriré un conjunto corto de opciones.\n\nEjemplo: \"sudadera negra por menos de \$50, oversize\".';

  @override
  String get aiChatSnackbarCopied => 'Copiado';

  @override
  String get aiChatCopyCta => 'Copiar';

  @override
  String get aiChatRegenerateCta => 'Regenerar';

  @override
  String get aiChatPickedForYouTitle => 'Elegido para ti';

  @override
  String get aiChatInlineAddCta => 'Añadir';

  @override
  String get aiChatSnackbarAddedToCart => 'Añadido al carrito';

  @override
  String get aiChatDefaultOption => 'Predeterminado';

  @override
  String aiChatLandingGreeting(String name) {
    return 'Hola $name';
  }

  @override
  String get aiChatLandingPrompt => '¿En qué puedo ayudarte a comprar hoy?';

  @override
  String get aiChatQuickActionFindDealsTitle => 'Encontrar ofertas de hoy';

  @override
  String get aiChatQuickActionPickOutfitTitle => 'Elegir un outfit';

  @override
  String get aiChatQuickActionGiftIdeasTitle => 'Ideas de regalos';

  @override
  String get aiChatQuickActionTrackOrderTitle => 'Seguir mi pedido';

  @override
  String aiChatCartItemsCount(int count) {
    return '$count artículos';
  }

  @override
  String aiChatWishlistSavedCount(int count) {
    return '$count guardados';
  }

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get commonComingSoon => 'Próximamente';

  @override
  String get messagesTitle => 'Mensajes';

  @override
  String get messagesTabOrder => 'Pedido';

  @override
  String get messagesTabActivity => 'Actividad';

  @override
  String get messagesTabPromo => 'Promo';

  @override
  String get messagesTabNews => 'Noticias';

  @override
  String get trendsTitle => 'Tendencias';

  @override
  String get homePickedForYouTitle => 'Elegido para ti';

  @override
  String get homePickedForYouSubtitle =>
      'Coincidencias rápidas según tu gusto (demo)';

  @override
  String get homePicksLoadErrorTitle =>
      'No se pudieron cargar las recomendaciones';

  @override
  String get homeNoPicksTitle => 'Aún no hay recomendaciones';

  @override
  String get homeTrendingNowTitle => 'Tendencias ahora';

  @override
  String get homeTrendingNowSubtitle =>
      'Ordenado por lo que la gente está tocando hoy';

  @override
  String get homeTrendingNowLoadErrorTitle => 'No se pudo cargar tendencias';

  @override
  String get homeNoTrendingPicksTitle => 'Aún no hay tendencias';

  @override
  String get homeCuratedTrendsTitle => 'Tendencias seleccionadas';

  @override
  String get homeCuratedTrendsSubtitle =>
      'Selecciones del editor — con estilo, versátiles y fáciles de combinar.';

  @override
  String get homeShopByCategoryTitle => 'Comprar por categoría';

  @override
  String get homeShopByCategorySubtitle => 'Accesos rápidos';

  @override
  String get homeBadgeNew => 'Nuevo';

  @override
  String get homeUpdatedToday => 'Actualizado hoy';

  @override
  String homeCategoryItemsCount(int count) {
    return '$count artículos';
  }

  @override
  String get homeWeekendSaleTitle => 'Oferta de fin de semana';

  @override
  String get homeWeekendSaleSubtitle =>
      '15% extra de descuento en artículos seleccionados';

  @override
  String get homeWeekendSaleCta => 'Comprar ahora';

  @override
  String homeDeliverToCity(String city) {
    return 'Entregar en $city';
  }

  @override
  String get homeCityBeirut => 'Beirut';

  @override
  String get homeCityTripoli => 'Trípoli';

  @override
  String get homeCitySidon => 'Sidón';

  @override
  String get homeCityTyre => 'Tiro';

  @override
  String get homeCityJounieh => 'Jounieh';

  @override
  String get homeCityByblos => 'Biblos';

  @override
  String get homeCityZahle => 'Zahlé';

  @override
  String get homeCityBaalbek => 'Baalbek';

  @override
  String get homeCityNabatieh => 'Nabatiye';

  @override
  String get homeCityBatroun => 'Batroun';

  @override
  String get homeCityBsharri => 'Bsharri';

  @override
  String get homeCityAley => 'Aley';

  @override
  String get homeCategoryGroceries => 'Comestibles';

  @override
  String get homeCategoryRestaurants => 'Restaurantes';

  @override
  String get homeCategoryPharmacy => 'Farmacia';

  @override
  String get homeCategoryCoffee => 'Café';

  @override
  String get homeCategoryBakery => 'Panadería';

  @override
  String get homeCategoryElectronics => 'Electrónica';

  @override
  String get homeCategoryFlowers => 'Flores';

  @override
  String get homeCategoryPetSupplies => 'Mascotas';

  @override
  String get homeCategoryCosmetics => 'Cosméticos';

  @override
  String get homeCategorySnacks => 'Snacks';

  @override
  String get homeCategoryDrinks => 'Bebidas';

  @override
  String get homeCategoryBaby => 'Bebé';

  @override
  String get homeCuratedTrendsLoadErrorTitle =>
      'No se pudieron cargar las tendencias seleccionadas';

  @override
  String get homeCuratedTrendsEmptyTitle => 'Aún no hay selecciones curadas.';

  @override
  String get homeCuratedTrendsIntroTitle => 'La selección de la semana';

  @override
  String get homeCuratedTrendsIntroSubtitle =>
      'Una selección de nuestro catálogo — elegida por estilo, versatilidad y facilidad para combinar. No es un ranking de popularidad.';

  @override
  String get homeCuratedTrendsEditorsFavoritesTitle => 'Favoritos del editor';

  @override
  String get homeCuratedTrendsEditorsFavoritesSubtitle =>
      'Buenas opciones para empezar.';

  @override
  String get homeCuratedTrendsWorthALookTitle => 'Vale la pena ver';

  @override
  String get homeCuratedTrendsWorthALookSubtitle =>
      'Más selecciones para variar.';

  @override
  String get homeCuratedTrendsMorePicksTitle => 'Más selecciones';

  @override
  String get homeCuratedTrendsMorePicksSubtitle =>
      'Para explorar más allá de la selección.';

  @override
  String get homeCuratedTrendsEditorsPickBadge => 'Selección del editor';

  @override
  String get homeCuratedTrendsHeroPickLabel =>
      'La elección destacada de la semana';

  @override
  String get commonBack => 'Atrás';

  @override
  String get collectionTitle => 'Colección';

  @override
  String get collectionNotFound => 'Colección no encontrada.';

  @override
  String get collectionLoadProductsErrorTitle =>
      'No se pudieron cargar los productos';

  @override
  String get collectionLoadProductsErrorSubtitle =>
      'Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get collectionNoResultsTitle => 'Sin resultados';

  @override
  String get collectionNoResultsSubtitle =>
      'Prueba con otra palabra clave o filtros.';

  @override
  String get searchNoResultsSubtitle => 'Prueba con otra palabra clave.';

  @override
  String get searchFeaturedTitle => 'Destacado';

  @override
  String get searchCollectionsTitle => 'Colecciones';

  @override
  String get searchCollectionsSubtitle =>
      'Selecciones editoriales para inspirar tu próximo carrito.';

  @override
  String get searchBackToShopTooltip => 'Volver a la tienda';

  @override
  String get searchHintSearchForProducts => 'Buscar productos';

  @override
  String get searchHintSearchInCollection => 'Buscar en esta colección';

  @override
  String get searchTooltipSearch => 'Buscar';

  @override
  String get searchTooltipFilters => 'Filtros';

  @override
  String get searchFiltersTitle => 'Filtros';

  @override
  String get searchFiltersClearAll => 'Borrar todo';

  @override
  String get searchFiltersApply => 'Aplicar';

  @override
  String get searchFiltersSortByTitle => 'Ordenar por';

  @override
  String get searchFiltersSortRecommended => 'Recomendado';

  @override
  String get searchFiltersSortPopular => 'Popular';

  @override
  String get searchFiltersSortRating => 'Valoración';

  @override
  String get searchFiltersPriceTierTitle => 'Rango de precio';

  @override
  String get searchFiltersPriceTierLowest => 'Precio más bajo';

  @override
  String get searchFiltersPriceTierMid => 'Gama media';

  @override
  String get searchFiltersPriceTierHigh => 'Alta gama';

  @override
  String get searchFiltersCategoriesTitle => 'Categorías';

  @override
  String get searchRecentSearchesTitle => 'Búsquedas recientes';

  @override
  String get searchRecentSearchesEmptyHint =>
      'Busca productos para verlos aquí.';

  @override
  String get searchCollectionsExplore => 'Explorar';

  @override
  String get searchCollectionEditorial1Title => 'Selección del editor';

  @override
  String get searchCollectionEditorial1Subtitle =>
      'Hallazgos curados con acabados premium';

  @override
  String get searchCollectionEditorial2Title => 'Esenciales del fin de semana';

  @override
  String get searchCollectionEditorial2Subtitle =>
      'Poco esfuerzo, gran impacto';

  @override
  String get searchCollectionEditorial3Title => 'Tecnología limpia';

  @override
  String get searchCollectionEditorial3Subtitle =>
      'Opciones minimalistas y modernas';

  @override
  String get searchCollectionEditorial4Title => 'Rincón del café';

  @override
  String get searchCollectionEditorial4Subtitle =>
      'Pequeñas mejoras que se sienten premium';

  @override
  String get searchCollectionEditorial5Title => 'Antojos diarios';

  @override
  String get searchCollectionEditorial5Subtitle => 'Snacks favoritos';

  @override
  String get searchCollectionEditorial6Title => 'Bebé y familia';

  @override
  String get searchCollectionEditorial6Subtitle =>
      'Opciones suaves y delicadas';

  @override
  String get commonClear => 'Borrar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonSaving => 'Guardando…';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonRefresh => 'Actualizar';

  @override
  String get commonSignIn => 'Iniciar sesión';

  @override
  String get commonSignOut => 'Cerrar sesión';

  @override
  String get commonEnabled => 'Activado';

  @override
  String get commonDisabled => 'Desactivado';

  @override
  String get commonVerified => 'Verificado';

  @override
  String get commonNotVerified => 'No verificado';

  @override
  String get commonSeeAll => 'Ver todo';

  @override
  String get languageNameEnglish => 'English';

  @override
  String get languageNameArabic => 'العربية';

  @override
  String get languageNameFrench => 'Français';

  @override
  String get languageNameSpanish => 'Español';

  @override
  String get profileThemeTitle => 'Tema';

  @override
  String get profileThemeSystem => 'Sistema';

  @override
  String get profileThemeLight => 'Claro';

  @override
  String get profileThemeDark => 'Oscuro';

  @override
  String get profileSignOutDialogTitle => '¿Cerrar sesión?';

  @override
  String get profileSignOutDialogBody =>
      'Puedes volver a iniciar sesión en cualquier momento.';

  @override
  String profileSnackbarSignInToAccess(String feature) {
    return 'Inicia sesión para acceder a $feature.';
  }

  @override
  String profileNotAvailableYet(String feature) {
    return '$feature aún no está disponible.';
  }

  @override
  String get profileSectionAccount => 'Cuenta';

  @override
  String get profileSectionMyShopping => 'Mis compras';

  @override
  String get profileSectionSupport => 'Soporte';

  @override
  String get profileSectionApp => 'App';

  @override
  String get profileSectionAuth => 'Autenticación';

  @override
  String get profileAccountDetailsTitle => 'Detalles de la cuenta';

  @override
  String get profileAccountDetailsTileSubtitle => 'Perfil y verificación';

  @override
  String get profileAccountDetailsSubtitle =>
      'Gestiona tu perfil y verificación';

  @override
  String get profileAddressesTitle => 'Direcciones';

  @override
  String get profileAddressesSubtitle => 'Direcciones de entrega';

  @override
  String get profilePaymentMethodsTitle => 'Métodos de pago';

  @override
  String get profilePaymentMethodsSubtitle => 'Tarjetas y billeteras';

  @override
  String get profileOrdersTitle => 'Pedidos';

  @override
  String get profileOrdersSubtitle => 'Seguir compras y entrega';

  @override
  String get profileWishlistTitle => 'Lista de deseos';

  @override
  String get profileWishlistSubtitle => 'Artículos guardados';

  @override
  String get profileCartTitle => 'Carrito';

  @override
  String get profileCartSubtitle => 'Artículos listos para pagar';

  @override
  String get profileMessagesTitle => 'Mensajes';

  @override
  String get profileHelpCenterTitle => 'Centro de ayuda';

  @override
  String get profileHelpCenterSubtitle => 'Respuestas a preguntas comunes';

  @override
  String get profileContactSupportTitle => 'Contactar soporte';

  @override
  String get profileContactSupportSubtitle => 'Estamos aquí para ayudar';

  @override
  String get profileBuildStatusTelemetryTitle => 'Telemetría';

  @override
  String get profileBuildStatusPersonalizationTitle => 'Personalización';

  @override
  String get profileBuildStatusSubtitle =>
      'Definido por la configuración de build';

  @override
  String get profileSignInSubtitle =>
      'Desbloquea sincronización de pedidos y mensajes';

  @override
  String get profileSignOutSubtitle =>
      'Puedes volver a iniciar sesión en cualquier momento';

  @override
  String get profileFeatureOrders => 'Pedidos';

  @override
  String get profileFeatureMessages => 'Mensajes';

  @override
  String get profileGuestLabel => 'Invitado';

  @override
  String get profileMemberLabel => 'Miembro';

  @override
  String get profileGuestInitial => 'I';

  @override
  String get profileAccountConnected => 'Cuenta conectada';

  @override
  String get profileSignInToUnlockBenefits =>
      'Inicia sesión para desbloquear beneficios';

  @override
  String get profileSignInBannerBody =>
      'Inicia sesión para sincronizar pedidos y acceder a mensajes en varios dispositivos.';

  @override
  String profileGoldPoints(int value) {
    return '$value Gold';
  }

  @override
  String get goldTitle => 'Gold';

  @override
  String get goldInfoTooltip => 'Info';

  @override
  String get goldTierRulesPlaceholder =>
      'Las reglas del nivel aún no están disponibles.';

  @override
  String get goldRetentionMonthPlaceholder => 'este mes';

  @override
  String goldRetentionMessage(int remaining, String month) {
    return 'Completa $remaining pedidos más este mes para mantener Gold en $month.';
  }

  @override
  String get goldPointsLabel => 'Puntos';

  @override
  String get goldPointsHistoryCta => 'Historial de puntos';

  @override
  String goldOrdersCompletedLabel(int count) {
    return '$count pedido(s)';
  }

  @override
  String goldOrdersOutOfLabel(int count) {
    return 'de $count';
  }

  @override
  String get goldNoticeSimplifiedPoints =>
      'Hemos simplificado la forma de ganar y canjear puntos de lealtad… el valor sigue siendo el mismo.';

  @override
  String get goldDiscountsAndOffersTitle => 'Descuentos y ofertas';

  @override
  String get goldRewardsUnavailableBody =>
      'Las recompensas aún no están disponibles.';

  @override
  String get goldPointsHistoryTitle => 'Historial de puntos';

  @override
  String get goldPointsHistoryUnavailableBody =>
      'El historial de puntos aún no está disponible.';

  @override
  String get goldRewardDetailsTitle => 'Detalles de la recompensa';

  @override
  String get goldClose => 'Cerrar';

  @override
  String get goldRewardDetailsPlaceholderTitle => 'Recompensa';

  @override
  String get goldRewardDetailsPlaceholderSubtitle =>
      'Esta recompensa aún no está disponible.';

  @override
  String goldRewardPointsChip(int points) {
    return 'O $points pts';
  }

  @override
  String get goldRewardTermsPlaceholder =>
      'Los términos y la elegibilidad aún no están disponibles.';

  @override
  String get goldClaimRewardCta => 'Canjear recompensa';

  @override
  String get profileSignInRequiredTitle => 'Se requiere iniciar sesión';

  @override
  String get profileSignInRequiredSubtitle =>
      'Inicia sesión para ver y actualizar los detalles de tu cuenta.';

  @override
  String get profileSectionDisplayName => 'Nombre para mostrar';

  @override
  String get profileSectionEmail => 'Correo';

  @override
  String get profileSectionPhoneNumber => 'Número de teléfono';

  @override
  String get profileFieldNameLabel => 'Nombre';

  @override
  String get profileFieldNameHint => 'Tu nombre';

  @override
  String get profileAnonymousEditBlocked =>
      'Inicia sesión para editar tu perfil.';

  @override
  String get profileNoEmail => 'Sin correo';

  @override
  String get profileVerifyEmailCta => 'Verificar correo';

  @override
  String get profileAnonymousEmailBlocked =>
      'Inicia sesión para verificar tu correo.';

  @override
  String get profileAnonymousPhoneBlocked =>
      'Inicia sesión para verificar tu teléfono.';

  @override
  String get profileNoPhoneLinked => 'Sin teléfono vinculado';

  @override
  String get profileFieldPhoneLabel => 'Número de teléfono';

  @override
  String get profileFieldPhoneHint => '+12025550123';

  @override
  String get profileSendCodeCta => 'Enviar código';

  @override
  String get profileFieldSmsCodeLabel => 'Código SMS';

  @override
  String get profileVerifyPhoneCta => 'Verificar teléfono';

  @override
  String get profileSnackbarNameUpdated => 'Nombre actualizado';

  @override
  String get profileSnackbarVerificationEmailSent =>
      'Correo de verificación enviado';

  @override
  String get profileSnackbarSmsCodeSent => 'Código SMS enviado';

  @override
  String get profileSnackbarPhoneVerified => 'Teléfono verificado';

  @override
  String get profileSnackbarPleaseSignInToEditName =>
      'Inicia sesión para editar tu nombre.';

  @override
  String get profileSnackbarNoEmailAttached =>
      'No hay correo asociado a esta cuenta.';

  @override
  String get profileSnackbarPleaseSignInToVerifyPhone =>
      'Inicia sesión para verificar un número de teléfono.';

  @override
  String get profileSnackbarEnterPhone => 'Ingresa un número de teléfono';

  @override
  String get profileSnackbarStartPhoneVerificationFirst =>
      'Primero inicia la verificación del teléfono.';

  @override
  String get profileSnackbarEnterSmsCode => 'Ingresa el código SMS';

  @override
  String profileVerifiedCountLabel(int count) {
    return '$count/2 verificados';
  }

  @override
  String get profileSectionProfileTitle => 'Perfil';

  @override
  String get profileSectionProfileSubtitle =>
      'Mantén actualizada la información de tu cuenta.';

  @override
  String get profileSectionEmailTitle => 'Correo';

  @override
  String get profileSectionEmailSubtitle =>
      'Verifica para desbloquear la sincronización de pedidos.';

  @override
  String get profileSectionPhoneTitle => 'Teléfono';

  @override
  String get profileSectionPhoneSubtitle =>
      'Verifica para recuperación de cuenta y actualizaciones de entrega.';

  @override
  String profileResendAvailableInSeconds(int seconds) {
    return 'Reenvío disponible en ${seconds}s';
  }

  @override
  String get profileGuestSessionTitle => 'Sesión de invitado';

  @override
  String get profileYourAccountTitle => 'Tu cuenta';

  @override
  String get profileAnonymousSyncHint =>
      'Inicia sesión para sincronizar entre dispositivos.';

  @override
  String get profileSignedInLabel => 'Sesión iniciada';

  @override
  String get profileAnonymousSyncAndVerifyHint =>
      'Inicia sesión para sincronizar y verificar tu cuenta.';

  @override
  String get profileDemoBadgeLabel => 'DEMO';

  @override
  String get offersTitle => 'Ofertas';

  @override
  String get offersSubtitle => 'Ofertas exclusivas seleccionadas para ti';

  @override
  String get offersTooltipFilters => 'Filtros';

  @override
  String get offersSearchHint => 'Buscar ofertas';

  @override
  String get offersLoadErrorTitle => 'No se pudieron cargar las ofertas';

  @override
  String get offersEmptyTitle => 'No se encontraron ofertas';

  @override
  String get offersEmptySubtitle => 'Prueba con otro filtro o búsqueda.';

  @override
  String get offersQuickAll => 'Todo';

  @override
  String get offersQuickNew => 'Nuevo';

  @override
  String get offersQuickPopular => 'Popular';

  @override
  String get offersQuickExpiring => 'Por vencer';

  @override
  String get offersQuickOnline => 'Online';

  @override
  String get offersQuickInStore => 'En tienda';

  @override
  String get offersFeaturedDealBadge => 'Oferta destacada';

  @override
  String get offersFeaturedShopDeal => 'Ver oferta';

  @override
  String get offersFiltersTitle => 'Filtros';

  @override
  String get offersFiltersClearAll => 'Borrar todo';

  @override
  String get offersFiltersSortBy => 'Ordenar por';

  @override
  String get offersFiltersPriceTier => 'Rango de precio';

  @override
  String get offersFiltersChannel => 'Canal';

  @override
  String get offersFiltersCategories => 'Categorías';

  @override
  String get offersFiltersApply => 'Aplicar';

  @override
  String get offersSortRecommended => 'Recomendado';

  @override
  String get offersSortEndingSoon => 'Termina pronto';

  @override
  String get offersSortHighestDiscount => 'Mayor descuento';

  @override
  String get offersSortNewest => 'Más nuevo';

  @override
  String get offersPriceUnder25 => 'Menos de 25\$';

  @override
  String get offersPriceUnder50 => 'Menos de 50\$';

  @override
  String get offersPriceHighValue => 'Gran valor';

  @override
  String get offersChannelAll => 'Todo';

  @override
  String get offersChannelOnline => 'Online';

  @override
  String get offersChannelInStore => 'En tienda';

  @override
  String get offersCategoryFashion => 'Moda';

  @override
  String get offersCategoryShoes => 'Zapatos';

  @override
  String get offersCategoryBeauty => 'Belleza';

  @override
  String get offersCategoryElectronics => 'Electrónica';

  @override
  String get offersCategoryHome => 'Hogar';

  @override
  String get offersCategoryGrocery => 'Supermercado';

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
  String get offersBadgeBogo => '2x1';

  @override
  String get offersBadgeDeal => 'OFERTA';

  @override
  String get offersPillCode => 'Código';

  @override
  String get offersPillFeatured => 'Destacado';

  @override
  String get offersViewDealCta => 'Ver oferta';

  @override
  String get offerDetailsTitle => 'Detalles de la oferta';

  @override
  String get offerLoadErrorTitle => 'No se pudo cargar la oferta';

  @override
  String get offerNotFoundTitle => 'Oferta no encontrada';

  @override
  String get offerExpiresExpired => 'Vencida';

  @override
  String get offerExpiresEndsSoon => 'Termina pronto';

  @override
  String offerExpiresEndsInDays(int days) {
    return 'Termina en $days d';
  }

  @override
  String offerExpiresEndsInHours(int hours) {
    return 'Termina en $hours h';
  }

  @override
  String get offerPromoCodeCopied => 'Código promocional copiado';

  @override
  String get offerRedeemTitle => 'Canjear';

  @override
  String get offerTerms => 'Términos';

  @override
  String get offerCopyCodeTooltip => 'Copiar código';

  @override
  String get offerUseCodeAtCheckout => 'Usa este código al pagar.';

  @override
  String get offerNoPromoCodeRequired => 'No se requiere código promocional.';

  @override
  String get offerShopProductsInThisOffer => 'Ver productos de esta oferta';

  @override
  String get productItemTitle => 'Artículo';

  @override
  String get productClearSelectionTooltip => 'Borrar selección';

  @override
  String get productRemoveFromWishlistTooltip => 'Quitar de la lista de deseos';

  @override
  String get productSaveToWishlistTooltip => 'Guardar en la lista de deseos';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonRequired => 'Obligatorio';

  @override
  String get commonSomethingWentWrongTryAgain =>
      'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get authWelcomeBackSubtitle =>
      'Bienvenido de nuevo — inicia sesión para continuar';

  @override
  String get authSignInTitle => 'Iniciar sesión';

  @override
  String get authSignInBody =>
      'Usa tu correo y contraseña para acceder a tu cuenta.';

  @override
  String get authEmailLabel => 'Correo electrónico';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authPasswordHint => '••••••••';

  @override
  String get authEmailRequired => 'El correo es obligatorio';

  @override
  String get authPasswordRequired => 'La contraseña es obligatoria';

  @override
  String get authInvalidEmail => 'Introduce un correo electrónico válido';

  @override
  String get authForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get authPasswordResetUnavailable =>
      'El restablecimiento de contraseña aún no está disponible.';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authContinueWithGoogle => 'Continuar con Google';

  @override
  String get authContinueAsGuest => 'Continuar como invitado';

  @override
  String get trustSecure => 'Seguro';

  @override
  String get trustFastDelivery => 'Entrega rápida';

  @override
  String get trustSupport => 'Soporte';

  @override
  String get wishlistTitle => 'Favoritos';

  @override
  String get wishlistLoadErrorTitle => 'No se pudo cargar la lista de deseos';

  @override
  String get wishlistEmptyTitle => 'Aún no hay elementos guardados';

  @override
  String get wishlistEmptySubtitle =>
      'Toca el corazón de un producto para guardarlo aquí.';

  @override
  String get cartTitle => 'Carrito';

  @override
  String get cartSelectAll => 'Seleccionar todo';

  @override
  String get cartDeselectAll => 'Deseleccionar todo';

  @override
  String get cartLoadErrorTitle => 'No se pudo cargar tu carrito';

  @override
  String get cartSyncNotice =>
      'Inicia sesión para sincronizar este carrito entre dispositivos. Hasta entonces, se queda en este dispositivo.';

  @override
  String get cartYouMightLikeTitle => 'Te puede gustar';

  @override
  String get cartYouMightLikeSubtitle =>
      'Extras opcionales. Toca para ver detalles.';

  @override
  String get cartFilterAll => 'Todo';

  @override
  String get cartFilterHotDeals => 'Ofertas destacadas';

  @override
  String get cartFilterFrequentFavorites => 'Favoritos frecuentes';

  @override
  String get cartSelectionAllSelectedMessage =>
      'Todos los artículos están seleccionados para el pago. Desmarca artículos para mantenerlos en tu bolsa.';

  @override
  String get cartSelectionSomeSelectedMessage =>
      'El pago incluirá solo los artículos seleccionados. Los no seleccionados se quedan en tu bolsa.';

  @override
  String get cartSelectionNoneSelectedMessage =>
      'Selecciona artículos para continuar al pago.';

  @override
  String get cartSubtotalLabel => 'Subtotal';

  @override
  String get cartSelectedSubtotalLabel => 'Subtotal seleccionado';

  @override
  String get cartTaxesAndShippingNote =>
      'Los impuestos y el envío se calculan al pagar.';

  @override
  String get cartSelectItemsToContinue => 'Selecciona artículos para continuar';

  @override
  String get cartProceedToCheckout => 'Proceder al pago';

  @override
  String get cartEmptyTitle => 'Tu carrito está vacío';

  @override
  String get cartEmptySubtitle1 =>
      'Añade los artículos que quieres comprar y revísalos aquí antes de pagar.';

  @override
  String get cartEmptySubtitle2 =>
      'Añade artículos desde cualquier página de producto y vuelve aquí para revisarlos y pagar.';

  @override
  String get cartContinueShopping => 'Seguir comprando';

  @override
  String get checkoutTitle => 'Pagar';

  @override
  String get checkoutShippingTitle => 'Envío';

  @override
  String get checkoutShippingSubtitle =>
      'Introduce los datos de entrega para realizar tu pedido.';

  @override
  String get checkoutHintSelectItems =>
      'Selecciona artículos del carrito para continuar';

  @override
  String get checkoutHintSignIn => 'Inicia sesión para realizar tu pedido';

  @override
  String get checkoutPlaceOrder => 'Realizar pedido';

  @override
  String get checkoutPlacingOrder => 'Realizando pedido…';

  @override
  String get checkoutDeliveryTitle => 'Entrega';

  @override
  String get checkoutFullNameLabel => 'Nombre completo';

  @override
  String get checkoutPhoneLabel => 'Teléfono';

  @override
  String get checkoutAddressLabel => 'Dirección';

  @override
  String get checkoutCityLabel => 'Ciudad';

  @override
  String get checkoutStateLabel => 'Estado/Región';

  @override
  String get checkoutPostalCodeLabel => 'Código postal';

  @override
  String get checkoutCountryLabel => 'País';

  @override
  String get checkoutSubtotalLabel => 'Subtotal';

  @override
  String get checkoutShippingFeeLabel => 'Envío';

  @override
  String get checkoutFreeShipping => 'Envío gratis';

  @override
  String get checkoutTotalLabel => 'Total';

  @override
  String get paymentsTitle => 'Pago';

  @override
  String get paymentsChooseMethod => 'Elige un método de pago';

  @override
  String get paymentsContinueCta => 'Continuar';

  @override
  String get paymentsConfirmTitle => 'Confirmar pago';

  @override
  String paymentsSelectedMethod(String method) {
    return 'Has elegido: $method';
  }

  @override
  String get paymentsPayCta => 'Pagar';

  @override
  String get paymentsSuccessTitle => 'Pago exitoso';

  @override
  String get paymentsSuccessHeadline => 'Pago completado';

  @override
  String paymentsOrderIdLabel(String orderId) {
    return 'ID del pedido: $orderId';
  }

  @override
  String get paymentsViewOrderCta => 'Ver pedido';

  @override
  String get paymentsViewOrdersCta => 'Ver pedidos';

  @override
  String get paymentsContinueShoppingCta => 'Seguir comprando';

  @override
  String get paymentsFailureTitle => 'Pago fallido';

  @override
  String get paymentsFailureBody =>
      'No pudimos completar tu pago. Inténtalo de nuevo.';

  @override
  String get paymentsSummaryTitle => 'Resumen del pedido';

  @override
  String get paymentsSummaryItems => 'Artículos';

  @override
  String get paymentsSummarySubtotal => 'Subtotal';

  @override
  String get paymentsSummaryShipping => 'Envío';

  @override
  String get paymentsSummaryFree => 'Gratis';

  @override
  String get paymentsSummaryTotal => 'Total';

  @override
  String get paymentsMethodStripe => 'Stripe';

  @override
  String get paymentsMethodStripeSubtitle => 'Tarjeta';

  @override
  String get paymentsMethodPaypal => 'PayPal';

  @override
  String get paymentsMethodPaypalSubtitle => 'Pago con PayPal';

  @override
  String get checkoutCartEmpty => 'Tu carrito está vacío.';

  @override
  String get checkoutSignInRequired => 'Inicia sesión para continuar.';

  @override
  String get checkoutInvalidPhone => 'Número de teléfono no válido';

  @override
  String get checkoutAddressSearching => 'Buscando…';

  @override
  String get checkoutAddressSuggestionsUnavailable =>
      'Sugerencias de dirección no disponibles — puedes ingresar manualmente.';

  @override
  String get checkoutUseManualEntry => 'Usar entrada manual';
}
