# NovaCommerce

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![State](https://img.shields.io/badge/State-Riverpod-3C873A)
![Routing](https://img.shields.io/badge/Routing-GoRouter-6E56CF)
![Backend](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=000)
![Database](https://img.shields.io/badge/Database-Firestore-FFA000?logo=firebase&logoColor=000)
![Payments](https://img.shields.io/badge/Payments-Stripe-635BFF?logo=stripe&logoColor=white)
![AI](https://img.shields.io/badge/AI-Concierge%20UI%20%2B%20TFLite-FF6F00?logo=tensorflow&logoColor=white)

NovaCommerce is a production-oriented Flutter/Firebase ecommerce app foundation with a polished mobile storefront, product discovery, product details with variants, cart, checkout, payment flow, orders, profile, wishlist, offers, loyalty rewards, localization, performance tooling, and an AI concierge surface.

It is best understood as an advanced ecommerce MVP and customizable commerce app foundation, not a simple UI template. The project includes real app architecture, repository abstractions, local/demo repositories, Firebase integration, Firestore rules, Cloud Functions payment/order finalization architecture, Stripe payment flow support, and reusable feature modules that can be rebranded or extended for a real commerce product.

> **Current readiness:** NovaCommerce is demo-ready and commercially valuable as a source-code foundation. It still needs production hardening before app-store launch, including test cleanup, final Firebase/Stripe configuration, app signing, fresh screenshots, production data, admin tooling, privacy/legal pages, and operational integrations.

---

## Table of contents

- [What NovaCommerce is](#what-novacommerce-is)
- [Current status](#current-status)
- [Buyer / client positioning](#buyer--client-positioning)
- [Feature overview](#feature-overview)
- [Core user flows](#core-user-flows)
- [Payments and orders](#payments-and-orders)
- [AI surfaces](#ai-surfaces)
- [Localization and design system](#localization-and-design-system)
- [Architecture](#architecture)
- [Backend and Firebase](#backend-and-firebase)
- [Performance and resilience](#performance-and-resilience)
- [Tech stack](#tech-stack)
- [Project structure](#project-structure)
- [Getting started](#getting-started)
- [Configuration and environment flags](#configuration-and-environment-flags)
- [Firebase setup](#firebase-setup)
- [Stripe setup](#stripe-setup)
- [Emulators](#emulators)
- [Demo mode](#demo-mode)
- [Testing and quality](#testing-and-quality)
- [Screenshots](#screenshots)
- [Known limitations](#known-limitations)
- [Pre-sale / pre-launch checklist](#pre-sale--pre-launch-checklist)
- [Roadmap ideas](#roadmap-ideas)
- [License](#license)

---

## What NovaCommerce is

NovaCommerce gives a buyer or development team the foundation for a modern mobile commerce product.

It includes:

- Cross-platform Flutter app structure.
- Feature-first architecture.
- Firebase Authentication integration.
- Cloud Firestore integration.
- Firebase Cloud Functions backend for payment/order finalization.
- Stripe-oriented payment flow.
- Demo payment mode for walkthroughs.
- Product catalog, home feed, search, product details, cart, checkout, payment, orders, offers, loyalty, wishlist, profile, messages, trends, and AI assistant screens.
- Local fallback/demo repositories so the app can be shown without a fully configured live backend.
- Multi-language localization files.
- Performance instrumentation and CI documentation.
- Test suite covering unit, widget, integration, and golden-test areas.

NovaCommerce is suitable for:

- Retail brands that want their own mobile shopping app.
- Local marketplaces for fashion, grocery, pharmacy, electronics, coffee, lifestyle, or mixed categories.
- Startups needing an ecommerce MVP for client or investor demos.
- Software agencies that want a reusable Flutter/Firebase commerce foundation.
- Buyers who want a white-label ecommerce app base instead of starting from zero.

---

## Current status

### Implemented

- Modern storefront home feed.
- Product catalog browsing.
- Search and filtering flow.
- Product details with image carousel, variants, stock state, wishlist action, and add-to-cart behavior.
- Local cart persistence.
- Firestore cart sync for signed-in users.
- Checkout shipping form and summary recalculation.
- Payment method, payment confirmation, success, and failure screens.
- Fake/demo payment repository for walkthroughs.
- Stripe payment repository architecture.
- Firebase Cloud Functions for Stripe PaymentIntent creation and order finalization.
- Orders list and order details.
- Firebase Authentication support.
- Anonymous auth, email/password auth, and Google sign-in support.
- Profile and account screens.
- Wishlist.
- Recently viewed products.
- Offers and promotions module.
- Gold loyalty/rewards module.
- AI concierge chat UI.
- TFLite navigation-intent model asset and app-side runner/controller architecture.
- Messages and trends screens.
- English, Arabic, French, and Spanish localization files.
- Light and dark theme support.
- Material 3 design system.
- Shared UI components.
- Performance tooling and documentation.
- Unit, widget, golden, and integration-test assets.

### Demo-ready but not production-final

- The app can be presented as a strong ecommerce MVP/source-code asset.
- Demo repositories and fake payment behavior make buyer walkthroughs easier.
- Stripe architecture exists, but each buyer must configure their own Firebase project, Stripe account, webhook secret, app IDs, signing, and production data.
- PayPal is present only as a demo/stub path, not a production PayPal integration.
- The AI concierge UI is implemented, but it is currently backed by a fake deterministic repository rather than a real LLM/recommendation backend.
- The TFLite navigation model asset and architecture exist, but live model loading is currently guarded/disabled in the inspected state.
- Some production work remains before public app-store release.

### Not included

- Admin dashboard.
- Inventory management UI.
- Order management dashboard.
- Refund management UI.
- Real shipping carrier integration.
- Delivery tracking.
- Warehouse or fulfillment integration.
- Production privacy policy and terms pages.
- Final buyer branding.
- Final Android/iOS release signing.
- Production-ready catalog/content pipeline.

---

## Buyer / client positioning

NovaCommerce can be positioned as:

> A customizable Flutter/Firebase commerce app foundation with modern shopping flows, Stripe-oriented payment architecture, orders, offers, loyalty, localization, and AI concierge UI.

Recommended honest positioning:

- “Advanced ecommerce MVP.”
- “Production-oriented Flutter commerce foundation.”
- “White-label mobile commerce starter.”
- “Buyer-ready source-code package after cleanup.”
- “Demo-ready ecommerce app with real backend architecture.”

Avoid positioning it as:

- “Fully production ready today.”
- “Complete marketplace platform.”
- “Real AI-powered shopping assistant.”
- “Ready to publish immediately.”
- “Complete admin + logistics solution.”

A strong buyer pitch:

> NovaCommerce is not a single-screen template. It is a structured ecommerce app with real shopping flows, Firebase integration, Stripe-oriented backend functions, local demo mode, modular repositories, and a feature-first Flutter architecture. A buyer can rebrand it, connect their Firebase and Stripe accounts, replace seed data with their catalog, and continue building toward production.

---

## Feature overview

### Storefront home

The home experience is built around a modern commerce feed.

It includes:

- Brand app bar.
- Delivery/city selector surface.
- Messages shortcut.
- Gold loyalty entry.
- Search entry.
- Category tiles.
- Curated product sections.
- Trending sections.
- Picked-for-you sections.
- Pull-to-refresh.
- Infinite scroll/load-more behavior.
- Skeleton/loading states.
- Product cards.
- Image preloading and performance markers.

Commercial value:

- Gives buyers a recognizable ecommerce first screen.
- Can be adapted to many verticals: fashion, grocery, pharmacy, electronics, lifestyle, coffee, beauty, baby/family, or mixed local commerce.
- Makes the app feel like a real shopping product instead of a static prototype.

### Product discovery and search

The app includes a dedicated search route and search view model.

Implemented capabilities include:

- Query filtering by product title and brand.
- Category filtering.
- Price-tier filtering.
- Sort modes such as recommended, popular, and rating-like scoring.
- Featured product preview.
- Editorial collection routes.
- Recent-searches infrastructure through local persistence.

Future upgrade paths:

- Algolia.
- Meilisearch.
- Firestore index-backed search.
- Custom backend search.
- Personalized recommendations.

### Product details

The product details experience includes:

- Product image pager.
- Brand and title display.
- Price display.
- Product description.
- Stock badge.
- Color variant selection.
- Size variant selection.
- Disabled options based on availability.
- Wishlist toggle.
- Add-to-cart bar.
- Snackbar action to view cart.
- Loading, error, and not-found states.

Commercial value:

- Supports conversion-focused product browsing.
- Variant support is useful for fashion, apparel, shoes, color/size-based inventory, and similar retail categories.

### Cart

The cart system includes:

- SharedPreferences-backed local persistence.
- Firestore sync when a signed-in user is available.
- Syncing repository that bridges local and remote cart state.
- Quantity updates.
- Item removal.
- Clear cart.
- Selected-item checkout behavior.
- Cart totals.
- Recommended add-on items.
- Selection messaging for all selected, partially selected, or no selected items.

Commercial value:

- Supports guest shopping.
- Supports signed-in cart sync.
- Enables a realistic buyer demo: add item, update quantity, select items, checkout.

### Checkout

Checkout includes:

- Shipping form.
- Full name field.
- Phone field.
- Address field.
- City field.
- State/region field.
- Postal code field.
- Country field.
- Required-field validation.
- Phone normalization through `phone_number`.
- Special Lebanese phone handling.
- Optional Google Places autocomplete behind environment flags.
- Manual address entry fallback.
- Summary recalculation.
- Tax and shipping fee calculation hooks.
- Selected cart item checkout.
- Sign-in gating.
- Navigation into payment flow.

Current behavior:

- Checkout routes into payment flow.
- Fake/demo payment can show payment success for demos.
- Real Stripe order creation is handled through Firebase Cloud Functions in the Stripe path.

### Payments

NovaCommerce includes a payment architecture rather than only static payment screens.

Implemented payment surfaces:

- Payment method selection.
- Payment confirmation screen.
- Payment success screen.
- Payment failure screen.
- Fake/demo payment repository.
- Stripe payment repository.
- PayPal demo/stub repository.

Fake/demo payment mode:

- Supports Stripe and PayPal labels.
- Can simulate success, failure, or cancellation.
- Useful for sales demos without real credentials.

Stripe real-mode architecture:

- Uses Firebase Cloud Functions.
- Creates Stripe PaymentIntent.
- Initializes and presents Stripe payment sheet.
- Finalizes order from PaymentIntent after successful payment.
- Supports webhook-based finalization through `stripeWebhook`.
- Uses locking/idempotency-style protection through `payment_intent_locks`.
- Stores payment session context under `payment_sessions`.

PayPal status:

- Demo/stub flow exists.
- Real PayPal integration is not production-configured in this build.

### Orders

Orders include:

- Orders list.
- Order details.
- Order success route.
- Firestore stream for signed-in user orders.
- Order DTO and mapper layer.
- Sorting by creation date.
- Empty state.
- Error state.

Backend order creation:

- Real Stripe payment path creates paid orders through Cloud Functions.
- Orders are linked to `uid`.
- Order payload includes user, device, status, currency, subtotal, shipping fee, total, amount in minor units, payment status, provider, PaymentIntent ID, shipping, items, and timestamps.

### Authentication and account

Authentication support includes:

- Firebase anonymous authentication.
- Email/password authentication.
- Google sign-in.
- Guest-to-signed-in credential linking path.
- Demo fallback mode for invalid Firebase API key scenarios.
- Auth state provider.
- Profile screen.
- Account details screen.
- Display name update.
- Email verification.
- Phone verification flow.
- Sign-in and sign-out UI.

Production note:

- Each buyer must configure Firebase Auth providers for their own Firebase project.
- Google sign-in requires correct app IDs, SHA keys, OAuth client setup, and platform configuration.

### Wishlist and recently viewed

Wishlist:

- Local SharedPreferences-backed repository.
- Product heart toggle.
- Wishlist screen.
- Empty and populated states.

Recently viewed:

- Local SharedPreferences-backed repository.
- Supports rediscovery and future personalization.

Future upgrade path:

- Sync wishlist and recently viewed data to user accounts.
- Use recently viewed behavior for recommendations.

### Offers

The offers module includes:

- Offers screen.
- Offer details screen.
- Offer cards.
- Debounced search input.
- Quick filters:
  - All.
  - New.
  - Popular.
  - Expiring.
  - Online.
  - In-store.
- Sort modes:
  - Recommended.
  - Ending soon.
  - Highest discount.
  - Newest.
- Tags and channel filtering.
- Pagination/load more.
- Firestore-backed repository.
- Fake offers repository with seeded data.
- Repository cache for page and detail reads.
- Promo code support.
- Terms URL support.

Commercial value:

- Enables promotional campaigns.
- Supports seasonal offers, online vs in-store deals, promo codes, and featured promotions.

### Gold loyalty

The Gold loyalty feature includes:

- Gold screen.
- Points history screen.
- Reward details screen.
- Reward offer cards.
- Gold balance provider.
- Local and Firestore repositories.
- Idempotent local order crediting.
- Firestore user ledger path for credited orders.
- Awarding logic based on order total.

Commercial value:

- Adds retention and repeat-purchase mechanics.
- Can be adapted into rewards, wallet credit, paid membership, or customer tiering.

Production note:

- Firestore rules and/or backend logic must be reviewed before production.
- Loyalty awarding should ideally be server-side to prevent client-side reward manipulation.

### Messages and trends

The app includes:

- Messages screen.
- Message tabs for order, activity, promo, and news.
- Trends screen.
- Trending-now route.
- Picked-for-you route.

Commercial value:

- Adds CRM, notification, editorial, and campaign expansion points.
- Makes the product feel broader than a basic shopping/cart demo.

---

## Core user flows

### Buyer demo flow

A recommended product demo:

1. Open the storefront home.
2. Show categories and curated sections.
3. Open product details.
4. Select color/size variants.
5. Add the product to cart.
6. Open cart.
7. Update quantity or selection.
8. Continue to checkout.
9. Fill shipping details.
10. Choose a payment method.
11. Simulate a successful demo payment or use configured Stripe mode.
12. Show payment success / order success.
13. Show orders.
14. Show wishlist.
15. Show offers.
16. Show Gold loyalty.
17. Show profile.
18. Show AI concierge UI.

### Technical review flow

For a technical buyer or developer, show:

- `lib/app/router/app_router.dart` for routing.
- Dependency injection/providers.
- Repository interfaces.
- Fake/local/Firestore repository implementations.
- Checkout and payment flow.
- `functions/src/index.ts` for Stripe/Firebase Functions.
- `firestore.rules` for security posture.
- Test folders.
- CI workflow.
- Performance documentation and tooling.

---

## Payments and orders

NovaCommerce uses a repository-based payment architecture.

### Payment modes

The app supports multiple payment modes conceptually:

- Fake/demo payment for walkthroughs.
- Stripe-backed real payment path.
- PayPal demo/stub path.

### Stripe flow

At a high level:

1. User completes checkout details.
2. App creates or prepares a payment session.
3. Firebase Cloud Function creates a Stripe PaymentIntent.
4. App initializes Stripe payment sheet.
5. User completes payment.
6. Backend finalizes the order from the PaymentIntent.
7. Webhook can also finalize/confirm payment state.
8. Order is stored in Firestore and linked to the signed-in user.

### Firestore collections related to payment/order flow

Important paths include:

```text
orders/{orderId}
payment_sessions/{paymentIntentId}
payment_intent_locks/{paymentIntentId}
See [LICENSE](LICENSE).
