# Definition of Done (NovaCommerce)

## Must-pass flows
- Browse → Product Details → Add to Cart → Checkout → Orders confirmation.
- Cart updates reflect additions/removals and totals update correctly.
- Orders list shows the newly placed order (or fake/demo equivalent).

## Offline / resiliency
- Airplane mode on Home: shows cached content or graceful error + retry.
- Airplane mode on Cart: shows graceful error + retry.

## Auth edge cases
- Signed-out checkout path prompts sign-in or handles auth gating gracefully.

## Error / retry validation
- Home section retry works and does not blank the entire Home feed.
- Orders retry works on error state.

## Performance sanity
- Skeletons display during loading; no obvious jank when scrolling.

## Privacy / security sanity
- No secrets committed in repo.
- Telemetry is off by default (ENABLE_TELEMETRY=false).

## Build verification
- Debug build runs locally.
- Release builds succeed:
  - APK (release)
  - AAB (release)
