import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:nova_commerce/app/theme/app_tokens.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

class AiPrivacyNote extends StatelessWidget {
  const AiPrivacyNote({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 6.h),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.34)),
        ),
        child: Padding(
          padding: AppInsets.cardTight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
                ),
                child: Icon(Icons.info_outline, size: 18.r, color: cs.primary),
              ),
              SizedBox(width: AppSpace.sm),
              Expanded(
                child: Text(
                  t.aiChatPrivacyNote,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.78),
                    height: 1.32,
                    fontWeight: FontWeight.w600,
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
