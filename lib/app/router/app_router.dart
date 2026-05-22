import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../features/ai_assistant/ai_assistant.dart';
import '../../features/auth/auth.dart';
import '../../features/cart/cart.dart';
import '../../features/checkout/checkout.dart';
import '../../features/home/home.dart';
import '../../features/loyalty/loyalty.dart';
import '../../features/messages/messages.dart';
import '../../features/offers/offers.dart';
import '../../features/orders/orders.dart';
import '../../features/products/products.dart';
import '../../features/profile/profile.dart';
import '../../features/search/search.dart';
import '../../features/trends/trends.dart';
import '../../features/wishlist/wishlist.dart';
import '../../features/payments/payments.dart';
import '../perf/perf_route_screen.dart';
import '../perf/performance_engine.dart';
import '../perf/performance_runtime_hints.dart';
import '../startup/feature_init_once.dart';
import '../widgets/app_shell_container.dart';
import 'app_routes.dart';

Widget _perfScope({required GoRouterState state, required Widget child}) {
  final route = state.uri.path.trim();
  return PerformanceRouteScope(
    route: route.isEmpty ? AppRoutes.home : route,
    child: child,
  );
}

CustomTransitionPage<void> _fadeSlidePage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: _perfScope(state: state, child: child),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (!PerformanceRuntimeHints.allowRouteTransitions.value) {
        return child;
      }
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

class _ActiveBranchNavigatorContainer extends StatelessWidget {
  const _ActiveBranchNavigatorContainer({
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final maxIndex = children.length - 1;
    final index = currentIndex < 0
        ? 0
        : (currentIndex > maxIndex ? maxIndex : currentIndex);
    return KeyedSubtree(key: ValueKey<int>(index), child: children[index]);
  }
}

GoRouter createAppRouter({String initialLocation = AppRoutes.home}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final homeNavigatorKey = GlobalKey<NavigatorState>();
  final searchNavigatorKey = GlobalKey<NavigatorState>();
  final aiNavigatorKey = GlobalKey<NavigatorState>();
  final offersNavigatorKey = GlobalKey<NavigatorState>();
  final cartNavigatorKey = GlobalKey<NavigatorState>();
  final profileNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return AppShellContainer(navigationShell: navigationShell);
        },
        navigatorContainerBuilder: (context, navigationShell, children) {
          return _ActiveBranchNavigatorContainer(
            currentIndex: navigationShell.currentIndex,
            children: children,
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) {
                  initProductsFeatureOnce();
                  return _perfScope(state: state, child: const HomeV2Screen());
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: searchNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.search,
                builder: (context, state) {
                  initProductsFeatureOnce();
                  final initialQuery = state.uri.queryParameters['q'] ?? '';
                  return _perfScope(
                    state: state,
                    child: SearchScreen(initialQuery: initialQuery),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'collection/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return _perfScope(
                        state: state,
                        child: CollectionResultsScreen(collectionId: id),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: aiNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.ai,
                builder: (context, state) =>
                    _perfScope(state: state, child: const AiChatScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: offersNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.offers,
                builder: (context, state) =>
                    _perfScope(state: state, child: const OffersScreen()),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return _perfScope(
                        state: state,
                        child: OfferDetailsScreen(offerId: id),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: cartNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.cart,
                builder: (context, state) {
                  initCartFeatureOnce();
                  return _perfScope(state: state, child: const CartScreen());
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: profileNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) {
                  initAuthFeatureOnce();
                  return _perfScope(state: state, child: const ProfileScreen());
                },
              ),
              GoRoute(
                path: AppRoutes.profileDetails,
                pageBuilder: (context, state) {
                  initAuthFeatureOnce();
                  return _fadeSlidePage(
                    state: state,
                    child: const ProfileDetailsScreen(),
                  );
                },
              ),
              GoRoute(
                path: AppRoutes.profileAccountDetails,
                pageBuilder: (context, state) {
                  initAuthFeatureOnce();
                  return _fadeSlidePage(
                    state: state,
                    child: const ProfileAccountDetailsScreen(),
                  );
                },
              ),
              GoRoute(
                path: AppRoutes.wishlist,
                pageBuilder: (context, state) {
                  initAuthFeatureOnce();
                  return _fadeSlidePage(
                    state: state,
                    child: const WishlistScreen(),
                  );
                },
              ),
              GoRoute(
                path: AppRoutes.orders,
                pageBuilder: (context, state) {
                  initAuthFeatureOnce();
                  return _fadeSlidePage(
                    state: state,
                    child: const OrdersScreen(),
                  );
                },
                routes: [
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) {
                      initAuthFeatureOnce();
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
        path: AppRoutes.trends,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(state: state, child: const TrendsScreen());
        },
      ),
      GoRoute(
        path: AppRoutes.trendingNow,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(state: state, child: const TrendingNowScreen());
        },
      ),
      GoRoute(
        path: AppRoutes.pickedForYou,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const PickedForYouScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.product,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          initProductsFeatureOnce();
          final productId = state.uri.queryParameters['id'];
          return _fadeSlidePage(
            state: state,
            child: ProductDetailsScreen(productId: productId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.signIn,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          initAuthFeatureOnce();
          return _fadeSlidePage(state: state, child: const SignInScreen());
        },
      ),
      GoRoute(
        path: AppRoutes.messages,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(state: state, child: const MessagesScreen());
        },
      ),
      GoRoute(
        path: AppRoutes.checkout,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          initAuthFeatureOnce();
          initCartFeatureOnce();
          initCheckoutFeatureOnce();
          return _fadeSlidePage(state: state, child: const CheckoutScreen());
        },
      ),

      GoRoute(
        path: AppRoutes.payment,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          initCheckoutFeatureOnce();
          initCartFeatureOnce();
          final args = state.extra is PaymentFlowArgs
              ? state.extra as PaymentFlowArgs
              : null;
          return _fadeSlidePage(
            state: state,
            child: args == null
                ? const Scaffold(
                    body: Center(child: Text('Missing payment args')),
                  )
                : PaymentMethodScreen(args: args),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.paymentConfirm,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          initCheckoutFeatureOnce();
          final args = state.extra is PaymentConfirmArgs
              ? state.extra as PaymentConfirmArgs
              : null;
          return _fadeSlidePage(
            state: state,
            child: args == null
                ? const Scaffold(
                    body: Center(child: Text('Missing payment confirm args')),
                  )
                : PaymentConfirmScreen(args: args),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.paymentSuccess,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          initCheckoutFeatureOnce();
          final args = state.extra is PaymentSuccessArgs
              ? state.extra as PaymentSuccessArgs
              : null;
          return _fadeSlidePage(
            state: state,
            child: args == null
                ? const Scaffold(
                    body: Center(child: Text('Missing payment success args')),
                  )
                : PaymentSuccessScreen(args: args),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.paymentFailure,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          initCheckoutFeatureOnce();
          final message = state.extra is String ? state.extra as String : '';
          return _fadeSlidePage(
            state: state,
            child: PaymentFailureScreen(
              message: message.trim().isEmpty ? 'Payment failed.' : message,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.gold,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(state: state, child: const GoldScreen());
        },
      ),
      GoRoute(
        path: AppRoutes.goldPointsHistory,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const PointsHistoryScreen(),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.goldRewardDetails}/:id',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _fadeSlidePage(
            state: state,
            child: RewardDetailsScreen(rewardId: id),
          );
        },
      ),

      if (!kReleaseMode)
        GoRoute(
          path: '/__perf',
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (context, state) {
            return _fadeSlidePage(state: state, child: const PerfRouteScreen());
          },
        ),
      GoRoute(
        path: '${AppRoutes.orderSuccess}/:id',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          initCheckoutFeatureOnce();
          initAuthFeatureOnce();
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
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const Scaffold(body: Center(child: Text('Coming soon'))),
          );
        },
      ),
      GoRoute(
        path: '/brands',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const Scaffold(body: Center(child: Text('Coming soon'))),
          );
        },
      ),
      GoRoute(
        path: '/new-in',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const Scaffold(body: Center(child: Text('Coming soon'))),
          );
        },
      ),
      GoRoute(
        path: '/fall-winter',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const Scaffold(body: Center(child: Text('Coming soon'))),
          );
        },
      ),
      GoRoute(
        path: '/plus-size',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const Scaffold(body: Center(child: Text('Coming soon'))),
          );
        },
      ),
      GoRoute(
        path: '/fandom-faves',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const Scaffold(body: Center(child: Text('Coming soon'))),
          );
        },
      ),
      GoRoute(
        path: '/flash-flex',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const Scaffold(body: Center(child: Text('Coming soon'))),
          );
        },
      ),
      GoRoute(
        path: '/cotton',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const Scaffold(body: Center(child: Text('Coming soon'))),
          );
        },
      ),
      GoRoute(
        path: '/cotton-align',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          return _fadeSlidePage(
            state: state,
            child: const Scaffold(body: Center(child: Text('Coming soon'))),
          );
        },
      ),
      GoRoute(
        path: '/super-deals',
        parentNavigatorKey: rootNavigatorKey,
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
