# Nova Commerce — HomeScreen Upgrade Plan (Shein-like Experience)

> This is a product + architecture plan/spec (not implementation code). It aligns with current app rules: **feature-first**, **Riverpod**, **dumb UI**, **providers for derived lists**, **no UI → repo calls**, and **performance-first**.

## 1) Goals & Non-goals

### Goals
- **Shein-like home experience** for Nova Commerce: a **personalized**, **modular** feed with **dynamic ranking**, **fast perceived UX**, and **experimentation-ready** sections.
- Make the Home feed **section-based**, with **clear data contracts**, **predictable state**, and **consistent skeleton/error UI**.
- Keep UX **snappy** (scroll 60fps, quick first content, async section loading).
- Support **incremental rollout** behind feature flags (no big-bang rewrite).

### Non-goals
- **No full backend rewrite** or new backend stack requirement.
- **No heavy redesign** that breaks current navigation or core shopping flows.
- **No ML dependency** for v1; personalization begins rule-based.
- **No UI → repo calls** or logic inside widgets; all logic lives in providers/controllers.

## 2) Current State (Baseline)

### Home Architecture (today)
- Home screen uses **Riverpod view model/controller** for state and **UI widgets** for presentation.
- **Filter providers** exist for category / search / derived lists.
- Sections are computed in UI-level logic and are relatively **static**.

### Pain Points
- **Static sections** (limited personalization or dynamic ranking).
- **Limited experimentation** (no consistent section registry for variants).
- **Slow perceived loading** (spinners, not layout-matching skeletons).
- **No clear feed contracts** (section composition not standardized).

## 3) Target UX (Spec-level)

### Sections & Behaviors
- **Hero banner + promos**: rotating, tappable promos with fallback static image.
- **Category chips / quick filters**: horizontally scrollable chips for top categories.
- **“For You” personalized feed**: prioritized items based on recent behavior.
- **Trending / Best Sellers**: top-performing products.
- **Flash deals / under $X**: time-boxed or price-limited collection.
- **New arrivals**: latest products.
- **Continue browsing / recently viewed**: resume last browse path.
- **“Inspired by…” (similar items)**: e.g., “Inspired by your last view”.
- **Sticky search entry** + global search route.
- **Pull-to-refresh**: refreshes sections and re-ranks; **refresh != loading** (keep content, show refresh indicator + subtle shimmer per section).
- **Empty/error states**: section-level fallback; global error uses common retry pattern; retry only reloads failed section unless forced.

## 4) Feed Architecture (Most Important)

### Modular Feed System
- **Home is a list of sections** defined by a registry. Each section has:
  - `id`, `title`, `layoutType` (`carousel`, `grid`, `list`),
  - `dataProvider` (Riverpod provider),
  - `skeleton` (layout-matched),
  - `errorUI` (section-level error state + retry).

### HomeFeedController
- A **HomeFeedController** assembles **ordered sections** + **states**.
- Outputs an ordered list of `HomeSectionState` objects (loading/ready/error/empty).
- Controls **refresh** and **section-level retry**.

### Ranking Strategy
- **Phase 1**: deterministic rules (recent views, category preferences, trending).
- **Phase 2**: client-side scoring/ranking (cached, lightweight).
- **Phase 3**: server-driven ranking (optional backend capability).

### Data Contracts
- `HomeFeedRequest` (domain):
  - userId/deviceId (optional), timezone, locale, flags.
  - previous session context: recent views, cart affinity, category preferences.
- `HomeSectionData` (domain):
  - section id, title, layout, items, metadata (tracking tags).
- DTOs are **separate from domain**; mapping happens in repositories.

## 5) Personalization Strategy (Phased)

- **Phase 1 — Rule-based personalization**
  - Inputs: recent views, cart affinity, category preference, search history.
  - Output: reordering + boosting sections based on weighted heuristics.

- **Phase 2 — Lightweight client scoring**
  - Cached scores for product/category affinity; local calculations only.

- **Phase 3 — Server-driven ranking**
  - Backend returns ordered sections with weights; client still validates/falls back.

**Data usage (privacy-safe):**
- Recent views (local), wishlist additions, cart additions, category taps, searches.
- **Opt-out**: if telemetry disabled or user opts out, personalization falls back to generic ordering.

## 6) Performance Plan (60fps)

### Hard Budgets
- **Time-to-first-content**: < 900ms on mid devices (cached), < 1500ms (cold).
- **Scroll jank**: < 1% frames over 16ms.
- **Image sizes**: capped, responsive, lazy loaded.

### Rendering Strategy
- **Skeleton-first rendering** aligned with final layout.
- **Pagination + loadMore** only in sections that support it (not global list).
- **Caching**: image cache + feed payload cache (stale-while-revalidate).
- **No heavy work in build**; use providers + selectors for derived lists.

### Instrumentation
- Track frame times, section load times, time-to-first-interaction.
- Log section-level errors & retries for diagnostics.

## 7) Data & Backend Assumptions

- Required data (even if mocked now):
  - `featured`, `promos`, `trending`, `bestSellers`, `newArrivals`, `flashDeals`, `recentlyViewed`, `similarItems`, `forYou`.
- Optional server-driven **sections config** (JSON shape):

```json
{
  "version": 1,
  "sections": [
    {
      "id": "hero",
      "title": "",
      "layoutType": "carousel",
      "dataKey": "featured",
      "rankWeight": 100
    }
  ]
}
```

- **Offline behavior**: cached feed shown immediately; stale-while-revalidate refresh in background.

## 8) Experimentation & Analytics

- Feature flags to switch **new feed vs old**.
- A/B test hooks for **section ordering**, **layout variants**, **ranking rules**.
- Metrics:
  - CTR per section
  - add-to-cart rate
  - conversion funnel
  - time-to-first-interaction
  - scroll depth
- **Privacy constraints** respected (telemetry flag, opt-out support, no PII).

## 9) Migration Plan (Incremental Rollout)

- **Phase 0 — Instrument + refactor**
  - Extract current Home into **section components**.
  - Add telemetry for baseline metrics.
- **Phase 1 — Section registry + skeleton/error patterns**
  - Introduce registry + `HomeFeedController`.
  - Ensure old Home remains behind a flag.
- **Phase 2 — Rule-based personalization**
  - “For You” ordering + recent views.
  - Section-level caching.
- **Phase 3 — Server-driven config + experiments**
  - Support server-provided section config.
  - A/B testing for ranking/ordering.

**No big-bang rewrite**: the old Home remains available behind a feature flag until parity is met.

## 10) Risks & Mitigations

- **Jank risk** → Use cached images, layout-matched skeletons, avoid build-time work.
- **Over-fetching** → Section-level pagination, dedupe requests, request IDs.
- **Rebuild storms** → Use Riverpod selectors, split providers.
- **Flaky rankings** → Stable fallback order and deterministic rules.
- **Privacy concerns** → Strict opt-out + limited data usage.

## 11) Acceptance Criteria

### Phase 0 Done
- Home split into section components with baseline metrics.
- Old Home remains functional behind flag.

### Phase 1 Done
- Section registry + `HomeFeedController` in place.
- Skeleton + error UI per section.
- Perf: TTFContent and scroll jank tracked.

### Phase 2 Done
- “For You” personalization rules applied.
- Caching + pagination standards implemented.
- Analytics event coverage for section interactions.

### Phase 3 Done
- Server-driven config supported.
- Experiment hooks live with flag/variant support.
- Visual parity with old Home + perf thresholds met.
