import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova_commerce/app/theme/app_tokens.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    Widget item({
      required int index,
      required IconData icon,
      required String label,
    }) {
      final isSelected = _selected == index;
      final color = isSelected
          ? cs.primary
          : cs.onSurface.withValues(alpha: 0.72);

      return Expanded(
        child: InkWell(
          onTap: () => setState(() => _selected = index),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            constraints: BoxConstraints(minHeight: AppHitTargets.comfortable),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? cs.primary.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: isSelected
                    ? cs.primary.withValues(alpha: 0.18)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 21.r),
                SizedBox(height: AppSpace.xs),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: color,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final selectedLabels = [
      t.messagesTabOrder,
      t.messagesTabActivity,
      t.messagesTabPromo,
      t.messagesTabNews,
    ];
    final selectedIcons = [
      Icons.receipt_long,
      Icons.notifications_none,
      Icons.local_offer_outlined,
      Icons.newspaper_outlined,
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        title: Text(t.messagesTitle),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
        child: Column(
          children: [
            Material(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(AppRadii.xl),
              child: Padding(
                padding: EdgeInsets.all(4.r),
                child: Row(
                  children: [
                    item(
                      index: 0,
                      icon: Icons.receipt_long,
                      label: t.messagesTabOrder,
                    ),
                    item(
                      index: 1,
                      icon: Icons.notifications_none,
                      label: t.messagesTabActivity,
                    ),
                    item(
                      index: 2,
                      icon: Icons.local_offer_outlined,
                      label: t.messagesTabPromo,
                    ),
                    item(
                      index: 3,
                      icon: Icons.newspaper_outlined,
                      label: t.messagesTabNews,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpace.xl),
            Expanded(
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.34),
                    ),
                  ),
                  child: Padding(
                    padding: AppInsets.state,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 62.r,
                          height: 62.r,
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            border: Border.all(
                              color: cs.primary.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Icon(
                            selectedIcons[_selected],
                            color: cs.primary,
                            size: 28.r,
                          ),
                        ),
                        SizedBox(height: AppSpace.md),
                        Text(
                          selectedLabels[_selected],
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpace.xs),
                        Text(
                          t.commonComingSoon,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface.withValues(alpha: 0.68),
                                height: 1.28,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
