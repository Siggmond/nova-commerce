# Nova Commerce Architecture

## Decisions

- Architecture: Feature-first with layers
- State management: Riverpod (StateNotifier-based controllers; migrate incrementally to Riverpod Notifier/AsyncNotifier only when needed)
- Routing: go_router
- Dependency injection (DI): Riverpod providers (composition root in `lib/app/di/app_providers.dart`)

## Goals

- Keep UI dumb: widgets/screens render state and invoke controller commands only.
- No business logic in widgets: computations, orchestration, retries, debouncing, request-cancellation belong in controllers.
- Separate domain from data: domain entities are used by the app; Firestore/SharedPrefs DTOs are mapped in `data` layer.
- Keep features modular: each feature owns its `presentation`, `application`, `data`, and `domain` subfolders.

## Current folder structure

- `lib/main.dart`
- `lib/app/`
  - `bootstrap.dart` / `main_common.dart` (startup and shared app entry)
  - `di/app_providers.dart` (repository and service composition root)
  - `router/` (GoRouter routes, route names, tab definitions)
  - `config/` (environment flags, locale/theme/performance mode)
  - `theme/` (theme and design tokens)
  - `perf/` and `startup/` (runtime performance and feature init helpers)
- `lib/core/`
  - `errors/` (error mapping, app exceptions)
  - `widgets/` (shared UI building blocks)
  - `domain/` (shared domain types and repository interfaces)
  - `services/`, `security/`, `device/`, `perf/`, `images/`, `telemetry/`, `ai_nav/`
- `lib/features/<feature>/`
  - `presentation/` (screens, widgets)
  - `presentation/state/` where a feature owns view models/controllers
  - `domain/` (entities/value objects, repository interfaces)
  - `data/` (datasources, DTOs, mappers, repository implementations)

## Current reality

- Riverpod providers live in `lib/app/di/app_providers.dart` and expose fake, local, syncing, Firestore, Firebase Auth, payment, AI, and utility implementations.
- Compile-time environment flags live in `lib/app/config/app_env.dart`.
- GoRouter setup lives in `lib/app/router/app_router.dart`, with route names in `lib/app/router/app_routes.dart`.
- Feature modules already exist under `lib/features/*` and generally use `presentation`, `domain`, and `data` boundaries.
- Some shared ecommerce types live under `lib/core/domain` because they are used across multiple features.

Migration should remain incremental to avoid breaking behavior.

## Layer responsibilities

### Presentation

- Renders state.
- Sends user intent to controllers (e.g. `ref.read(xxxControllerProvider.notifier).doThing()`).
- Must not call repositories directly.

### Application

- Orchestrates use-cases and async flows.
- Owns immutable state.
- Handles retries/undo/optimistic updates.
- Differentiates loading vs refreshing.

### Domain

- Pure Dart: entities and repository interfaces.
- No Flutter, no Firestore/SharedPreferences.

### Data

- Implements repository interfaces.
- Owns DTOs/DB models.
- Converts DTO/DB models <-> domain models via mappers.

## State conventions

- Use an explicit state model per feature.
- Loadable state uses either:
  - Riverpod `AsyncValue<T>` where it fits, or
  - a sealed state type with `loading/data/error` (equivalent)
- Refreshing vs loading:
  - Loading: no cached content yet.
  - Refreshing: keep last good data visible and update in the background.
- Requests that can become stale must be cancellable/ignored via request IDs and debouncing.

## Error handling

- Controllers return actionable errors:
  - include a clear message
  - include a recovery action (`Retry`, `Undo`) where applicable
- Map low-level exceptions to UX-safe messages via `lib/core/errors/*`.

## Naming conventions

- Providers:
  - repositories: `<thing>RepositoryProvider`
  - controllers: `<feature>ControllerProvider` (or `<feature>ViewModelProvider` during migration)
- Files:
  - screens: `<name>_screen.dart`
  - controller: `<name>_controller.dart`
  - state: `<name>_state.dart`

## Routing

- Define route paths in `lib/app/router/app_routes.dart`.
- Configure routes in `lib/app/router/app_router.dart`.
- For bottom navigation tabs, prefer a shell/branch-per-tab approach so each tab has its own navigation stack.

## Environment configuration

- Use compile-time environment flags (see `lib/app/config/app_env.dart`).
- Keep dev/stage/prod separated via flavors and environment variables.
