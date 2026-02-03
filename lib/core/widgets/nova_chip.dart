import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import '../theme/nova_tokens.dart';

class NovaChip extends StatelessWidget {
  const NovaChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: enabled ? onSelected : null,
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: selected ? cs.primary : cs.onSurface.withValues(alpha: 0.85),
      ),
      selectedColor: cs.primary.withValues(alpha: 0.10),
      backgroundColor: NovaColors.sheetStrong(cs),
      side: BorderSide(
        color: selected
            ? cs.primary.withValues(alpha: 0.22)
            : cs.outlineVariant.withValues(alpha: 0.6),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NovaRadii.radiusPill),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpace.sm,
        vertical: AppSpace.xxs,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}
