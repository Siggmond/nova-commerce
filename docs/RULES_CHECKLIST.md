# Nova Commerce — 1–100 Rules Checklist

This file tracks compliance status for the refactor rules.

Legend:
- ✅ Done
- ⚠️ Partial / in progress
- ❌ Not started

## Product / UX TODOs (not part of rules 1–100)

- **HomeScreen upgrade (Shein-like feed)**: TODO
  - Product/UX plan only (not rules compliance).
  - Must respect architecture rules: feature-first, Riverpod, dumb UI, providers for derived lists, no UI→repo calls, performance-first.
  - See `docs/HOMESCREEN_UPGRADE_PLAN.md`
- **Phase 1 tracking task — Section registry + HomeFeedController**: TODO
  - Tracking task only. Do not start until Phase 0 metrics are in place.

## Rules 39–52 (UI consistency & design system)

- **39 — Design tokens (color/type/spacing/radii/elevation)**: ✅
  - `lib/core/theme/app_theme.dart` (Material 3 ColorScheme + component theming)
  - `lib/core/theme/app_tokens.dart`
  - `lib/core/theme/app_typography.dart`
  - `lib/core/theme/app_colors.dart`
- **40 — Replace ad-hoc padding/font sizes with tokens**: ⚠️
  - In progress; tokens introduced and will be applied incrementally.
- **41 — Standardize empty/loading/error states**: ✅
  - `lib/core/widgets/empty_state.dart`
  - `lib/core/widgets/error_state.dart`
  - `lib/core/widgets/shimmer.dart`
- **42 — Hit targets >= 48dp**: ✅
  - `lib/core/theme/app_tokens.dart` (`AppHitTargets.min`)
- **43 — Don’t rely on color alone**: ⚠️
  - In progress; ensure icons/text accompany states.
- **44 — Consistent iconography**: ⚠️
  - In progress (currently Material icons; normalize to consistent set).
- **45 — Reusable components**: ✅
  - `lib/core/widgets/app_button.dart` (added)
  - `lib/core/widgets/section_card.dart` (added)
- **46 — Loading UX (skeletons > spinners)**: ⚠️
  - In progress (some spinners remain; e.g. `OrderDetailsScreen` migrated).
- **47 — Calm visual density (avoid heavy shadows/borders)**: ⚠️
  - In progress.
- **48 — Consistent cards/sections**: ✅
  - `lib/core/widgets/section_card.dart` (added)
- **49 — Consistent buttons**: ✅
  - `lib/core/widgets/app_button.dart` (added)
- **50 — Consistent empty state**: ✅
  - `lib/core/widgets/empty_state.dart`
- **51 — Consistent error state**: ✅
  - `lib/core/widgets/error_state.dart`
- **52 — Skeleton components**: ✅
  - `lib/core/widgets/shimmer.dart`

## Rules 63–76 (Offline-first & data integrity)

- **63 — Offline-first stance explicit**: ✅
  - Not claimed as strict offline-first in codebase; app uses Firestore as backend and SharedPreferences persistence for cart/wishlist.
  - `README.md`
  - `lib/data/repositories/syncing_cart_repository.dart`
- **64 — Single write layer (no UI→DB writes scattered)**: ✅
  - Firestore writes confined to repositories/datasources (no UI direct Firestore usage)
  - `lib/data/repositories/firestore_order_repository.dart`
  - `lib/data/datasources/firestore_cart_datasource.dart`
  - `lib/data/repositories/firestore_cart_repository.dart`
- **65 — Transactions for multi-step writes**: ✅
  - Checkout/order placement + stock decrement is transactional
  - `lib/data/repositories/firestore_order_repository.dart`
- **66 — Migrations tested for local persistence**: ✅
  - SharedPreferences cart migration covered (legacy shape -> v1 lines)
  - `lib/data/datasources/shared_prefs_cart_datasource.dart`
  - `test/shared_prefs_cart_migration_test.dart`
- **67 — Stable IDs created at creation time**: ✅
  - Orders: Firestore doc id created at write time (`collection('orders').doc()`)
  - Device id: UUID stored locally
  - `lib/data/repositories/firestore_order_repository.dart`
  - `lib/data/datasources/device_id_datasource.dart`
- **68 — Time handling (store UTC, display local)**: ✅
  - Orders: Firestore timestamps mapped to UTC in mapper; UI displays `toLocal()`
  - Cart: `updatedAt` stored as UTC ISO string
  - `lib/features/orders/data/mappers/order_mapper.dart`
  - `lib/features/orders/presentation/orders_screen.dart`
  - `lib/features/orders/presentation/order_details_screen.dart`
  - `lib/data/repositories/firestore_cart_repository.dart`
- **69 — DB constraints validation (required fields/lengths)**: ⚠️
  - Local cart lines validated on load
  - Checkout validates required shipping fields before write
  - `lib/data/datasources/shared_prefs_cart_datasource.dart`
  - `lib/features/checkout/presentation/checkout_viewmodel.dart`
- **70 — Indexes for query-heavy fields**: ⚠️
  - Firestore indexes are configured in Firebase Console; app code uses standard queries
  - `lib/data/datasources/firestore_product_datasource.dart`
- **71 — Soft delete / undo expectations**: N/A
  - No order cancel/delete flow implemented.
- **72 — Export/backup for local user data**: ✅
  - JSON export for locally-stored cart/wishlist/device id
  - `lib/data/services/local_data_exporter.dart`
  - `test/local_data_exporter_test.dart`

## Rules 77–86 (Security & privacy)

- **77 — No secrets hardcoded (repo audit)**: ⚠️
  - Found Firebase Android config containing an API key; treated as sensitive per rules.
  - `android/app/google-services.json` (placeholder)
  - `.gitignore` ignores Firebase platform config
  - `android/app/build.gradle.kts` applies google-services plugin only when `google-services.json` exists
- **78 — Environment separation (dev/stage/prod) via build-time config**: ⚠️
  - Build-time config exists via `--dart-define`:
    - `lib/core/config/app_env.dart`
  - Android flavors implemented:
    - `android/app/build.gradle.kts` (`dev`/`stage`/`prod`)
    - `docs/BUILD_FLAVORS.md`
- **79 — Secure storage correctness (tokens/credentials)**: ✅
  - App does not persist auth tokens manually; FirebaseAuth manages sessions.
  - Added secure storage abstraction for any future secrets:
    - `lib/core/security/secure_store.dart`
    - `lib/core/config/providers.dart` (`secureStoreProvider`)
    - `test/secure_store_test.dart`
- **80 — Sensitive data not stored in SharedPreferences**: ✅
  - SharedPrefs stores non-sensitive app state (cart lines, wishlist ids, debug perf flag, deviceId).
  - `lib/data/datasources/shared_prefs_cart_datasource.dart`
  - `lib/data/datasources/shared_prefs_wishlist_datasource.dart`
  - `lib/core/config/performance_mode.dart`
  - `lib/data/datasources/device_id_datasource.dart`
- **81 — Permission denial UX**: N/A
  - No permission-gated features detected (no `permission_handler`/camera/location/etc.).
- **82 — Permission prompts only when needed**: N/A
  - No permission prompts implemented.
- **83 — Encryption for sensitive local data**: ✅
  - No sensitive local data beyond session state handled by FirebaseAuth.
  - Cart/wishlist/deviceId are stored unencrypted by design; considered low sensitivity for this demo.
- **84 — Logging redaction / no PII in release logs**: ✅
  - Added debug-only centralized logger with redaction.
  - `lib/core/utils/app_logger.dart`
- **85 — AI transparency (sources/citations)**: ✅
  - AI UI explicitly states no citations (demo) and potential inaccuracy.
  - `lib/features/ai_assistant/presentation/ai_privacy_note.dart`
- **86 — AI delete controls (clear chat / delete my data)**: ✅
  - Added “Clear chat” control (in-memory history reset).
  - `lib/features/ai_assistant/presentation/ai_clear_chat_action.dart`
  - `lib/features/ai_assistant/presentation/ai_chat_viewmodel.dart` (`clear()`)

## Rules 87–94 (AI integration)

- **87 — AI must never block core workflows**: ✅
  - AI is a separate tab/route; browse/cart/checkout/orders do not depend on AI.
  - `lib/core/config/app_router.dart` (AI is its own `StatefulShellBranch`)
  - `lib/features/home/presentation/home_screen.dart` (AI entry is additive)

- **88 — Show sources/citations for AI claims (always)**: ❌ N/A
  - This app’s AI is an intentionally fake/demo assistant and explicitly states it does not provide citations.
  - `lib/features/ai_assistant/presentation/ai_privacy_note.dart`

- **89 — Make AI optional per user; product must remain valuable without it**: ✅
  - All core commerce features work without visiting AI.
  - `lib/core/config/app_router.dart`
  - `README.md` (AI is described as an extra feature; app supports demo mode without Firebase)

- **90 — Cache AI results where possible (summaries, embeddings)**: ❌ N/A
  - No real LLM calls, embeddings, or server responses exist in this demo; caching is not applicable.
  - `lib/core/config/providers.dart` (`aiRepositoryProvider` uses `FakeAiRepository`)

- **91 — Stream responses in chat for perceived speed**: ❌ N/A
  - Non-streaming is acceptable for demo/fake AI; current interface is `Future<ChatMessage>`.
  - `lib/domain/repositories/ai_repository.dart`
  - `lib/features/ai_assistant/presentation/ai_chat_viewmodel.dart`

- **92 — Rate limit + retry policy + exponential backoff**: ⚠️ deferred
  - Not implemented because AI is local/fake and cannot error in a realistic way.
  - When a real AI backend is added, implement retry/backoff at the repository layer.
  - `lib/domain/repositories/ai_repository.dart`
  - `lib/core/config/providers.dart` (`aiRepositoryProvider`)

- **93 — Guardrails: detect “no sources found” and say it clearly**: ❌ N/A
  - The app does not claim citations at all (explicit disclosure), so “no sources found” is not a meaningful state.
  - `lib/features/ai_assistant/presentation/ai_privacy_note.dart`

- **94 — Keep AI interfaces swappable (mock/local → backend later)**: ✅
  - AI is behind a repository interface + provider boundary; swapping implementation is a one-line provider change.
  - `lib/domain/repositories/ai_repository.dart`
  - `lib/core/config/providers.dart` (`aiRepositoryProvider`)
  - `lib/features/ai_assistant/presentation/ai_chat_viewmodel.dart`

## Rules 95–100 (Testing, release & operations)

- **95 — Minimum test coverage (repos/controllers/mappers)**: ✅
  - Checkout flow:
    - `test/checkout_viewmodel_test.dart`
    - `lib/features/checkout/presentation/checkout_viewmodel.dart`
  - Orders controllers:
    - `test/orders_controller_test.dart`
    - `lib/features/orders/presentation/orders_controller.dart`
  - AI chat viewmodel:
    - `test/ai_chat_viewmodel_test.dart`
    - `lib/features/ai_assistant/presentation/ai_chat_viewmodel.dart`
  - Critical parsing/mapping:
    - `test/order_mapping_test.dart`
    - `lib/features/orders/data/dto/order_dto.dart`
    - `lib/features/orders/data/mappers/order_mapper.dart`
  - Product details viewmodel:
    - `test/product_details_viewmodel_test.dart`
    - `lib/features/product/presentation/product_details_viewmodel.dart`

- **96 — Golden tests (major screen + reusable component) & stability**: ⚠️
  - Golden tests added and auto-skip until baseline PNGs are generated:
    - `test/golden_product_details_not_found_test.dart`
    - `test/golden_app_button_test.dart`
  - To generate baselines: `flutter test --update-goldens`

- **97 — CI pipeline (format/analyze/test/build)**: ✅
  - GitHub Actions workflow:
    - `.github/workflows/ci.yml`
  - Runs format check, analyze, tests, and builds a dev APK.

- **98 — Crash reporting + privacy-aware analytics**: ⚠️
  - Scaffolding only (feature-flagged), no external crash/analytics backend wired yet.
  - `lib/core/telemetry/telemetry.dart` (NoopTelemetry)
  - `lib/core/config/providers.dart` (`telemetryProvider`)
  - `lib/core/config/app_env.dart` (`ENABLE_TELEMETRY`)
  - `lib/main.dart` (error hooks enabled only when `ENABLE_TELEMETRY=true`)

- **99 — Build flavors + signing**: ✅
  - Android flavors + conditional Google Services plugin + signing scaffolding:
    - `android/app/build.gradle.kts`
    - `.gitignore` ignores `**/key.properties` + keystores
  - Docs:
    - `docs/BUILD_FLAVORS.md`

- **100 — Release checklist (actionable)**: ✅
  - `docs/RELEASE_CHECKLIST.md`
