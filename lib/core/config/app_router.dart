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
import '../../features/checkout/domain/checkout_cart_summary.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/product/presentation/product_details_screen.dart';
import '../../features/trends/presentation/trends_screen.dart';
import '../../features/profile/presentation/profile_details_screen.dart';
import '../../features/profile/presentation/profile_account_details_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/messages/presentation/messages_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/wishlist/presentation/wishlist_screen.dart';
import '../widgets/app_shell.dart';
import 'app_env.dart';
import 'app_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>();
final _aiNavigatorKey = GlobalKey<NavigatorState>();
final _trendsNavigatorKey = GlobalKey<NavigatorState>();
final _cartNavigatorKey = GlobalKey<NavigatorState>();
final _profileNavigatorKey = GlobalKey<NavigatorState>();

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

GoRouter createAppRouter({String initialLocation = AppRoutes.home}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _aiNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.ai,
                builder: (context, state) => const AiChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _trendsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.trends,
                builder: (context, state) => const TrendsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _cartNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.cart,
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: AppRoutes.profileDetails,
                pageBuilder: (context, state) {
                  return _fadeSlidePage(
                    state: state,
                    child: const ProfileDetailsScreen(),
                  );
                },
              ),
              GoRoute(
                path: AppRoutes.profileAccountDetails,
                pageBuilder: (context, state) {
                  final enableRedesign =
                      AppEnv.enableNovaUi && AppEnv.enableNovaUiProfileDetails;
                  return _fadeSlidePage(
                    state: state,
                    child: enableRedesign
                        ? const ProfileAccountDetailsScreen()
                        : const ProfileDetailsScreen(),
                  );
                },
              ),
              GoRoute(
                path: AppRoutes.wishlist,
                pageBuilder: (context, state) {
                  return _fadeSlidePage(
                    state: state,
                    child: const WishlistScreen(),
                  );
                },
              ),
              GoRoute(
                path: AppRoutes.orders,
                pageBuilder: (context, state) {
                  return _fadeSlidePage(
                    state: state,
                    child: const OrdersScreen(),
                  );
                },
                routes: [
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      if (id.trim().isEmpty) {
                        return _fadeSlidePage(
                          state: state,
                          child: const OrdersScreen(),
                        );
                      }
                      return _fadeSlidePage(
                        state: state,
                        child: OrderDetailsScreen(orderId: id),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.search,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final initialQuery = state.uri.queryParameters['q'] ?? '';
          return _fadeSlidePage(
            state: state,
            child: SearchScreen(initialQuery: initialQuery),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.product,
        parentNavigatorKey: _rootNavigatorKey,
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
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(state: state, child: const SignInScreen());
        },
      ),
      GoRoute(
        path: AppRoutes.messages,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(state: state, child: const MessagesScreen());
        },
      ),
      GoRoute(
        path: AppRoutes.checkout,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(state: state, child: const CheckoutScreen());
        },
      ),
      GoRoute(
        path: '${AppRoutes.orderSuccess}/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'];
          final summary = state.extra is CheckoutCartSummary
              ? state.extra as CheckoutCartSummary
              : null;
          return _fadeSlidePage(
            state: state,
            child: OrderSuccessScreen(orderId: id ?? '', summary: summary),
          );
        },
      ),

      GoRoute(
        path: '/browse',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const Scaffold(body: Center(child: Text('Coming soon'))),
          );
        },
      ),
      GoRoute(
        path: '/brands',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const Scaffold(body: Center(child: Text('Coming soon'))),
          );
        },
      ),
      GoRoute(
        path: '/new-in',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const Scaffold(body: Center(child: Text('Coming soon'))),
          );
        },
      ),
      GoRoute(
        path: '/fall-winter',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const Scaffold(body: Center(child: Text('Coming soon'))),
          );
        },
      ),
      GoRoute(
        path: '/plus-size',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const Scaffold(body: Center(child: Text('Coming soon'))),
          );
        },
      ),
      GoRoute(
        path: '/fandom-faves',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const Scaffold(body: Center(child: Text('Coming soon'))),
          );
        },
      ),
      GoRoute(
        path: '/flash-flex',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const Scaffold(body: Center(child: Text('Coming soon'))),
          );
        },
      ),
      GoRoute(
        path: '/cotton',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const Scaffold(body: Center(child: Text('Coming soon'))),
          );
        },
      ),
      GoRoute(
        path: '/cotton-align',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const Scaffold(body: Center(child: Text('Coming soon'))),
          );
        },
      ),
      GoRoute(
        path: '/super-deals',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const Scaffold(body: Center(child: Text('Coming soon'))),
          );
        },
      ),
    ],
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return createAppRouter();
});
