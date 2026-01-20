import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../config/app_routes.dart';
import '../../features/cart/presentation/cart_viewmodel.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static int _locationToIndex(String location) {
    if (location.startsWith(AppRoutes.ai)) return 1;
    if (location.startsWith(AppRoutes.cart)) return 2;
    if (location.startsWith(AppRoutes.profile)) return 3;
    return 0;
  }

  static String _indexToLocation(int index) {
    switch (index) {
      case 1:
        return AppRoutes.ai;
      case 2:
        return AppRoutes.cart;
      case 3:
        return AppRoutes.profile;
      case 0:
      default:
        return AppRoutes.home;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = GoRouterState.of(context);
    final currentIndex = _locationToIndex(state.uri.toString());
    final cartCount = ref
        .watch(cartViewModelProvider)
        .fold<int>(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          final location = _indexToLocation(index);
          if (location == state.uri.toString()) return;
          context.go(location);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Shop',
          ),
          const NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI',
          ),
          NavigationDestination(
            icon: _CartIcon(count: cartCount, selected: false),
            selectedIcon: _CartIcon(count: cartCount, selected: true),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
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
