import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color),
                SizedBox(height: 6.h),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        child: Column(
          children: [
            Row(
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
            SizedBox(height: 18.h),
            Expanded(
              child: Center(
                child: Text(
                  t.commonComingSoon,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface.withValues(alpha: 0.7),
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
