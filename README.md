# NovaCommerce

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![State](https://img.shields.io/badge/State-Riverpod-3C873A)
![Routing](https://img.shields.io/badge/Routing-GoRouter-6E56CF)
![Backend](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=000)
![DB](https://img.shields.io/badge/DB-Firestore-FFA000?logo=firebase&logoColor=000)

A Flutter + Firebase commerce app showcasing end‑to‑end shopping flows with a clean, scalable architecture: product discovery, variants, cart, checkout, orders, authentication, and an optional AI assistant layer.

> **Scope:** Payments and logistics integrations are intentionally out of scope.

---

## Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Firebase Setup](#firebase-setup)
- [Emulators](#emulators)
- [Demo Mode](#demo-mode)
- [License](#license)

---

## Features

### Core commerce
- Product catalog with pagination and featured products
- Product variants (size/color) with stock validation
- Cart with quantity management and persistence
- Wishlist with local + remote sync
- Checkout with transactional stock decrement
- Orders list + order details

### Authentication
- Email/password sign-in
- Google sign-in
- Anonymous (guest) sessions with upgrade to authenticated accounts

### Backend & data
- Firestore for products, orders, and user data
- Firestore transactions for atomic checkout and stock updates
- Offline persistence enabled for Firestore
- Emulator support for local development

### UX & performance
- Responsive layout (flutter_screenutil)
- Cached images (cached_network_image)
- Skeleton loaders for perceived performance
- Consistent, user-friendly error handling

### AI assistant (optional)
- “Nova AI” chat assistant for product-related queries
- Repository is modular (supports real or fake implementations)

---

## Screenshots

<!-- 4-column grid using HTML (renders well on GitHub) -->
<div align="center">
  <img src="assets/screenshots/Img1.jpeg" width="22%" alt="Home" />
  <img src="assets/screenshots/Img2.jpeg" width="22%" alt="Home feed" />
  <img src="assets/screenshots/Img3.jpeg" width="22%" alt="Product details" />
  <img src="assets/screenshots/Img4.jpeg" width="22%" alt="Nova AI" />
</div>

<br/>

<div align="center">
  <img src="assets/screenshots/Img5.jpeg" width="22%" alt="Cart" />
  <img src="assets/screenshots/Img6.jpeg" width="22%" alt="Checkout" />
  <img src="assets/screenshots/Img7.jpeg" width="22%" alt="Profile" />
  <img src="assets/screenshots/Img8.jpeg" width="22%" alt="Wishlist empty" />
</div>

<br/>

<div align="center">
  <img src="assets/screenshots/Img9.jpeg" width="22%" alt="Wishlist with item" />
  <img src="assets/screenshots/Img10.jpeg" width="22%" alt="Orders empty" />
  <img src="assets/screenshots/Img11.jpeg" width="22%" alt="Sign in" />
</div>

---

## Tech Stack

- Flutter / Dart
- Material 3
- Riverpod
- GoRouter
- Firebase Auth + Firestore
- cached_network_image
- flutter_screenutil

---

## Project Structure

High-level layout:

```text
lib/
  main.dart
  app.dart
  core/          # routing, theme, shared widgets, config, error mapping
  domain/        # entities + repository interfaces
  data/          # repository implementations + datasources
  features/      # home, product, cart, checkout, wishlist, orders, auth, ai_assistant, profile
```

---

## Getting Started

### Prerequisites
- Flutter SDK (3.x)
- Dart SDK (3.x)

Install dependencies:

```bash
flutter pub get
```

Run quality checks:

```bash
dart format .
flutter analyze
flutter test
```

Run the app:

```bash
flutter run
```

---

## Firebase Setup

This app uses **client-side Firebase configuration** (no server-side secrets are included in this repository).

### Option A — Use your own Firebase project (recommended)

1. Create a Firebase project.
2. Enable Authentication providers (Anonymous / Email-Password / Google).
3. Create Firestore collections:
   - `products`
   - `orders`
4. From the repo root, run:

```bash
flutterfire configure
```

This generates:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

> Tip: If your product query orders by `createdAt`, make sure product docs contain `createdAt` and any flags you filter on (e.g. `featured: true`).

---

## Emulators (optional)

Start emulators:

```bash
firebase emulators:start --only firestore,auth
```

Run app using emulators (examples):

### iOS Simulator
```bash
flutter run \
  --dart-define=USE_FIRESTORE_EMULATOR=true \
  --dart-define=FIRESTORE_HOST=localhost \
  --dart-define=FIRESTORE_PORT=8080 \
  --dart-define=AUTH_PORT=9099
```

### Android Emulator
```bash
flutter run \
  --dart-define=USE_FIRESTORE_EMULATOR=true \
  --dart-define=FIRESTORE_HOST=10.0.2.2 \
  --dart-define=FIRESTORE_PORT=8080 \
  --dart-define=AUTH_PORT=9099
```

> Notes:
> - On Android Emulator, `10.0.2.2` routes to your host machine.
> - On a physical device, use your machine’s LAN IP (e.g., `192.168.x.x`).

---

## Demo Mode

Run with in-memory repositories (no Firebase required):

```bash
flutter run --dart-define=USE_FAKE_REPOS=true
```

---

## License

This repository is provided for **review and evaluation purposes only**.
It is **not open-source** and may not be reused, redistributed, or deployed without explicit written permission.

See [LICENSE](LICENSE).

