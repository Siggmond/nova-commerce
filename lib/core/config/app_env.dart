class AppEnv {
  static const String flavor = String.fromEnvironment(
    'APP_FLAVOR',

    defaultValue: 'prod',
  );

  static const bool useFakeRepos = bool.fromEnvironment(
    'USE_FAKE_REPOS',

    defaultValue: false,
  );

  static const bool enableTelemetry = bool.fromEnvironment(
    'ENABLE_TELEMETRY',

    defaultValue: false,
  );

  static const bool useFakeAi = bool.fromEnvironment(
    'USE_FAKE_AI',

    defaultValue: false,
  );

  static const bool enableAiPlaceholders = bool.fromEnvironment(
    'ENABLE_AI_PLACEHOLDERS',

    defaultValue: false,
  );

  static const bool enableHomePersonalization = bool.fromEnvironment(
    'ENABLE_HOME_PERSONALIZATION',

    defaultValue: false,
  );

  static const bool enablePlacesAutocomplete = bool.fromEnvironment(
    'ENABLE_PLACES_AUTOCOMPLETE',

    defaultValue: false,
  );

  static const bool enableNovaUi = bool.fromEnvironment(
    'ENABLE_NOVA_UI',

    defaultValue: false,
  );

  static const bool enableNovaUiProductDetails = bool.fromEnvironment(
    'ENABLE_NOVA_UI_PRODUCT_DETAILS',

    defaultValue: false,
  );

  static const bool enableNovaUiCart = bool.fromEnvironment(
    'ENABLE_NOVA_UI_CART',

    defaultValue: false,
  );

  static const bool enableNovaUiCheckout = bool.fromEnvironment(
    'ENABLE_NOVA_UI_CHECKOUT',

    defaultValue: false,
  );

  static const bool enableNovaUiProfile = bool.fromEnvironment(
    'ENABLE_NOVA_UI_PROFILE',

    defaultValue: false,
  );

  static const bool enableNovaUiProfileDetails = bool.fromEnvironment(
    'ENABLE_NOVA_UI_PROFILE_DETAILS',

    defaultValue: false,
  );

  static const String googlePlacesApiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',

    defaultValue: '',
  );

  static const bool useFirestoreEmulator = bool.fromEnvironment(
    'USE_FIRESTORE_EMULATOR',

    defaultValue: false,
  );

  static const String firestoreHost = String.fromEnvironment(
    'FIRESTORE_HOST',

    defaultValue: 'localhost',
  );

  static const int firestorePort = int.fromEnvironment(
    'FIRESTORE_PORT',

    defaultValue: 8080,
  );

  static const int authPort = int.fromEnvironment(
    'AUTH_PORT',

    defaultValue: 9099,
  );
}
