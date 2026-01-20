class AppEnv {
  static const bool useFakeRepos = bool.fromEnvironment(
    'USE_FAKE_REPOS',
    defaultValue: false,
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
