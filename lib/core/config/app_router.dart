import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/ai_assistant/presentation/ai_chat_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/orders/presentation/order_details_screen.dart';
import '../../features/orders/presentation/order_success_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/product/presentation/product_details_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/wishlist/presentation/wishlist_screen.dart';
import '../widgets/app_shell.dart';
import 'app_routes.dart';

CustomTransitionPage<void> _fadeSlidePage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.02),
        end: Offset.zero,
      ).animate(fade);
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.ai,
            builder: (context, state) => const AiChatScreen(),
          ),
          GoRoute(
            path: AppRoutes.cart,
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.product,
        pageBuilder: (context, state) {
          final productId = state.uri.queryParameters['id'];
          return _fadeSlidePage(
            state: state,
            child: ProductDetailsScreen(productId: productId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.signIn,
        pageBuilder: (context, state) {
          return _fadeSlidePage(state: state, child: const SignInScreen());
        },
      ),
      GoRoute(
        path: AppRoutes.checkout,
        pageBuilder: (context, state) {
          return _fadeSlidePage(state: state, child: const CheckoutScreen());
        },
      ),
      GoRoute(
        path: AppRoutes.orders,
        pageBuilder: (context, state) {
          return _fadeSlidePage(state: state, child: const OrdersScreen());
        },
        routes: [
          GoRoute(
            path: ':id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'];
              return _fadeSlidePage(
                state: state,
                child: OrderDetailsScreen(orderId: id ?? ''),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '${AppRoutes.orderSuccess}/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'];
          return _fadeSlidePage(
            state: state,
            child: OrderSuccessScreen(orderId: id ?? ''),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.wishlist,
        pageBuilder: (context, state) {
          return _fadeSlidePage(state: state, child: const WishlistScreen());
        },
      ),
    ],
  );
});
