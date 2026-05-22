# Nova Commerce Architecture

## Decisions

- Architecture: Feature-first with layers
- State management: Riverpod (StateNotifier-based controllers; migrate incrementally to Riverpod Notifier/AsyncNotifier only when needed)
- Routing: go_router
- Dependency injection (DI): Riverpod providers (composition root in `lib/core/config/providers.dart`)

## Goals

- Keep UI dumb: widgets/screens render state and invoke controller commands only.
- No business logic in widgets: computations, orchestration, retries, debouncing, request-cancellation belong in controllers.
- Separate domain from data: domain entities are used by the app; Firestore/SharedPrefs DTOs are mapped in `data` layer.
- Keep features modular: each feature owns its `presentation`, `application`, `data`, and `domain` subfolders.

## Target folder structure

- `lib/app.dart` / `lib/main.dart`
- `lib/core/`
  - `config/` (env, DI providers, router, routes)
  - `errors/` (error mapping, app exceptions)
  - `theme/` (theme + design tokens)
  - `widgets/` (shared UI building blocks)
  - `utils/` (formatting, helpers)
- `lib/features/<feature>/`
  - `presentation/` (screens, widgets)
  - `application/` (controllers, state objects)
  - `domain/` (entities/value objects, repository interfaces)
  - `data/` (datasources, DTOs, mappers, repository implementations)

## Current reality (starting point)

- Riverpod providers live in `lib/core/config/providers.dart` and expose repository implementations.
- Many features already exist under `lib/features/*/presentation`.
- Some shared `domain/` and `data/` types currently live at `lib/domain` and `lib/data`.

Migration will be incremental to avoid breaking behavior.

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

- Define route paths in `lib/core/config/app_routes.dart`.
- Configure routes in `lib/core/config/app_router.dart`.
- For bottom navigation tabs, prefer a shell/branch-per-tab approach so each tab has its own navigation stack.

## Environment configuration

- Use compile-time environment flags (see `lib/core/config/app_env.dart`).
- Keep dev/stage/prod separated via flavors and environment variables.
