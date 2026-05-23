# NovaCommerce Design Rules

## 1. Purpose

This document defines the UI refinement rules for NovaCommerce.

NovaCommerce should feel like a premium native mobile commerce app: calm, polished, readable, responsive, and trustworthy. The quality benchmark is the restraint and consistency users expect from top-tier native apps, including Apple-style clarity and Samsung-style practical mobile ergonomics. This is a quality reference only. NovaCommerce must not copy Apple, Samsung, iOS, One UI, App Store, Galaxy Store, or any branded interface directly.

These rules guide refinement only. They are not permission to redesign the product, remove sections, rename features, change flows, or replace working UI with placeholders.

## 2. Non-negotiable product constraints

Future UI work must preserve the current product.

Do not remove, hide, rename, or reduce these areas:

- Home
- Product discovery
- Search
- Product details
- Variants
- Cart
- Checkout
- Payments
- Orders
- Offers
- Loyalty / Gold
- Wishlist
- Profile
- Messages
- Trends
- AI concierge surfaces
- Localization
- Demo/fallback flows

Do not delete screens, modules, routes, repositories, tests, localization strings, or assets unless a separate technical cleanup task proves they are unused and the removal is explicitly approved.

Every design change must keep the app usable as an ecommerce portfolio product.

## 3. Premium design principles

NovaCommerce should feel:

- Premium but not flashy.
- Calm but not empty.
- Modern but not trendy.
- Ecommerce-focused but not cluttered.
- Native-mobile quality, not a generic Flutter demo.
- Consistent across home, product details, cart, checkout, offers, loyalty, profile, and AI surfaces.

The design should prioritize:

- Clear hierarchy.
- Comfortable spacing.
- Strong readability.
- Predictable touch behavior.
- Clean product imagery.
- Trustworthy checkout and payment UI.
- Subtle motion.
- Performance-safe rendering.
- Accessibility.

Avoid:

- Overusing gradients.
- Overusing glassmorphism.
- Overusing shadows.
- Heavy blur everywhere.
- Random decorative elements.
- Inconsistent corner radii.
- Tiny tap targets.
- Low-contrast text.
- Overcrowded product cards.
- Animation that slows shopping.

## 4. Layout and spacing rules

Use spacing to make the app feel expensive and intentional.

### Base spacing scale

Prefer a consistent spacing scale:

- 4 px: tiny internal alignment.
- 8 px: compact spacing.
- 12 px: related item spacing.
- 16 px: default section padding.
- 20 px: premium horizontal screen padding.
- 24 px: major section separation.
- 32 px: large screen rhythm.
- 40+ px: hero or empty-state spacing only.

### Screen padding

Use consistent horizontal padding per screen type:

- Main commerce screens: 16-20 px.
- Dense lists: 12-16 px.
- Detail pages: 16-20 px.
- Checkout/payment forms: 16-20 px.
- Tablets/large screens: use max-width content constraints rather than stretching everything.

### Section spacing

Every screen should have a clear rhythm:

- Header.
- Primary action or search area.
- Content sections.
- Secondary content.
- Bottom action area if needed.

Avoid stacking cards with random gaps. Section spacing should feel intentional and repeatable.

### Alignment

Align text, cards, controls, and product imagery consistently. Do not mix left edges randomly. Avoid center-aligning large blocks of commerce content except for empty states.

## 5. Typography rules

Typography should feel premium, readable, and product-focused.

### Font direction

Use Plus Jakarta Sans as the preferred primary Latin font family if implemented. It should be applied globally through the app theme, not manually on each widget.

Arabic and other localized text must remain readable. If the primary font does not support a script well, use system fallback fonts or explicit `fontFamilyFallback`.

### Hierarchy

Use typography to create clear levels:

- Screen title: confident, short, high contrast.
- Section title: clear and compact.
- Product title: readable, not oversized.
- Price: stronger weight than metadata.
- Metadata: lower contrast but still accessible.
- Error/empty/help text: calm and useful.

### Rules

- Do not create many one-off text styles.
- Do not use all caps for long labels.
- Do not make price text visually weaker than secondary metadata.
- Do not use tiny font sizes below accessibility-safe limits.
- Keep line height comfortable, especially in product details, checkout, and profile.
- Preserve localization expansion; do not assume English text length.

## 6. Color and contrast rules

NovaCommerce should use a calm, premium color system.

### Color direction

Use:

- Neutral surfaces.
- Strong but restrained brand color.
- Clear semantic colors for success, warning, danger, and info.
- Product imagery as the main source of visual energy.
- Subtle background differentiation.

Avoid:

- Too many accent colors on one screen.
- Neon colors unless intentionally part of a sale badge.
- Low contrast labels.
- Pure black text on every surface when a softer token works better.
- Color-only communication without icons/text.

### Contrast

All important text and controls must meet accessibility-friendly contrast. This is especially important for:

- Prices.
- Checkout totals.
- Payment actions.
- Error messages.
- Disabled variants.
- Offer expiry labels.
- Loyalty balance.
- Profile/account status.

## 7. Surface, card, and elevation rules

Surfaces should feel native and layered without looking heavy.

### Cards

Cards should use:

- Consistent corner radius.
- Clear internal padding.
- Light border or very subtle shadow.
- Stable image aspect ratios.
- Predictable tap areas.

Avoid:

- Thick borders everywhere.
- Strong shadows on every card.
- Nested cards with competing backgrounds.
- Random card radius values.
- Dark text over busy images without protection.

### Elevation

Use elevation sparingly:

- Bottom navigation or shell surfaces may use subtle elevation.
- Sticky checkout/payment bars may use subtle elevation.
- Product cards should usually rely on surface + border rather than heavy shadows.
- Modal sheets can use higher elevation.

### Material correctness

If a `ListTile` or ink response is inside a decorated surface, ensure there is a proper `Material` ancestor inside the decoration so Flutter ink/background behavior remains correct.

## 8. Buttons, chips, and controls rules

Controls must feel consistent and easy to tap.

### Touch targets

- Minimum target size should be close to 48 px.
- Icon-only buttons must have enough padding.
- Chips must be easy to tap on real phones.

### Buttons

Primary buttons:

- One dominant primary action per screen or section.
- High contrast.
- Clear label.
- Loading/disabled states.

Secondary buttons:

- Less visual weight.
- Useful for optional paths.

Danger/destructive actions:

- Clear warning color.
- Avoid accidental taps.
- Confirm when appropriate.

### Chips

Chips should:

- Use consistent radius.
- Show selected/unselected states clearly.
- Avoid layout jump when selected.
- Support long localized labels gracefully.

## 9. Product card rules

Product cards are one of the most important ecommerce surfaces.

Each product card should make these clear:

- Product image.
- Brand/title.
- Price.
- Discount or offer status when available.
- Rating/popularity only if meaningful.
- Wishlist/action affordance.
- Stock or variant limitation only when relevant.

Rules:

- Do not overcrowd product cards.
- Keep image aspect ratios stable.
- Avoid text overflow.
- Use max lines intentionally.
- Price should be visually strong.
- Badges should not cover important product image content.
- Favorite/wishlist buttons must be large enough and visually stable.
- Skeleton/loading cards must match final layout dimensions.

## 10. Home screen refinement rules

The home screen should feel like a premium commerce storefront, not a random dashboard.

Preserve all current sections and content. Refinement should improve:

- Header clarity.
- Search prominence.
- Delivery/location surface.
- Category readability.
- Product section hierarchy.
- Promotional section balance.
- Empty/loading/error states.
- Scroll performance.

Rules:

- Do not remove sections to make the screen look cleaner.
- Do not replace real content with placeholders.
- Do not make the hero area so large that commerce content is pushed too far down.
- Keep product discovery fast.
- Use consistent section headers.
- Make "see all" actions clear but not visually loud.
- Keep pull-to-refresh and pagination behavior stable.

## 11. Search and discovery refinement rules

Search should feel fast, structured, and useful.

Refinement should improve:

- Search bar clarity.
- Recent searches.
- Filter chips.
- Collection cards.
- Result cards.
- Empty and no-result states.
- Sort/filter affordances.

Rules:

- Do not hide filters.
- Do not remove discovery sections.
- Do not make filters visually heavier than results.
- Keep search results readable in tight constraints.
- Make empty states helpful, not decorative only.
- Preserve recent-search and local persistence behavior.

## 12. Product details refinement rules

Product details should feel conversion-focused and premium.

Refinement should improve:

- Image carousel spacing.
- Product title hierarchy.
- Brand/metadata clarity.
- Price prominence.
- Variant picker clarity.
- Disabled option states.
- Wishlist and cart actions.
- Bottom action bar.
- Not-found/error/loading states.

Rules:

- Do not remove variant logic.
- Do not hide disabled options without clear reason.
- Do not make add-to-cart hard to reach.
- Do not bury price under visual noise.
- Keep product description readable.
- Preserve tests for selection behavior.

## 13. Cart, checkout, and payment refinement rules

Cart, checkout, and payment screens must feel trustworthy and calm.

Refinement should improve:

- Item list clarity.
- Quantity controls.
- Selected item state.
- Totals and fees.
- Shipping form readability.
- Required-field validation.
- Payment method selection.
- Confirmation/success/failure states.
- Security/trust cues.

Rules:

- Do not remove validation.
- Do not hide totals.
- Do not make primary payment actions ambiguous.
- Do not reduce error visibility.
- Do not overdecorate checkout.
- Keep form fields accessible and easy to scan.
- Preserve fake/demo payment behavior for portfolio walkthroughs.

## 14. Profile, offers, loyalty, and account refinement rules

These areas should feel consistent with the commerce app, not like separate prototypes.

### Profile/account

Improve:

- Group card spacing.
- Account status clarity.
- Settings/action hierarchy.
- Sign-out and destructive action separation.

Do not remove account details, verification flows, or demo indicators.

### Offers

Improve:

- Offer card hierarchy.
- Discount visibility.
- Expiry clarity.
- Online/in-store channel labels.
- Filter/search usability.

Do not remove offer filters, promo code surfaces, or terms links.

### Loyalty / Gold

Improve:

- Points balance clarity.
- Reward card hierarchy.
- History readability.
- Tier/benefit communication.

Do not imply real financial value unless the backend rules support it.

### AI surfaces

Improve:

- Chat readability.
- Empty/seed state clarity.
- Privacy note visibility.
- Message bubble rhythm.

Do not claim real LLM intelligence if the implementation is deterministic/demo-backed.

## 15. Motion and interaction rules

Motion should feel native, subtle, and useful.

Use motion for:

- State changes.
- Loading transitions.
- Tab changes.
- Add-to-cart feedback.
- Sheet/modal entry.
- Small affordance confirmations.

Avoid:

- Long animations.
- Heavy hero animations everywhere.
- Constant pulsing.
- Expensive blur or shader effects on scrolling lists.
- Animation that blocks shopping.

General timing:

- Micro-interactions: 120-180 ms.
- Standard transitions: 200-280 ms.
- Modal/sheet transitions: 250-320 ms.

Respect reduced motion preferences where possible.

## 16. Accessibility rules

Accessibility is part of premium quality.

Rules:

- Maintain readable contrast.
- Keep touch targets large.
- Support dynamic text scale where possible.
- Avoid text clipping with localization.
- Add semantic labels for icon-only controls.
- Do not use color as the only indicator.
- Ensure disabled states are clear.
- Make forms screen-reader friendly.
- Keep focus order logical.
- Avoid tiny price/metadata text.

Before merging UI changes, test at larger text scale when possible.

## 17. Performance-safe UI rules

Design refinement must not make the app slower.

Rules:

- Avoid expensive blur on long scrolling screens.
- Avoid heavy nested shadows on many cards.
- Avoid oversized images without caching/resizing strategy.
- Preserve image caching policies.
- Preserve skeleton/loading states.
- Avoid unnecessary rebuilds.
- Keep animations lightweight.
- Do not add large dependencies for small UI effects.
- Do not introduce expensive layout passes in product grids.
- Keep home/feed scrolling smooth.

If performance tooling flags regressions, prefer simplifying visuals over weakening performance checks.

## 18. What Codex must never do

Codex must never:

- Delete current sections to make the UI look cleaner.
- Remove product flows.
- Remove cart, checkout, payments, offers, loyalty, profile, wishlist, search, trends, messages, or AI surfaces.
- Replace real UI with static placeholders.
- Remove localization support.
- Remove tests to pass CI.
- Commit fake screenshots.
- Commit fake golden baselines.
- Commit real Firebase secrets.
- Commit payment secrets.
- Claim production readiness without proof.
- Copy Apple or Samsung UI exactly.
- Introduce broad rewrites without a staged plan.
- Modify backend code during a visual refinement task unless explicitly requested.
- Mix unrelated cleanup with design changes.
- Change navigation structure unless explicitly approved.
- Break non-golden tests.
- Add heavy animation or blur everywhere.
- Hide known limitations.

## 19. Acceptance checklist before any UI commit

Before any UI/refinement commit, verify:

- No product section was removed.
- No screen was deleted.
- No route was broken.
- No feature module was hidden.
- Current content remains available.
- Typography still works in English, Arabic, French, and Spanish.
- Product cards do not overflow.
- Checkout remains clear and trustworthy.
- Payment screens remain understandable.
- Profile/account actions remain accessible.
- Offers and loyalty screens remain visible.
- AI surfaces still show accurate demo behavior.
- `dart format --set-exit-if-changed .` passes.
- `flutter analyze` passes.
- `flutter test --exclude-tags=golden` passes.
- Any changed widget tests are meaningful, not weakened.
- No fake screenshots or fake baselines were added.
- No secrets were committed.
- The diff is scoped to the intended UI batch.

## 20. Recommended implementation order

Do future visual refinement in small safe batches.

Recommended order:

1. Typography and theme foundation.
   - Global font family.
   - Text theme consistency.
   - No screen redesign.

2. Core design tokens.
   - Radius.
   - Spacing.
   - Surface colors.
   - Shadows.
   - Button/chip styles.

3. Shared components.
   - Buttons.
   - Chips.
   - Cards.
   - Product tiles.
   - Text fields.
   - Section headers.
   - Empty/error/loading states.

4. Home screen refinement.
   - Keep all sections.
   - Improve spacing, hierarchy, and section rhythm.

5. Product discovery/search refinement.
   - Improve filters, recent searches, collections, and result cards.

6. Product details refinement.
   - Improve image, variant, price, and add-to-cart hierarchy.

7. Cart/checkout/payment refinement.
   - Improve trust, forms, totals, and action clarity.

8. Offers/loyalty/profile refinement.
   - Make secondary modules feel equally polished.

9. AI/messages/trends refinement.
   - Improve clarity and consistency without overclaiming intelligence.

10. Screenshot preparation.
   - Only after UI is stable.
   - Use fresh current screenshots.
   - Do not reuse old screenshots.

Each implementation batch should be small enough to review and revert safely.
