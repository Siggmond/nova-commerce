import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import '../../app/theme/nova_tokens.dart';

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
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      selected: selected,
      onSelected: enabled ? onSelected : null,
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
        color: enabled
            ? (selected ? cs.primary : cs.onSurface.withValues(alpha: 0.82))
            : cs.onSurface.withValues(alpha: 0.42),
      ),
      selectedColor: cs.primary.withValues(alpha: 0.10),
      backgroundColor: NovaColors.sheetStrong(cs),
      side: BorderSide(
        color: selected
            ? cs.primary.withValues(alpha: 0.22)
            : cs.outlineVariant.withValues(alpha: 0.55),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NovaRadii.radiusPill),
      ),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.xxs,
      ),
      visualDensity: VisualDensity.standard,
      showCheckmark: false,
    );
  }
}
