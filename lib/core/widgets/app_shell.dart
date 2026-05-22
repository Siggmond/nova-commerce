import 'package:flutter/material.dart';

import 'ai_animated_navbar.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.tabCount,
    required this.tabLabels,
    required this.cartCount,
    required this.suggestedIndex,
    required this.suggestedConfidence,
    required this.reduceAnimations,
    required this.onSelectTab,
  });

  final Widget body;
  final int currentIndex;
  final int tabCount;
  final List<String> tabLabels;
  final int cartCount;
  final int? suggestedIndex;
  final double? suggestedConfidence;
  final bool reduceAnimations;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: AiAnimatedNavBar(
        currentIndex: currentIndex,
        labels: tabLabels,
        cartCount: cartCount,
        suggestedIndex: suggestedIndex,
        suggestedConfidence: suggestedConfidence,
        reduceAnimations: reduceAnimations,
        onSelect: (index) {
          if (index < 0 || index >= tabCount) return;
          onSelectTab(index);
        },
      ),
    );
  }
}
