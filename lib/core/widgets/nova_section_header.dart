import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import '../theme/nova_tokens.dart';

class NovaSectionHeader extends StatelessWidget {
  const NovaSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: NovaText.sectionTitle(context)),
                if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                  SizedBox(height: AppSpace.xxs),
                  Text(subtitle!, style: NovaText.bodyMuted(context)),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: AppSpace.sm),
            IconTheme(
              data: IconThemeData(color: cs.primary.withValues(alpha: 0.90)),
              child: trailing!,
            ),
          ],
        ],
      ),
    );
  }
}
