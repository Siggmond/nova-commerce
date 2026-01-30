import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget item({
      required int index,
      required IconData icon,
      required String label,
    }) {
      final isSelected = _selected == index;
      final color = isSelected ? cs.primary : cs.onSurface.withValues(alpha: 0.72);

      return Expanded(
        child: InkWell(
          onTap: () => setState(() => _selected = index),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color),
                const SizedBox(height: 6),
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
        title: const Text('Messages'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          children: [
            Row(
              children: [
                item(index: 0, icon: Icons.receipt_long, label: 'Order'),
                item(index: 1, icon: Icons.notifications_none, label: 'Activity'),
                item(index: 2, icon: Icons.local_offer_outlined, label: 'Promo'),
                item(index: 3, icon: Icons.newspaper_outlined, label: 'News'),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Center(
                child: Text(
                  'Coming soon',
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
