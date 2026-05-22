# Android build flavors & signing

## Flavors

Configured Android flavors:

- `dev`
- `stage`
- `prod`

Gradle config:
- `android/app/build.gradle.kts`

### Build commands

- Dev (fake repos):
  - `flutter build apk --debug --flavor dev --dart-define=USE_FAKE_REPOS=true --dart-define=APP_FLAVOR=dev`

- Stage:
  - `flutter build apk --debug --flavor stage --dart-define=APP_FLAVOR=stage`

- Prod:
  - `flutter build apk --release --flavor prod --dart-define=APP_FLAVOR=prod`

## Google Services

`google-services.json` is intentionally ignored.

### Per-flavor config (recommended)

Create a Firebase app for each flavor you want to build with Firebase enabled.

- `dev`: `com.novacommerce.nova_commerce.dev`
- `stage`: `com.novacommerce.nova_commerce.stage`
- `prod`: `com.novacommerce.nova_commerce`

Place the downloaded files here:

- `android/app/src/dev/google-services.json`
- `android/app/src/stage/google-services.json`
- `android/app/src/prod/google-services.json`

Gradle applies the Google Services plugin if it detects a `google-services.json` either at:

- `android/app/google-services.json` (legacy single-config)
- or anywhere under `android/app/src/**/google-services.json` (flavor-specific)

## Signing

Release signing uses `key.properties` (ignored by git).

Create `android/key.properties`:

- `storeFile=../keystore/upload-keystore.jks`
- `storePassword=...`
- `keyAlias=...`
- `keyPassword=...`

Place the keystore file at the matching path.

If `key.properties` is missing, release builds fall back to debug signing (for local testing only).
