import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

class AiPrivacyNote extends StatelessWidget {
  const AiPrivacyNote({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Padding(
          padding: AppInsets.cardTight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
              SizedBox(width: AppSpace.sm),
              Expanded(
                child: Text(
                  'Nova AI replies are generated and may be inaccurate. This demo does not provide citations. Your conversations are saved locally on this device and can be cleared anytime.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.75),
                        height: 1.25,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
