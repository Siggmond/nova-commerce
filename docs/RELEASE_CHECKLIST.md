# NovaCommerce — Release Checklist

## Pre-release

- **Version bump**
  - Update `pubspec.yaml` `version:` (SemVer + build number).
  - Ensure release notes / changelog entry exists (your preferred format).

- **Dependencies**
  - `flutter pub get`
  - Optional: `flutter pub outdated`

- **Quality gates**
  - `dart format --set-exit-if-changed .`
  - `flutter analyze`
  - `flutter test`
  - Golden tests (if enabled):
    - `flutter test --update-goldens`

- **Build flavors sanity**
  - `flutter build apk --debug --flavor dev --dart-define=USE_FAKE_REPOS=true`
  - `flutter build apk --release --flavor prod`

- **Migrations & local data**
  - Verify SharedPreferences migration tests pass:
    - `test/shared_prefs_cart_migration_test.dart`

- **Privacy & security checks**
  - Confirm no secrets committed:
    - `android/app/google-services.json` must not be in git
    - `ios/Runner/GoogleService-Info.plist` must not be in git
  - Confirm AI transparency + delete controls are present.

## Store readiness

- **Store assets**
  - App icon, screenshots, feature graphic (if applicable).

- **Metadata**
  - Short/long description
  - Privacy policy link

## Rollout

- **Internal testing**
  - Smoke test: auth, home browse, product details, cart, checkout (fake repos), orders.

- **Production rollout**
  - Publish staged rollout (if supported)
  - Monitor crash/analytics dashboards (if enabled)

## Post-release

- **Monitoring**
  - Watch crash rate, ANRs, and key flows.

- **Hotfix process**
  - Create a `hotfix/*` branch
  - Minimal changes + rerun full CI
  - Bump build number and ship
