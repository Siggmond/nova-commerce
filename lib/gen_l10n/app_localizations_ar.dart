// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'نوفا كوميرس';

  @override
  String get brandName => 'نوفا';

  @override
  String get navShop => 'تسوق';

  @override
  String get navSearch => 'بحث';

  @override
  String get navAi => 'مساعد';

  @override
  String get navOffers => 'عروض';

  @override
  String get navCart => 'السلة';

  @override
  String get navAccount => 'الحساب';

  @override
  String get aiChatTitle => 'مساعد نوفا';

  @override
  String get aiChatSubtitle => 'اعثر وقارن واشترِ بشكل أسرع';

  @override
  String get aiChatPrivacyNote =>
      'ردود نوفا بالذكاء الاصطناعي مُولَّدة وقد تكون غير دقيقة. هذا العرض التجريبي لا يوفر مصادر. يتم حفظ محادثاتك محليًا على هذا الجهاز ويمكنك مسحها في أي وقت.';

  @override
  String get aiChatTooltipSessions => 'الجلسات';

  @override
  String get aiChatTooltipInfo => 'معلومات';

  @override
  String get aiChatTooltipClearChat => 'مسح المحادثة';

  @override
  String get aiChatTooltipAdd => 'إضافة';

  @override
  String get aiChatTooltipSend => 'إرسال';

  @override
  String get aiChatHint => 'الميزانية، الذوق، الاستخدام…';

  @override
  String get aiChatSnackbarChatCleared => 'تم مسح المحادثة';

  @override
  String get aiChatSessionsTitle => 'الجلسات';

  @override
  String get aiChatNewSessionCta => 'جديد';

  @override
  String get aiChatSearchSessionsHint => 'ابحث في الجلسات';

  @override
  String get aiChatNewChatTitle => 'محادثة جديدة';

  @override
  String get aiChatSeedAssistantMessage =>
      'يمكنني مساعدتك على التضييق بسرعة. أخبرني بميزانيتك + أسلوبك + الاستخدام، وسأقترح مجموعة قصيرة من الخيارات.\n\nمثال: \"هودي أسود أقل من \$50، واسع\".';

  @override
  String get aiChatSnackbarCopied => 'تم النسخ';

  @override
  String get aiChatCopyCta => 'نسخ';

  @override
  String get aiChatRegenerateCta => 'إعادة توليد';

  @override
  String get aiChatPickedForYouTitle => 'مختار لك';

  @override
  String get aiChatInlineAddCta => 'إضافة';

  @override
  String get aiChatSnackbarAddedToCart => 'تمت الإضافة إلى السلة';

  @override
  String get aiChatDefaultOption => 'افتراضي';

  @override
  String aiChatLandingGreeting(String name) {
    return 'مرحبًا $name';
  }

  @override
  String get aiChatLandingPrompt => 'بماذا يمكنني مساعدتك في التسوق اليوم؟';

  @override
  String get aiChatQuickActionFindDealsTitle => 'اعثر على عروض اليوم';

  @override
  String get aiChatQuickActionPickOutfitTitle => 'اختر إطلالة';

  @override
  String get aiChatQuickActionGiftIdeasTitle => 'أفكار هدايا';

  @override
  String get aiChatQuickActionTrackOrderTitle => 'تتبع طلبي';

  @override
  String aiChatCartItemsCount(int count) {
    return '$count عناصر';
  }

  @override
  String aiChatWishlistSavedCount(int count) {
    return '$count محفوظ';
  }

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'افتراضي النظام';

  @override
  String get commonComingSoon => 'قريبًا';

  @override
  String get messagesTitle => 'الرسائل';

  @override
  String get messagesTabOrder => 'الطلبات';

  @override
  String get messagesTabActivity => 'النشاط';

  @override
  String get messagesTabPromo => 'عروض';

  @override
  String get messagesTabNews => 'أخبار';

  @override
  String get trendsTitle => 'الترند';

  @override
  String get homePickedForYouTitle => 'مختار لك';

  @override
  String get homePickedForYouSubtitle =>
      'اقتراحات سريعة بناءً على ذوقك (تجريبي)';

  @override
  String get homePicksLoadErrorTitle => 'تعذر تحميل الاختيارات';

  @override
  String get homeNoPicksTitle => 'لا توجد اختيارات بعد';

  @override
  String get homeTrendingNowTitle => 'الأكثر رواجًا الآن';

  @override
  String get homeTrendingNowSubtitle => 'مرتبة حسب ما ينقر عليه الناس اليوم';

  @override
  String get homeTrendingNowLoadErrorTitle => 'تعذر تحميل الأكثر رواجًا الآن';

  @override
  String get homeNoTrendingPicksTitle => 'لا توجد اختيارات رائجة بعد';

  @override
  String get homeCuratedTrendsTitle => 'اتجاهات مختارة';

  @override
  String get homeCuratedTrendsSubtitle =>
      'اختيارات المحرر — أنيقة ومتعددة الاستخدام وسهلة التنسيق.';

  @override
  String get homeShopByCategoryTitle => 'تسوق حسب الفئة';

  @override
  String get homeShopByCategorySubtitle => 'روابط سريعة';

  @override
  String get homeBadgeNew => 'جديد';

  @override
  String get homeUpdatedToday => 'تم التحديث اليوم';

  @override
  String homeCategoryItemsCount(int count) {
    return '$count عنصر';
  }

  @override
  String get homeWeekendSaleTitle => 'تخفيضات نهاية الأسبوع';

  @override
  String get homeWeekendSaleSubtitle => 'خصم إضافي 15% على منتجات محددة';

  @override
  String get homeWeekendSaleCta => 'تسوق الآن';

  @override
  String homeDeliverToCity(String city) {
    return 'التوصيل إلى $city';
  }

  @override
  String get homeCityBeirut => 'بيروت';

  @override
  String get homeCityTripoli => 'طرابلس';

  @override
  String get homeCitySidon => 'صيدا';

  @override
  String get homeCityTyre => 'صور';

  @override
  String get homeCityJounieh => 'جونية';

  @override
  String get homeCityByblos => 'جبيل';

  @override
  String get homeCityZahle => 'زحلة';

  @override
  String get homeCityBaalbek => 'بعلبك';

  @override
  String get homeCityNabatieh => 'النبطية';

  @override
  String get homeCityBatroun => 'البترون';

  @override
  String get homeCityBsharri => 'بشري';

  @override
  String get homeCityAley => 'عاليه';

  @override
  String get homeCategoryGroceries => 'بقالة';

  @override
  String get homeCategoryRestaurants => 'مطاعم';

  @override
  String get homeCategoryPharmacy => 'صيدلية';

  @override
  String get homeCategoryCoffee => 'قهوة';

  @override
  String get homeCategoryBakery => 'مخبوزات';

  @override
  String get homeCategoryElectronics => 'إلكترونيات';

  @override
  String get homeCategoryFlowers => 'زهور';

  @override
  String get homeCategoryPetSupplies => 'مستلزمات الحيوانات الأليفة';

  @override
  String get homeCategoryCosmetics => 'مستحضرات تجميل';

  @override
  String get homeCategorySnacks => 'سناكات';

  @override
  String get homeCategoryDrinks => 'مشروبات';

  @override
  String get homeCategoryBaby => 'أطفال';

  @override
  String get homeCuratedTrendsLoadErrorTitle => 'تعذر تحميل الترندات المختارة';

  @override
  String get homeCuratedTrendsEmptyTitle => 'لا توجد اختيارات مُنسّقة بعد.';

  @override
  String get homeCuratedTrendsIntroTitle => 'اختيارات هذا الأسبوع';

  @override
  String get homeCuratedTrendsIntroSubtitle =>
      'مجموعة مُنسّقة من كتالوجنا — مختارة للأناقة وسهولة التنسيق. ليست قائمة بالأكثر شعبية.';

  @override
  String get homeCuratedTrendsEditorsFavoritesTitle => 'مفضلات المحرر';

  @override
  String get homeCuratedTrendsEditorsFavoritesSubtitle =>
      'اختيارات قوية للبدء بها.';

  @override
  String get homeCuratedTrendsWorthALookTitle => 'يستحق الإلقاء نظرة';

  @override
  String get homeCuratedTrendsWorthALookSubtitle =>
      'بعض الاختيارات الإضافية للتنوع.';

  @override
  String get homeCuratedTrendsMorePicksTitle => 'المزيد من الاختيارات';

  @override
  String get homeCuratedTrendsMorePicksSubtitle => 'لمن يريد الاستكشاف أكثر.';

  @override
  String get homeCuratedTrendsEditorsPickBadge => 'اختيار المحرر';

  @override
  String get homeCuratedTrendsHeroPickLabel => 'اختيار البطل لهذا الأسبوع';

  @override
  String get commonBack => 'رجوع';

  @override
  String get collectionTitle => 'مجموعة';

  @override
  String get collectionNotFound => 'لم يتم العثور على المجموعة.';

  @override
  String get collectionLoadProductsErrorTitle => 'تعذر تحميل المنتجات';

  @override
  String get collectionLoadProductsErrorSubtitle =>
      'يرجى التحقق من الاتصال والمحاولة مرة أخرى.';

  @override
  String get collectionNoResultsTitle => 'لا توجد نتائج';

  @override
  String get collectionNoResultsSubtitle =>
      'جرّب كلمة أخرى أو استخدم عوامل التصفية.';

  @override
  String get searchNoResultsSubtitle => 'جرّب كلمة أخرى.';

  @override
  String get searchFeaturedTitle => 'مميز';

  @override
  String get searchCollectionsTitle => 'مجموعات';

  @override
  String get searchCollectionsSubtitle =>
      'اختيارات تحريرية لإلهام سلتك القادمة.';

  @override
  String get searchBackToShopTooltip => 'العودة إلى التسوق';

  @override
  String get searchHintSearchForProducts => 'ابحث عن منتجات';

  @override
  String get searchHintSearchInCollection => 'ابحث داخل هذه المجموعة';

  @override
  String get searchTooltipSearch => 'بحث';

  @override
  String get searchTooltipFilters => 'عوامل التصفية';

  @override
  String get searchFiltersTitle => 'عوامل التصفية';

  @override
  String get searchFiltersClearAll => 'مسح الكل';

  @override
  String get searchFiltersApply => 'تطبيق';

  @override
  String get searchFiltersSortByTitle => 'الترتيب حسب';

  @override
  String get searchFiltersSortRecommended => 'مقترح';

  @override
  String get searchFiltersSortPopular => 'الأكثر شعبية';

  @override
  String get searchFiltersSortRating => 'التقييم';

  @override
  String get searchFiltersPriceTierTitle => 'فئة السعر';

  @override
  String get searchFiltersPriceTierLowest => 'الأقل سعراً';

  @override
  String get searchFiltersPriceTierMid => 'متوسط';

  @override
  String get searchFiltersPriceTierHigh => 'مرتفع';

  @override
  String get searchFiltersCategoriesTitle => 'الفئات';

  @override
  String get searchRecentSearchesTitle => 'عمليات البحث الأخيرة';

  @override
  String get searchRecentSearchesEmptyHint => 'ابحث عن منتجات لتظهر هنا.';

  @override
  String get searchCollectionsExplore => 'استكشف';

  @override
  String get searchCollectionEditorial1Title => 'اختيار المحرر';

  @override
  String get searchCollectionEditorial1Subtitle =>
      'اختيارات مُنسّقة بجودة عالية';

  @override
  String get searchCollectionEditorial2Title => 'أساسيات عطلة نهاية الأسبوع';

  @override
  String get searchCollectionEditorial2Subtitle => 'بسيطة وسريعة بتأثير كبير';

  @override
  String get searchCollectionEditorial3Title => 'تقنية نظيفة';

  @override
  String get searchCollectionEditorial3Subtitle => 'اختيارات بسيطة وعصرية';

  @override
  String get searchCollectionEditorial4Title => 'ركن القهوة';

  @override
  String get searchCollectionEditorial4Subtitle => 'ترقيات صغيرة بإحساس فاخر';

  @override
  String get searchCollectionEditorial5Title => 'حلويات يومية';

  @override
  String get searchCollectionEditorial5Subtitle => 'سناكات مفضلة';

  @override
  String get searchCollectionEditorial6Title => 'الطفل والعائلة';

  @override
  String get searchCollectionEditorial6Subtitle => 'اختيارات لطيفة وناعمة';

  @override
  String get commonClear => 'مسح';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonSaving => 'جارٍ الحفظ…';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonRefresh => 'تحديث';

  @override
  String get commonSignIn => 'تسجيل الدخول';

  @override
  String get commonSignOut => 'تسجيل الخروج';

  @override
  String get commonEnabled => 'مفعّل';

  @override
  String get commonDisabled => 'معطّل';

  @override
  String get commonVerified => 'موثّق';

  @override
  String get commonNotVerified => 'غير موثّق';

  @override
  String get commonSeeAll => 'عرض الكل';

  @override
  String get languageNameEnglish => 'English';

  @override
  String get languageNameArabic => 'العربية';

  @override
  String get languageNameFrench => 'Français';

  @override
  String get languageNameSpanish => 'Español';

  @override
  String get profileThemeTitle => 'المظهر';

  @override
  String get profileThemeSystem => 'النظام';

  @override
  String get profileThemeLight => 'فاتح';

  @override
  String get profileThemeDark => 'داكن';

  @override
  String get profileSignOutDialogTitle => 'تسجيل الخروج؟';

  @override
  String get profileSignOutDialogBody =>
      'يمكنك تسجيل الدخول مرة أخرى في أي وقت.';

  @override
  String profileSnackbarSignInToAccess(String feature) {
    return 'سجّل الدخول للوصول إلى $feature.';
  }

  @override
  String profileNotAvailableYet(String feature) {
    return '$feature غير متاح بعد.';
  }

  @override
  String get profileSectionAccount => 'الحساب';

  @override
  String get profileSectionMyShopping => 'تسوّقي';

  @override
  String get profileSectionSupport => 'الدعم';

  @override
  String get profileSectionApp => 'التطبيق';

  @override
  String get profileSectionAuth => 'المصادقة';

  @override
  String get profileAccountDetailsTitle => 'تفاصيل الحساب';

  @override
  String get profileAccountDetailsTileSubtitle => 'معلومات الملف والتوثيق';

  @override
  String get profileAccountDetailsSubtitle => 'إدارة ملفك الشخصي والتوثيق';

  @override
  String get profileAddressesTitle => 'العناوين';

  @override
  String get profileAddressesSubtitle => 'عناوين التوصيل';

  @override
  String get profilePaymentMethodsTitle => 'طرق الدفع';

  @override
  String get profilePaymentMethodsSubtitle => 'البطاقات والمحافظ';

  @override
  String get profileOrdersTitle => 'الطلبات';

  @override
  String get profileOrdersSubtitle => 'تتبع الشراء والتوصيل';

  @override
  String get profileWishlistTitle => 'قائمة الرغبات';

  @override
  String get profileWishlistSubtitle => 'عناصر محفوظة';

  @override
  String get profileCartTitle => 'السلة';

  @override
  String get profileCartSubtitle => 'عناصر جاهزة للدفع';

  @override
  String get profileMessagesTitle => 'الرسائل';

  @override
  String get profileHelpCenterTitle => 'مركز المساعدة';

  @override
  String get profileHelpCenterSubtitle => 'إجابات عن الأسئلة الشائعة';

  @override
  String get profileContactSupportTitle => 'تواصل مع الدعم';

  @override
  String get profileContactSupportSubtitle => 'نحن هنا للمساعدة';

  @override
  String get profileBuildStatusTelemetryTitle => 'القياس';

  @override
  String get profileBuildStatusPersonalizationTitle => 'التخصيص';

  @override
  String get profileBuildStatusSubtitle => 'يُحدد حسب إعدادات البناء';

  @override
  String get profileSignInSubtitle => 'افتح مزامنة الطلبات والرسائل';

  @override
  String get profileSignOutSubtitle => 'يمكنك تسجيل الدخول مرة أخرى في أي وقت';

  @override
  String get profileFeatureOrders => 'الطلبات';

  @override
  String get profileFeatureMessages => 'الرسائل';

  @override
  String get profileGuestLabel => 'ضيف';

  @override
  String get profileMemberLabel => 'عضو';

  @override
  String get profileGuestInitial => 'ض';

  @override
  String get profileAccountConnected => 'الحساب متصل';

  @override
  String get profileSignInToUnlockBenefits => 'سجّل الدخول لفتح المزايا';

  @override
  String get profileSignInBannerBody =>
      'سجّل الدخول لمزامنة الطلبات والوصول إلى الرسائل عبر الأجهزة.';

  @override
  String profileGoldPoints(int value) {
    return '$value ذهب';
  }

  @override
  String get goldTitle => 'ذهبي';

  @override
  String get goldInfoTooltip => 'معلومات';

  @override
  String get goldTierRulesPlaceholder => 'قواعد المستوى غير متاحة بعد.';

  @override
  String get goldRetentionMonthPlaceholder => 'هذا الشهر';

  @override
  String goldRetentionMessage(int remaining, String month) {
    return 'أكمل $remaining طلبًا إضافيًا هذا الشهر للحفاظ على المستوى الذهبي في $month.';
  }

  @override
  String get goldPointsLabel => 'النقاط';

  @override
  String get goldPointsHistoryCta => 'سجل النقاط';

  @override
  String goldOrdersCompletedLabel(int count) {
    return '$count طلب';
  }

  @override
  String goldOrdersOutOfLabel(int count) {
    return 'من أصل $count';
  }

  @override
  String get goldNoticeSimplifiedPoints =>
      'قمنا بتبسيط طريقة كسب واستبدال نقاط الولاء… القيمة بقيت كما هي.';

  @override
  String get goldDiscountsAndOffersTitle => 'خصومات وعروض';

  @override
  String get goldRewardsUnavailableBody => 'المكافآت غير متاحة بعد.';

  @override
  String get goldPointsHistoryTitle => 'سجل النقاط';

  @override
  String get goldPointsHistoryUnavailableBody => 'سجل النقاط غير متاح بعد.';

  @override
  String get goldRewardDetailsTitle => 'تفاصيل المكافأة';

  @override
  String get goldClose => 'إغلاق';

  @override
  String get goldRewardDetailsPlaceholderTitle => 'مكافأة';

  @override
  String get goldRewardDetailsPlaceholderSubtitle =>
      'هذه المكافأة غير متاحة بعد.';

  @override
  String goldRewardPointsChip(int points) {
    return 'أو $points نقطة';
  }

  @override
  String get goldRewardTermsPlaceholder => 'الشروط والأهلية غير متاحة بعد.';

  @override
  String get goldClaimRewardCta => 'استرداد المكافأة';

  @override
  String get profileSignInRequiredTitle => 'تسجيل الدخول مطلوب';

  @override
  String get profileSignInRequiredSubtitle =>
      'سجّل الدخول لعرض وتحديث تفاصيل حسابك.';

  @override
  String get profileSectionDisplayName => 'الاسم المعروض';

  @override
  String get profileSectionEmail => 'البريد الإلكتروني';

  @override
  String get profileSectionPhoneNumber => 'رقم الهاتف';

  @override
  String get profileFieldNameLabel => 'الاسم';

  @override
  String get profileFieldNameHint => 'اسمك';

  @override
  String get profileAnonymousEditBlocked => 'سجّل الدخول لتعديل ملفك الشخصي.';

  @override
  String get profileNoEmail => 'لا يوجد بريد';

  @override
  String get profileVerifyEmailCta => 'توثيق البريد';

  @override
  String get profileAnonymousEmailBlocked => 'سجّل الدخول لتوثيق بريدك.';

  @override
  String get profileAnonymousPhoneBlocked => 'سجّل الدخول لتوثيق هاتفك.';

  @override
  String get profileNoPhoneLinked => 'لا يوجد هاتف مرتبط';

  @override
  String get profileFieldPhoneLabel => 'رقم الهاتف';

  @override
  String get profileFieldPhoneHint => '+12025550123';

  @override
  String get profileSendCodeCta => 'إرسال الرمز';

  @override
  String get profileFieldSmsCodeLabel => 'رمز SMS';

  @override
  String get profileVerifyPhoneCta => 'توثيق الهاتف';

  @override
  String get profileSnackbarNameUpdated => 'تم تحديث الاسم';

  @override
  String get profileSnackbarVerificationEmailSent => 'تم إرسال رسالة التوثيق';

  @override
  String get profileSnackbarSmsCodeSent => 'تم إرسال رمز SMS';

  @override
  String get profileSnackbarPhoneVerified => 'تم توثيق الهاتف';

  @override
  String get profileSnackbarPleaseSignInToEditName =>
      'يرجى تسجيل الدخول لتعديل اسمك.';

  @override
  String get profileSnackbarNoEmailAttached =>
      'لا يوجد بريد مرتبط بهذا الحساب.';

  @override
  String get profileSnackbarPleaseSignInToVerifyPhone =>
      'يرجى تسجيل الدخول لتوثيق رقم هاتف.';

  @override
  String get profileSnackbarEnterPhone => 'أدخل رقم الهاتف';

  @override
  String get profileSnackbarStartPhoneVerificationFirst =>
      'ابدأ توثيق الهاتف أولاً.';

  @override
  String get profileSnackbarEnterSmsCode => 'أدخل رمز SMS';

  @override
  String profileVerifiedCountLabel(int count) {
    return 'تم التوثيق $count/2';
  }

  @override
  String get profileSectionProfileTitle => 'الملف الشخصي';

  @override
  String get profileSectionProfileSubtitle => 'حدّث معلومات حسابك.';

  @override
  String get profileSectionEmailTitle => 'البريد';

  @override
  String get profileSectionEmailSubtitle => 'وثّق لفتح مزامنة الطلبات.';

  @override
  String get profileSectionPhoneTitle => 'الهاتف';

  @override
  String get profileSectionPhoneSubtitle =>
      'وثّق لاستعادة الحساب وتحديثات التوصيل.';

  @override
  String profileResendAvailableInSeconds(int seconds) {
    return 'إعادة الإرسال بعد $secondsث';
  }

  @override
  String get profileGuestSessionTitle => 'جلسة ضيف';

  @override
  String get profileYourAccountTitle => 'حسابك';

  @override
  String get profileAnonymousSyncHint => 'سجّل الدخول للمزامنة عبر الأجهزة.';

  @override
  String get profileSignedInLabel => 'تم تسجيل الدخول';

  @override
  String get profileAnonymousSyncAndVerifyHint =>
      'سجّل الدخول للمزامنة وتوثيق حسابك.';

  @override
  String get profileDemoBadgeLabel => 'تجريبي';

  @override
  String get offersTitle => 'العروض';

  @override
  String get offersSubtitle => 'صفقات حصرية مختارة لك';

  @override
  String get offersTooltipFilters => 'عوامل التصفية';

  @override
  String get offersSearchHint => 'ابحث عن عروض';

  @override
  String get offersLoadErrorTitle => 'تعذر تحميل العروض';

  @override
  String get offersEmptyTitle => 'لا توجد عروض';

  @override
  String get offersEmptySubtitle => 'جرّب عامل تصفية مختلف أو بحثًا آخر.';

  @override
  String get offersQuickAll => 'الكل';

  @override
  String get offersQuickNew => 'جديد';

  @override
  String get offersQuickPopular => 'الأكثر شعبية';

  @override
  String get offersQuickExpiring => 'قارب على الانتهاء';

  @override
  String get offersQuickOnline => 'أونلاين';

  @override
  String get offersQuickInStore => 'داخل المتجر';

  @override
  String get offersFeaturedDealBadge => 'صفقة مميزة';

  @override
  String get offersFeaturedShopDeal => 'تسوق الصفقة';

  @override
  String get offersFiltersTitle => 'عوامل التصفية';

  @override
  String get offersFiltersClearAll => 'مسح الكل';

  @override
  String get offersFiltersSortBy => 'ترتيب حسب';

  @override
  String get offersFiltersPriceTier => 'فئة السعر';

  @override
  String get offersFiltersChannel => 'القناة';

  @override
  String get offersFiltersCategories => 'الفئات';

  @override
  String get offersFiltersApply => 'تطبيق';

  @override
  String get offersSortRecommended => 'مقترح';

  @override
  String get offersSortEndingSoon => 'ينتهي قريبًا';

  @override
  String get offersSortHighestDiscount => 'أعلى خصم';

  @override
  String get offersSortNewest => 'الأحدث';

  @override
  String get offersPriceUnder25 => 'أقل من 25\$';

  @override
  String get offersPriceUnder50 => 'أقل من 50\$';

  @override
  String get offersPriceHighValue => 'قيمة عالية';

  @override
  String get offersChannelAll => 'الكل';

  @override
  String get offersChannelOnline => 'أونلاين';

  @override
  String get offersChannelInStore => 'داخل المتجر';

  @override
  String get offersCategoryFashion => 'الأزياء';

  @override
  String get offersCategoryShoes => 'الأحذية';

  @override
  String get offersCategoryBeauty => 'الجمال';

  @override
  String get offersCategoryElectronics => 'الإلكترونيات';

  @override
  String get offersCategoryHome => 'المنزل';

  @override
  String get offersCategoryGrocery => 'البقالة';

  @override
  String get offersCategoryFitness => 'اللياقة';

  @override
  String offersBadgePercentOff(String value) {
    return 'خصم $value%';
  }

  @override
  String offersBadgeAmountOff(String value) {
    return 'خصم \$$value';
  }

  @override
  String get offersBadgeBogo => 'اشترِ واحدة واحصل على واحدة';

  @override
  String get offersBadgeDeal => 'صفقة';

  @override
  String get offersPillCode => 'رمز';

  @override
  String get offersPillFeatured => 'مميز';

  @override
  String get offersViewDealCta => 'عرض الصفقة';

  @override
  String get offerDetailsTitle => 'تفاصيل العرض';

  @override
  String get offerLoadErrorTitle => 'تعذر تحميل العرض';

  @override
  String get offerNotFoundTitle => 'لم يتم العثور على العرض';

  @override
  String get offerExpiresExpired => 'منتهي';

  @override
  String get offerExpiresEndsSoon => 'ينتهي قريبًا';

  @override
  String offerExpiresEndsInDays(int days) {
    return 'ينتهي خلال $days يوم';
  }

  @override
  String offerExpiresEndsInHours(int hours) {
    return 'ينتهي خلال $hours ساعة';
  }

  @override
  String get offerPromoCodeCopied => 'تم نسخ رمز العرض';

  @override
  String get offerRedeemTitle => 'الاسترداد';

  @override
  String get offerTerms => 'الشروط';

  @override
  String get offerCopyCodeTooltip => 'نسخ الرمز';

  @override
  String get offerUseCodeAtCheckout => 'استخدم هذا الرمز عند الدفع.';

  @override
  String get offerNoPromoCodeRequired => 'لا يلزم رمز ترويجي.';

  @override
  String get offerShopProductsInThisOffer => 'تسوق منتجات هذا العرض';

  @override
  String get productItemTitle => 'عنصر';

  @override
  String get productClearSelectionTooltip => 'مسح الاختيار';

  @override
  String get productRemoveFromWishlistTooltip => 'إزالة من المفضلة';

  @override
  String get productSaveToWishlistTooltip => 'حفظ في المفضلة';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonRequired => 'مطلوب';

  @override
  String get commonSomethingWentWrongTryAgain =>
      'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get authWelcomeBackSubtitle => 'مرحبًا بعودتك — سجّل الدخول للمتابعة';

  @override
  String get authSignInTitle => 'تسجيل الدخول';

  @override
  String get authSignInBody =>
      'استخدم بريدك الإلكتروني وكلمة المرور للوصول إلى حسابك.';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authPasswordHint => '••••••••';

  @override
  String get authEmailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get authPasswordRequired => 'كلمة المرور مطلوبة';

  @override
  String get authInvalidEmail => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get authForgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get authPasswordResetUnavailable =>
      'إعادة تعيين كلمة المرور غير متاحة بعد.';

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get authContinueWithGoogle => 'المتابعة باستخدام Google';

  @override
  String get authContinueAsGuest => 'المتابعة كضيف';

  @override
  String get trustSecure => 'آمن';

  @override
  String get trustFastDelivery => 'توصيل سريع';

  @override
  String get trustSupport => 'الدعم';

  @override
  String get wishlistTitle => 'المفضلة';

  @override
  String get wishlistLoadErrorTitle => 'تعذر تحميل المفضلة';

  @override
  String get wishlistEmptyTitle => 'لا توجد عناصر محفوظة بعد';

  @override
  String get wishlistEmptySubtitle => 'اضغط على القلب في المنتج لحفظه هنا.';

  @override
  String get cartTitle => 'السلة';

  @override
  String get cartSelectAll => 'تحديد الكل';

  @override
  String get cartDeselectAll => 'إلغاء تحديد الكل';

  @override
  String get cartLoadErrorTitle => 'تعذر تحميل سلتك';

  @override
  String get cartSyncNotice =>
      'سجّل الدخول لمزامنة هذه السلة عبر الأجهزة. وحتى ذلك الحين ستبقى على هذا الجهاز.';

  @override
  String get cartYouMightLikeTitle => 'قد يعجبك';

  @override
  String get cartYouMightLikeSubtitle => 'إضافات اختيارية. اضغط لعرض التفاصيل.';

  @override
  String get cartFilterAll => 'الكل';

  @override
  String get cartFilterHotDeals => 'عروض ساخنة';

  @override
  String get cartFilterFrequentFavorites => 'الأكثر تكرارًا';

  @override
  String get cartSelectionAllSelectedMessage =>
      'تم تحديد جميع العناصر لإتمام الشراء. ألغِ تحديد العناصر للاحتفاظ بها في الحقيبة.';

  @override
  String get cartSelectionSomeSelectedMessage =>
      'سيشمل الدفع العناصر المحددة فقط. تبقى العناصر غير المحددة في الحقيبة.';

  @override
  String get cartSelectionNoneSelectedMessage =>
      'حدد عناصر للمتابعة إلى الدفع.';

  @override
  String get cartSubtotalLabel => 'المجموع الفرعي';

  @override
  String get cartSelectedSubtotalLabel => 'المجموع الفرعي المحدد';

  @override
  String get cartTaxesAndShippingNote => 'يتم احتساب الضرائب والشحن عند الدفع.';

  @override
  String get cartSelectItemsToContinue => 'حدد عناصر للمتابعة';

  @override
  String get cartProceedToCheckout => 'المتابعة إلى الدفع';

  @override
  String get cartEmptyTitle => 'سلتك فارغة';

  @override
  String get cartEmptySubtitle1 =>
      'أضف العناصر التي تريد شراءها ثم راجعها هنا قبل الدفع.';

  @override
  String get cartEmptySubtitle2 =>
      'أضف عناصر من أي صفحة منتج ثم عد هنا لمراجعتها وإتمام الشراء.';

  @override
  String get cartContinueShopping => 'متابعة التسوق';

  @override
  String get checkoutTitle => 'الدفع';

  @override
  String get checkoutShippingTitle => 'الشحن';

  @override
  String get checkoutShippingSubtitle => 'أدخل تفاصيل التوصيل لإتمام طلبك.';

  @override
  String get checkoutHintSelectItems => 'حدد عناصر من السلة للمتابعة';

  @override
  String get checkoutHintSignIn => 'سجّل الدخول لإتمام الطلب';

  @override
  String get checkoutPlaceOrder => 'إتمام الطلب';

  @override
  String get checkoutPlacingOrder => 'جاري إتمام الطلب…';

  @override
  String get checkoutDeliveryTitle => 'التوصيل';

  @override
  String get checkoutFullNameLabel => 'الاسم الكامل';

  @override
  String get checkoutPhoneLabel => 'الهاتف';

  @override
  String get checkoutAddressLabel => 'العنوان';

  @override
  String get checkoutCityLabel => 'المدينة';

  @override
  String get checkoutStateLabel => 'الولاية/المنطقة';

  @override
  String get checkoutPostalCodeLabel => 'الرمز البريدي';

  @override
  String get checkoutCountryLabel => 'الدولة';

  @override
  String get checkoutSubtotalLabel => 'المجموع الفرعي';

  @override
  String get checkoutShippingFeeLabel => 'الشحن';

  @override
  String get checkoutFreeShipping => 'شحن مجاني';

  @override
  String get checkoutTotalLabel => 'الإجمالي';

  @override
  String get paymentsTitle => 'الدفع';

  @override
  String get paymentsChooseMethod => 'اختر طريقة الدفع';

  @override
  String get paymentsContinueCta => 'متابعة';

  @override
  String get paymentsConfirmTitle => 'تأكيد الدفع';

  @override
  String paymentsSelectedMethod(String method) {
    return 'لقد اخترت: $method';
  }

  @override
  String get paymentsPayCta => 'ادفع';

  @override
  String get paymentsSuccessTitle => 'تم الدفع';

  @override
  String get paymentsSuccessHeadline => 'اكتملت عملية الدفع';

  @override
  String paymentsOrderIdLabel(String orderId) {
    return 'رقم الطلب: $orderId';
  }

  @override
  String get paymentsViewOrderCta => 'عرض الطلب';

  @override
  String get paymentsViewOrdersCta => 'عرض الطلبات';

  @override
  String get paymentsContinueShoppingCta => 'متابعة التسوق';

  @override
  String get paymentsFailureTitle => 'فشل الدفع';

  @override
  String get paymentsFailureBody =>
      'تعذر إكمال عملية الدفع. يرجى المحاولة مرة أخرى.';

  @override
  String get paymentsSummaryTitle => 'ملخص الطلب';

  @override
  String get paymentsSummaryItems => 'العناصر';

  @override
  String get paymentsSummarySubtotal => 'المجموع الفرعي';

  @override
  String get paymentsSummaryShipping => 'الشحن';

  @override
  String get paymentsSummaryFree => 'مجاني';

  @override
  String get paymentsSummaryTotal => 'الإجمالي';

  @override
  String get paymentsMethodStripe => 'Stripe';

  @override
  String get paymentsMethodStripeSubtitle => 'بطاقة';

  @override
  String get paymentsMethodPaypal => 'PayPal';

  @override
  String get paymentsMethodPaypalSubtitle => 'دفع PayPal';

  @override
  String get checkoutCartEmpty => 'سلتك فارغة.';

  @override
  String get checkoutSignInRequired => 'يرجى تسجيل الدخول للمتابعة.';

  @override
  String get checkoutInvalidPhone => 'رقم هاتف غير صالح';

  @override
  String get checkoutAddressSearching => 'جاري البحث…';

  @override
  String get checkoutAddressSuggestionsUnavailable =>
      'اقتراحات العنوان غير متاحة — يمكنك الإدخال يدويًا.';

  @override
  String get checkoutUseManualEntry => 'استخدام الإدخال اليدوي';
}
