import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum _AiSuggestionMode { none, glow, pulse, strong }

class AiAnimatedNavBar extends StatefulWidget {
  const AiAnimatedNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    required this.cartCount,
    required this.suggestedIndex,
    required this.suggestedConfidence,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  final int cartCount;

  final int? suggestedIndex;

  final double? suggestedConfidence;

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
        oldWidget.suggestedConfidence != widget.suggestedConfidence) {
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
            boxShadow: [
              BoxShadow(
                blurRadius: 24.r,
                offset: Offset(0, -10.h),
                color: Colors.black.withValues(alpha: 0.10),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final t = Curves.easeInOut.transform(_pulse.value);
              return Row(
                children: [
                  _Item(
                    label: 'Shop',
                    selected: widget.currentIndex == 0,
                    suggested: effectiveSuggestedIndex == 0,
                    suggestionMode: mode,
                    confidence: confidence,
                    pulseT: t,
                    accent: cs.primary,
                    onTap: () => widget.onSelect(0),
                    icon: Icons.storefront_outlined,
                    selectedIcon: Icons.storefront,
                  ),
                  _Item(
                    label: 'AI',
                    selected: widget.currentIndex == 1,
                    suggested: effectiveSuggestedIndex == 1,
                    suggestionMode: mode,
                    confidence: confidence,
                    pulseT: t,
                    accent: cs.primary,
                    onTap: () => widget.onSelect(1),
                    icon: Icons.auto_awesome_outlined,
                    selectedIcon: Icons.auto_awesome,
                  ),
                  _Item(
                    label: 'Trends',
                    selected: widget.currentIndex == 2,
                    suggested: effectiveSuggestedIndex == 2,
                    suggestionMode: mode,
                    confidence: confidence,
                    pulseT: t,
                    accent: cs.primary,
                    onTap: () => widget.onSelect(2),
                    icon: Icons.trending_up_outlined,
                    selectedIcon: Icons.trending_up,
                  ),
                  _Item(
                    label: 'Cart',
                    selected: widget.currentIndex == 3,
                    suggested: effectiveSuggestedIndex == 3,
                    suggestionMode: mode,
                    confidence: confidence,
                    pulseT: t,
                    accent: cs.primary,
                    onTap: () => widget.onSelect(3),
                    iconWidget: _CartIcon(
                      count: widget.cartCount,
                      selected: widget.currentIndex == 3,
                    ),
                  ),
                  _Item(
                    label: 'Profile',
                    selected: widget.currentIndex == 4,
                    suggested: effectiveSuggestedIndex == 4,
                    suggestionMode: mode,
                    confidence: confidence,
                    pulseT: t,
                    accent: cs.primary,
                    onTap: () => widget.onSelect(4),
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
    required this.label,
    required this.selected,
    required this.suggested,
    required this.suggestionMode,
    required this.confidence,
    required this.pulseT,
    required this.accent,
    required this.onTap,
    this.icon,
    this.selectedIcon,
    this.iconWidget,
  });

  final String label;
  final bool selected;
  final bool suggested;
  final _AiSuggestionMode suggestionMode;
  final double confidence;
  final double pulseT;
  final Color accent;
  final VoidCallback onTap;

  final IconData? icon;
  final IconData? selectedIcon;
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final intensity = suggested
        ? switch (suggestionMode) {
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
          }
        : 0.0;

    final scale = selected
        ? 1.07
        : (suggested && suggestionMode == _AiSuggestionMode.strong
              ? 1.03
              : 1.0);

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
        onTap: onTap,
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 180),
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
  const _CartIcon({required this.count, required this.selected});

  final int count;
  final bool selected;

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
            duration: const Duration(milliseconds: 220),
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
