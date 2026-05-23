# NovaCommerce

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![State](https://img.shields.io/badge/State-Riverpod-3C873A)
![Routing](https://img.shields.io/badge/Routing-GoRouter-6E56CF)
![Backend](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=000)
![Database](https://img.shields.io/badge/DB-Firestore-FFA000?logo=firebase&logoColor=000)
![Auth](https://img.shields.io/badge/Auth-Firebase%20Auth-FFCA28?logo=firebase&logoColor=000)
![Payments](https://img.shields.io/badge/Payments-Stripe%20architecture-635BFF)
![AI](https://img.shields.io/badge/AI-Demo%20concierge%20%2B%20TFLite-FF6F00)
![CI](https://img.shields.io/badge/CI-format%20%7C%20analyze%20%7C%20tests-2EA44F)

NovaCommerce is a Flutter and Firebase portfolio project that demonstrates a modern mobile commerce experience: storefront browsing, product discovery, product details, cart, checkout, payment flow architecture, orders, offers, loyalty, wishlist, profile, localization, performance tooling, and demo AI surfaces.

The project is designed to show product thinking, Flutter architecture, Firebase integration points, UI systems, and practical engineering tradeoffs. It is not presented as a finished launch build.

## Portfolio Note

This repository is provided for portfolio review and technical evaluation only. It includes real app architecture, modular feature boundaries, Firebase integration points, and payment backend architecture, but live services still require project-specific setup before they can be used in a production environment.

## Screenshots

Current screenshots are stored in `assets/screenshots/`.

<p align="center">
  <img src="assets/screenshots/Screenshot_20260523_140630.png" width="180" alt="NovaCommerce screenshot 01" />
  <img src="assets/screenshots/Screenshot_20260523_140700.png" width="180" alt="NovaCommerce screenshot 02" />
  <img src="assets/screenshots/Screenshot_20260523_140711.png" width="180" alt="NovaCommerce screenshot 03" />
  <img src="assets/screenshots/Screenshot_20260523_140720.png" width="180" alt="NovaCommerce screenshot 04" />
</p>

<p align="center">
  <img src="assets/screenshots/Screenshot_20260523_140736.png" width="180" alt="NovaCommerce screenshot 05" />
  <img src="assets/screenshots/Screenshot_20260523_140742.png" width="180" alt="NovaCommerce screenshot 06" />
  <img src="assets/screenshots/Screenshot_20260523_140811.png" width="180" alt="NovaCommerce screenshot 07" />
  <img src="assets/screenshots/Screenshot_20260523_140818.png" width="180" alt="NovaCommerce screenshot 08" />
</p>

<p align="center">
  <img src="assets/screenshots/Screenshot_20260523_140824.png" width="180" alt="NovaCommerce screenshot 09" />
  <img src="assets/screenshots/Screenshot_20260523_140829.png" width="180" alt="NovaCommerce screenshot 10" />
  <img src="assets/screenshots/Screenshot_20260523_140844.png" width="180" alt="NovaCommerce screenshot 11" />
  <img src="assets/screenshots/Screenshot_20260523_140857.png" width="180" alt="NovaCommerce screenshot 12" />
</p>

<p align="center">
  <img src="assets/screenshots/Screenshot_20260523_140909.png" width="180" alt="NovaCommerce screenshot 13" />
</p>

## Features

- Storefront-style home feed with curated sections, categories, search entry points, product cards, pull-to-refresh, and load-more behavior.
- Product discovery and search with filters, recent searches, collection surfaces, result cards, and empty/error states.
- Product details flow with image carousel, variants, stock-aware selection, wishlist action, description, and add-to-cart behavior.
- Cart with local persistence, selected-item checkout behavior, quantity updates, recommendations, and signed-in Firestore sync architecture.
- Checkout form with shipping details, phone normalization, selected cart summary, validation surfaces, and payment handoff.
- Payment method, payment confirmation, success, and failure screens.
- Orders list, order details, and order success surfaces.
- Offers module with search, filters, sorting, offer cards, detail pages, promo-code-oriented data, and fake/Firestore repository implementations.
- Gold loyalty screens with reward cards, points history, and reward detail surfaces.
- Wishlist, recently viewed, profile, account details, messages, trends, and AI concierge modules.
- Demo repository implementations for reviewing the app without a configured Firebase project.
- Localization files for English, Arabic, French, and Spanish.
- Performance markers, image cache policies, and profile-flow tooling.

## Architecture

NovaCommerce follows a feature-first Flutter structure with clear boundaries:

- Presentation layers own screens, widgets, and view models.
- Domain layers define entities, repository contracts, and use cases.
- Data layers implement fake, local, Firestore, syncing, and provider-specific behavior.
- Riverpod is used for dependency injection and state management.
- GoRouter owns the route map and tab shell navigation.
- Firebase and payment dependencies sit behind repository/provider boundaries so demo and configured modes can coexist.
- Shared tokens and widgets keep typography, spacing, surfaces, cards, buttons, chips, states, and product UI consistent across the app.

## Firebase And Backend

The app uses Firebase client services and includes Firebase Functions architecture for server-owned payment/order work.

Firebase areas represented in the project:

- Firebase Core initialization.
- Firebase Auth for anonymous, email/password, and Google-oriented auth flows.
- Cloud Firestore integration points for products, carts, orders, home config, offers, and related app data.
- Firestore security rules.
- Firebase Emulator configuration for local development.
- Cloud Functions source for Stripe payment intent creation, webhook handling, and order finalization.

Project-specific Firebase client files are intentionally not committed for public review. Generate your own config with FlutterFire before running Firebase-backed flows.

## Payments

NovaCommerce includes a payment architecture rather than a drop-in configured payment account.

- Stripe-oriented flow exists through Flutter code and Firebase Functions.
- Stripe requires Firebase Functions deployment, Stripe secret configuration, webhook secret configuration, webhook endpoint setup, and project-specific Firebase/Auth/Firestore configuration.
- Demo/fake payment behavior exists for local walkthroughs.
- PayPal is represented as demo/stub behavior only; a real PayPal integration is not configured.

## AI Surfaces

NovaCommerce has two AI-oriented areas:

- Nova AI / AI concierge: a chat-style UI backed by deterministic fake/demo behavior unless a real service is connected later.
- AI navigation model architecture: a TFLite navigation-intent model path with controller logic, confidence thresholds, margin checks, cooldowns, and fail-safe behavior.

The concierge should be treated as a demo surface, not a connected LLM or production recommendation backend.

## Localization And Design System

- Material 3 UI foundation.
- Plus Jakarta Sans typography foundation.
- Light/dark theme architecture.
- Shared tokens for spacing, radius, surfaces, shadows, and interaction rhythm.
- Shared UI components for buttons, chips, surfaces, product cards, skeletons, empty states, error states, and status labels.
- Localized ARB sources for English, Arabic, French, and Spanish.
- Generated localization output is configured through `l10n.yaml`.

## Performance And Resilience

- Cached network images and decode-size policies.
- Home feed pagination and deduplication.
- Skeleton and retry states for key flows.
- Performance markers for app start, first frame, home product loading, route flows, and memory samples.
- Profile-mode performance tooling under `tool/` and `integration_test/`.
- Fake/local repositories help the app remain demonstrable without external services.
- CI avoids requiring private Firebase config or unreleased golden baselines.

## Tech Stack

- Flutter / Dart
- Material 3
- Riverpod
- GoRouter
- Firebase Core
- Firebase Auth
- Cloud Firestore
- Firebase Functions
- Stripe SDK integration points
- SharedPreferences
- Hive
- cached_network_image
- flutter_svg
- flutter_screenutil
- google_fonts
- tflite_flutter
- Flutter localization tooling
- GitHub Actions

## Project Structure

```text
lib/
  main.dart
  app/                 # app bootstrap, routing, DI, theme, config, perf runtime
  core/                # shared widgets, shared domain types, services, perf helpers
  features/            # feature-first modules
    ai_assistant/
    auth/
    cart/
    checkout/
    home/
    loyalty/
    messages/
    offers/
    orders/
    payments/
    products/
    profile/
    recently_viewed/
    search/
    trends/
    wishlist/
  l10n/                # ARB localization sources
  gen_l10n/            # generated localization output

functions/
  src/                 # Firebase Functions source

assets/
  icons/
  images/
  fonts/
  screenshots/

test/                  # unit, widget, and golden-oriented test files
integration_test/      # performance flow
tool/                  # performance capture and analysis scripts
docs/                  # design, architecture, and performance notes
```

## Getting Started

Install Flutter dependencies:

```bash
flutter pub get
```

Run the app in local demo mode:

```bash
flutter run --dart-define=USE_FAKE_REPOS=true
```

Run static analysis:

```bash
flutter analyze
```

Run the verified non-golden test suite:

```bash
flutter test --exclude-tags=golden
```

Build a debug APK:

```bash
flutter build apk --debug
```

## Demo Mode

Demo mode uses fake/local repositories so the app can be reviewed without a Firebase project:

```bash
flutter run --dart-define=USE_FAKE_REPOS=true
```

Payment behavior can also run in fake/demo mode depending on payment provider flags.

## Firebase Setup

To use Firebase-backed flows:

1. Create a Firebase project.
2. Enable the Authentication providers needed for your run: Anonymous, Email/Password, and Google if desired.
3. Create or seed Firestore data for products, offers, home config, carts, and orders as needed.
4. Generate platform configuration:

```bash
flutterfire configure
```

This produces project-specific client config such as:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

These files should be generated locally for your Firebase project. Do not commit real private project secrets.

For local emulators:

```bash
firebase emulators:start --only firestore,auth,functions
```

Example Android emulator run:

```bash
flutter run \
  --dart-define=USE_FIRESTORE_EMULATOR=true \
  --dart-define=FIRESTORE_HOST=10.0.2.2 \
  --dart-define=FIRESTORE_PORT=8080 \
  --dart-define=AUTH_PORT=9099
```

## Stripe Setup

Stripe-backed flows require app, Firebase, and Stripe configuration:

1. Deploy the Firebase Functions in `functions/`.
2. Configure Firebase Functions secrets for Stripe secret key and webhook secret.
3. Configure the Stripe webhook endpoint to call the deployed webhook function.
4. Provide a Stripe publishable key to the Flutter app through build-time configuration.
5. Confirm Firestore rules, cart data, product data, auth state, and order finalization behavior in your Firebase project.

Representative run flags:

```bash
flutter run \
  --dart-define=PAYMENTS_PROVIDER=stripe \
  --dart-define=PAYMENTS_MODE=real \
  --dart-define=STRIPE_PUBLISHABLE_KEY=your_publishable_key
```

Do not put Stripe secret keys in Flutter client code.

## Firebase Functions

Install and build Functions dependencies:

```bash
cd functions
npm ci
npm run build
```

The project currently expects Node 18 for Functions. If your local machine uses a newer Node version, `npm ci` may show an engine warning while still installing.

## Testing And Current Quality Status

Current verified status:

- `dart format --set-exit-if-changed .` passes.
- `flutter analyze` passes.
- `flutter test --exclude-tags=golden` passes: 58 passed, 1 skipped.
- `flutter build apk --debug` passes.

Golden screenshots/baselines are not currently required by CI. They should be refreshed only after the UI is stable and current baselines are intentionally committed.

Public CI currently runs:

- Dart format check.
- Flutter analyzer.
- Non-golden Flutter tests.

Public CI intentionally does not require:

- Golden tests without committed stable baselines.
- Release APK builds that require private Firebase config/signing files.

## Known Limitations

- Firebase project configuration is required for Firebase-backed flows.
- Stripe requires project-specific Functions deployment, secrets, webhook setup, and data validation.
- PayPal behavior is demo/stub only.
- Nova AI concierge uses deterministic fake/demo behavior unless connected to a real service later.
- Release signing, app identifiers, privacy/legal docs, catalog data, and release-specific setup are not included as finished deployment work.
- Admin tooling, fulfillment, carrier rates, refunds, and operational dashboards are outside the current app scope.
- Android debug builds may show an NDK version recommendation related to `integration_test`; the current debug build still completes.

## Roadmap

- Capture and curate a final screenshot set for the project gallery.
- Add stable golden baselines after the UI is finalized.
- Review the Android NDK version warning and decide whether to update local/project Android configuration.
- Optionally remove unused legacy Inter font assets after confirming no downstream assumptions.
- Harden Stripe/Functions setup documentation.
- Expand Firebase/local setup documentation with clearer emulator seed guidance.
- Move any remaining client-sensitive checkout assumptions into trusted backend paths.
- Add production privacy/legal pages if this project evolves beyond portfolio review.
- Add real AI service integration behind the existing repository boundary if desired.

## License

This repository is provided for portfolio review and technical evaluation only. It is not open source.

See [LICENSE](LICENSE).
