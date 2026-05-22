import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const int _tabShop = 0;
const int _tabSearch = 1;
const int _tabAi = 2;
const int _tabOffers = 3;
const int _tabCart = 4;
const int _tabAccount = 5;

const List<BoxShadow> _navBarShadows = <BoxShadow>[
  BoxShadow(color: Color(0x1A000000), blurRadius: 24, offset: Offset(0, -10)),
];

enum _AiSuggestionMode { none, glow, pulse, strong }

class AiAnimatedNavBar extends StatefulWidget {
  const AiAnimatedNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    required this.labels,
    required this.cartCount,
    required this.suggestedIndex,
    required this.suggestedConfidence,
    required this.reduceAnimations,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  final List<String> labels;

  final int cartCount;

  final int? suggestedIndex;

  final double? suggestedConfidence;
  final bool reduceAnimations;

  @override
  State<AiAnimatedNavBar> createState() => _AiAnimatedNavBarState();
}

class _AiAnimatedNavBarState extends State<AiAnimatedNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  _AiSuggestionMode get _mode {
    final index = widget.suggestedIndex;
    if (index == null) return _AiSuggestionMode.none;

    final c = (widget.suggestedConfidence ?? 0.0).clamp(0.0, 1.0).toDouble();
    if (c < 0.35) return _AiSuggestionMode.none;
    if (widget.reduceAnimations) return _AiSuggestionMode.glow;
    if (c < 0.45) return _AiSuggestionMode.glow;
    if (c < 0.60) return _AiSuggestionMode.pulse;
    return _AiSuggestionMode.strong;
  }

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant AiAnimatedNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.suggestedIndex != widget.suggestedIndex ||
        oldWidget.suggestedConfidence != widget.suggestedConfidence ||
        oldWidget.reduceAnimations != widget.reduceAnimations) {
      _syncPulse();
    }
  }

  void _syncPulse() {
    final mode = _mode;
    if (mode != _AiSuggestionMode.pulse && mode != _AiSuggestionMode.strong) {
      _pulse.stop();
      _pulse.value = 0;
    } else {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mode = _mode;
    final effectiveSuggestedIndex = mode == _AiSuggestionMode.none
        ? null
        : widget.suggestedIndex;
    final confidence = (widget.suggestedConfidence ?? 0.0)
        .clamp(0.0, 1.0)
        .toDouble();

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 62.h,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surface,
            boxShadow: _navBarShadows,
          ),
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final t = Curves.easeInOut.transform(_pulse.value);
              return Row(
                children: [
                  _Item(
                    tabKey: const Key('nav_tab_shop'),
                    label: widget.labels[_tabShop],
                    selected: widget.currentIndex == _tabShop,
                    suggested: effectiveSuggestedIndex == _tabShop,
                    suggestionMode: mode,
                    confidence: confidence,
                    pulseT: t,
                    reduceAnimations: widget.reduceAnimations,
                    accent: cs.primary,
                    onTap: () => widget.onSelect(_tabShop),
                    icon: Icons.storefront_outlined,
                    selectedIcon: Icons.storefront,
                  ),
                  _Item(
                    tabKey: const Key('nav_tab_search'),
                    label: widget.labels[_tabSearch],
                    selected: widget.currentIndex == _tabSearch,
                    suggested: effectiveSuggestedIndex == _tabSearch,
                    suggestionMode: mode,
                    confidence: confidence,
                    pulseT: t,
                    reduceAnimations: widget.reduceAnimations,
                    accent: cs.primary,
                    onTap: () => widget.onSelect(_tabSearch),
                    icon: Icons.search_outlined,
                    selectedIcon: Icons.search,
                  ),
                  _Item(
                    tabKey: const Key('nav_tab_ai'),
                    label: widget.labels[_tabAi],
                    selected: widget.currentIndex == _tabAi,
                    suggested: effectiveSuggestedIndex == _tabAi,
                    suggestionMode: mode,
                    confidence: confidence,
                    pulseT: t,
                    reduceAnimations: widget.reduceAnimations,
                    accent: cs.primary,
                    onTap: () => widget.onSelect(_tabAi),
                    icon: Icons.auto_awesome_outlined,
                    selectedIcon: Icons.auto_awesome,
                  ),
                  _Item(
                    tabKey: const Key('nav_tab_offers'),
                    label: widget.labels[_tabOffers],
                    selected: widget.currentIndex == _tabOffers,
                    suggested: effectiveSuggestedIndex == _tabOffers,
                    suggestionMode: mode,
                    confidence: confidence,
                    pulseT: t,
                    reduceAnimations: widget.reduceAnimations,
                    accent: cs.primary,
                    onTap: () => widget.onSelect(_tabOffers),
                    icon: Icons.local_offer_outlined,
                    selectedIcon: Icons.local_offer,
                  ),
                  _Item(
                    tabKey: const Key('nav_tab_cart'),
                    label: widget.labels[_tabCart],
                    selected: widget.currentIndex == _tabCart,
                    suggested: effectiveSuggestedIndex == _tabCart,
                    suggestionMode: mode,
                    confidence: confidence,
                    pulseT: t,
                    reduceAnimations: widget.reduceAnimations,
                    accent: cs.primary,
                    onTap: () => widget.onSelect(_tabCart),
                    iconWidget: _CartIcon(
                      count: widget.cartCount,
                      selected: widget.currentIndex == _tabCart,
                      reduceAnimations: widget.reduceAnimations,
                    ),
                  ),
                  _Item(
                    tabKey: const Key('nav_tab_account'),
                    label: widget.labels[_tabAccount],
                    selected: widget.currentIndex == _tabAccount,
                    suggested: effectiveSuggestedIndex == _tabAccount,
                    suggestionMode: mode,
                    confidence: confidence,
                    pulseT: t,
                    reduceAnimations: widget.reduceAnimations,
                    accent: cs.primary,
                    onTap: () => widget.onSelect(_tabAccount),
                    icon: Icons.person_outline,
                    selectedIcon: Icons.person,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.tabKey,
    required this.label,
    required this.selected,
    required this.suggested,
    required this.suggestionMode,
    required this.confidence,
    required this.pulseT,
    required this.reduceAnimations,
    required this.accent,
    required this.onTap,
    this.icon,
    this.selectedIcon,
    this.iconWidget,
  });

  final Key tabKey;
  final String label;
  final bool selected;
  final bool suggested;
  final _AiSuggestionMode suggestionMode;
  final double confidence;
  final double pulseT;
  final bool reduceAnimations;
  final Color accent;
  final VoidCallback onTap;

  final IconData? icon;
  final IconData? selectedIcon;
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final intensity = suggested
        ? (reduceAnimations
              ? 0.08
              : switch (suggestionMode) {
                  _AiSuggestionMode.glow =>
                    (0.10 + 0.06 * ((confidence - 0.35) / 0.10).clamp(0.0, 1.0))
                        .toDouble(),
                  _AiSuggestionMode.pulse =>
                    (0.12 + 0.10 * ((confidence - 0.45) / 0.15).clamp(0.0, 1.0))
                            .toDouble() *
                        (0.35 + 0.65 * pulseT),
                  _AiSuggestionMode.strong =>
                    (0.22 + 0.18 * ((confidence - 0.60) / 0.40).clamp(0.0, 1.0))
                            .toDouble() *
                        (0.45 + 0.55 * pulseT),
                  _AiSuggestionMode.none => 0.0,
                })
        : 0.0;

    final scale = reduceAnimations
        ? 1.0
        : (selected
              ? 1.07
              : (suggested && suggestionMode == _AiSuggestionMode.strong
                    ? 1.03
                    : 1.0));

    final iconColor = selected
        ? cs.onSurface
        : cs.onSurface.withValues(alpha: 0.72);

    final baseIcon =
        iconWidget ??
        Icon(
          selected ? (selectedIcon ?? icon) : icon,
          color: iconColor,
          size: 22.r,
        );

    return Expanded(
      child: InkWell(
        key: tabKey,
        onTap: onTap,
        child: Center(
          child: AnimatedScale(
            duration: reduceAnimations
                ? Duration.zero
                : const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            scale: scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999.r),
                    boxShadow: intensity <= 0
                        ? const []
                        : [
                            BoxShadow(
                              blurRadius: 18.r,
                              spreadRadius: 1.r,
                              offset: Offset(0, 6.h),
                              color: accent.withValues(alpha: intensity),
                            ),
                          ],
                  ),
                  child: baseIcon,
                ),
                SizedBox(height: 6.h),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? cs.onSurface
                        : cs.onSurface.withValues(alpha: 0.70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartIcon extends StatelessWidget {
  const _CartIcon({
    required this.count,
    required this.selected,
    required this.reduceAnimations,
  });

  final int count;
  final bool selected;
  final bool reduceAnimations;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final base = Icon(
      selected ? Icons.shopping_cart : Icons.shopping_cart_outlined,
    );
    if (count <= 0) return base;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        base,
        Positioned(
          top: (-4).h,
          right: (-6).w,
          child: AnimatedContainer(
            duration: reduceAnimations
                ? Duration.zero
                : const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: cs.surface, width: 1.5),
              boxShadow: [
                BoxShadow(
                  blurRadius: 14.r,
                  offset: Offset(0, 8.h),
                  color: Colors.black.withValues(alpha: 0.22),
                ),
              ],
            ),
            child: Text(
              count > 99 ? '99+' : '$count',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
