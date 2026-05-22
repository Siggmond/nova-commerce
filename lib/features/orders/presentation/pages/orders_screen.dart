import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nova_commerce/app/di/app_providers.dart';
import 'package:nova_commerce/app/config/app_env.dart';
import 'package:nova_commerce/app/router/app_routes.dart';
import 'package:nova_commerce/core/errors/app_error_mapper.dart';
import 'package:nova_commerce/core/widgets/error_state.dart';
import 'package:nova_commerce/core/widgets/nova_app_bar.dart';
import 'package:nova_commerce/core/widgets/nova_button.dart';
import 'package:nova_commerce/core/widgets/nova_surface.dart';
import 'package:nova_commerce/core/widgets/shimmer.dart';
import 'package:nova_commerce/features/orders/presentation/state/orders_controller.dart';
import 'package:nova_commerce/features/orders/presentation/widgets/order_status_ui.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersControllerProvider);
    final userAsync = ref.watch(authUserProvider);
    final useNovaUi = AppEnv.enableNovaUi;

    return Scaffold(
      appBar: useNovaUi
          ? NovaAppBar(titleText: 'Orders')
          : AppBar(title: const Text('Orders')),
      body: ordersAsync.when(
        loading: () => const _OrdersSkeleton(),
        error: (e, _) {
          final msg = mapAppError(e);
          return userAsync.when(
            loading: () => const _OrdersSkeleton(),
            error: (_, __) => AppErrorState(
              title: msg.title,
              subtitle: msg.subtitle,
              actionText: 'Retry',
              onAction: () => ref
                  .read(ordersControllerProvider.notifier)
                  .refresh(showLoading: true),
            ),
            data: (user) {
              if (user == null) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sign in to view your orders.',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        useNovaUi
                            ? NovaButton.primary(
                                onPressed: () => context.push(AppRoutes.signIn),
                                label: 'Sign in',
                              )
                            : FilledButton(
                                onPressed: () => context.push(AppRoutes.signIn),
                                child: const Text('Sign in'),
                              ),
                      ],
                    ),
                  ),
                );
              }
              return AppErrorState(
                title: msg.title,
                subtitle: msg.subtitle,
                actionText: 'Retry',
                onAction: () => ref
                    .read(ordersControllerProvider.notifier)
                    .refresh(showLoading: true),
              );
            },
          );
        },
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No orders yet.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    useNovaUi
                        ? NovaButton.primary(
                            onPressed: () => context.go(AppRoutes.home),
                            label: 'Start shopping',
                          )
                        : FilledButton(
                            onPressed: () => context.go(AppRoutes.home),
                            child: const Text('Start shopping'),
                          ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
            itemCount: orders.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final o = orders[index];
              final created = o.createdAt;
              final statusLabel = orderStatusLabel(o.status, o.statusRaw);
              final subtitle = created == null
                  ? 'Status: $statusLabel'
                  : '${created.toLocal()} • $statusLabel';

              final tile = ListTile(
                title: Text(
                  '${o.currency.toUpperCase()} ${o.total.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('${AppRoutes.orders}/${o.id}'),
              );

              if (useNovaUi) {
                return NovaSurface(padding: EdgeInsets.zero, child: tile);
              }

              return Card(child: tile);
            },
          );
        },
      ),
    );
  }
}

class _OrdersSkeleton extends StatelessWidget {
  const _OrdersSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return Shimmer(
          child: SkeletonBox(height: 76.h, radius: 14.r),
        );
      },
    );
  }
}
