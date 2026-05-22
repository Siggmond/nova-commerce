# NovaCommerce

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![State](https://img.shields.io/badge/State-Riverpod-3C873A)
![Routing](https://img.shields.io/badge/Routing-GoRouter-6E56CF)
![Backend](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=000)
![Firestore](https://img.shields.io/badge/DB-Firestore-FFA000?logo=firebase&logoColor=000)
![Auth](https://img.shields.io/badge/Auth-Firebase%20Auth-FFCA28?logo=firebase&logoColor=000)
![Payments](https://img.shields.io/badge/Payments-Stripe%20architecture-635BFF)
![AI](https://img.shields.io/badge/AI-Demo%20concierge%20%2B%20TFLite-FF6F00)

NovaCommerce is a Flutter and Firebase portfolio project that explores a modern e-commerce mobile app: storefront browsing, product details, cart, checkout, payments architecture, orders, offers, loyalty, wishlist, profile, localization, performance tooling, and demo AI surfaces.

The codebase is designed to show product thinking, Flutter architecture, Firebase integration, and pragmatic tradeoffs. It is not presented as a finished launch build.

## Portfolio Note

This repository is provided for portfolio review and technical evaluation only. It includes real app architecture and integration points, but several services require project-specific setup before they can be used in a live environment.

## Features

- Storefront-style home feed with curated sections, categories, search entry points, and product cards.
- Product details flow with images, variants, stock-aware selection, wishlist action, and add-to-cart behavior.
- Cart with local persistence and signed-in Firestore sync architecture.
- Checkout form with shipping details, phone normalization, selected cart item summary, and payment handoff.
- Orders list, order details, and order success surfaces.
- Offers with filters, sorting, detail pages, promo-code-oriented data, and fake/Firestore repository implementations.
- Gold loyalty screens and points/reward surfaces.
- Wishlist, recently viewed, profile, account details, messages, trends, and search modules.
- Demo repository implementations for running the app without a configured Firebase project.
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

## Firebase And Backend

The app uses Firebase client services and has Firebase Functions architecture for server-owned payment/order work.

Firebase areas represented in the project:

- Firebase Core initialization.
- Firebase Auth for anonymous, email/password, and Google-oriented auth flows.
- Cloud Firestore for products, carts, orders, home config, offers, and related app data.
- Firestore security rules.
- Firebase Emulator configuration for local development.
- Cloud Functions source for Stripe payment intent creation, webhook handling, and order finalization.

Project-specific Firebase files are intentionally not committed for public review. Generate your own config with FlutterFire before running Firebase-backed flows.

## Payments

NovaCommerce includes a payment architecture rather than a drop-in configured payment account.

- Stripe-oriented flow exists through Flutter code and Firebase Functions.
- Stripe requires Firebase Functions deployment, Stripe secret configuration, webhook secret configuration, webhook endpoint setup, and project-specific Firebase/Auth/Firestore configuration.
- Demo/fake payment behavior exists for local walkthroughs.
- PayPal is represented as demo/stub behavior only; a real PayPal integration is not configured.

## AI Surfaces

NovaCommerce has two AI-oriented areas:

- Nova AI / AI concierge: a chat-style UI backed by deterministic fake/demo behavior unless a real service is connected later.
- AI navigation model architecture: a TFLite navigation-intent model path with controller logic, confidence thresholds, margin checks, and fail-safe behavior.

The concierge should be treated as a demo surface, not a connected LLM or recommendation backend.

## Localization And Design System

- Material 3 UI foundation.
- Inter font family.
- Light/dark theme architecture.
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
- tflite_flutter
- Flutter localization tooling

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

test/                  # unit, widget, and golden-oriented tests
integration_test/      # performance flow
tool/                  # performance capture and analysis scripts
docs/                  # architecture and performance notes
```

## Getting Started

Install dependencies:

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

Run tests:

```bash
flutter test --exclude-tags=golden
flutter test --tags=golden
```

## Demo Mode

Demo mode uses fake/local repositories so the app can be reviewed without a Firebase project:

```bash
flutter run --dart-define=USE_FAKE_REPOS=true
```

Payment behavior can also be run in fake/demo mode depending on the payment provider flags.

## Firebase Setup

To use Firebase-backed flows:

1. Create a Firebase project.
2. Enable Authentication providers needed for your run: Anonymous, Email/Password, and Google if desired.
3. Create or seed Firestore data for products, offers, home config, carts, and orders as needed.
4. Generate platform configuration:

```bash
flutterfire configure
```

This produces project-specific client config such as:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

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

## Testing And Current Quality Status

Current local audit status:

- `flutter analyze` passes.
- `flutter test --exclude-tags=golden` currently fails and needs cleanup before the test suite can be considered green.
- `flutter test --tags=golden` currently does not run matching golden-tagged tests in this environment.

Known failing areas from the current audit include AI chat storage test setup, checkout/payment-flow expectations, product details widget assumptions, and tab navigation assertions.

## Screenshots

Screenshots will be added after capturing the latest app UI.

Recommended screens to include:

- Home storefront
- Product details
- Cart
- Checkout
- Payment flow
- Orders
- Offers
- Gold loyalty
- Wishlist
- Profile
- AI concierge
- Messages
- Dark mode

## Known Limitations

- Firebase project configuration is required for Firebase-backed flows.
- Stripe requires project-specific Functions deployment, secrets, webhook setup, and data validation.
- PayPal behavior is demo/stub only.
- Nova AI concierge uses deterministic fake/demo behavior unless connected to a real service later.
- Some tests currently fail and need follow-up work.
- Store signing, app identifiers, privacy/legal docs, catalog data, and release-specific setup are not included as finished deployment work.
- Admin tooling, fulfillment, carrier rates, refunds, and operational dashboards are outside the current app scope.

## Roadmap

- Repair the failing test suite and make CI status match the repository state.
- Replace or regenerate Firebase client config through a documented local setup flow.
- Capture current screenshots for the README.
- Harden Stripe/Functions setup documentation.
- Move any remaining client-sensitive checkout assumptions into trusted backend paths.
- Expand admin and operational flows if this project evolves beyond portfolio review.
- Add real AI service integration behind the existing repository boundary if desired.

## License

This repository is provided for portfolio review and technical evaluation only. It is not open source.

See [LICENSE](LICENSE).
