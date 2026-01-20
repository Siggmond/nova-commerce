import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_routes.dart';
import '../../../core/config/auth_providers.dart';
import '../../../core/errors/app_error_mapper.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/shimmer.dart';
import '../../../data/datasources/device_id_datasource.dart';
import '../../../domain/entities/order.dart' as domain;

final deviceIdProvider = FutureProvider<String>((ref) async {
  return DeviceIdDataSource().getOrCreate();
});

final ordersProvider = StreamProvider<List<domain.Order>>((ref) {
  final userAsync = ref.watch(authStateProvider);
  final deviceIdAsync = ref.watch(deviceIdProvider);

  return userAsync.when(
    loading: () => const Stream<List<domain.Order>>.empty(),
    error: (_, __) => const Stream<List<domain.Order>>.empty(),
    data: (user) {
      return deviceIdAsync.when(
        loading: () => const Stream<List<domain.Order>>.empty(),
        error: (_, __) => const Stream<List<domain.Order>>.empty(),
        data: (deviceId) {
          final orders = FirebaseFirestore.instance.collection('orders');
          final q = user == null
              ? orders.where('deviceId', isEqualTo: deviceId)
              : orders.where('uid', isEqualTo: user.uid);

          return q.snapshots().map((snap) {
            final list = snap.docs
                .map(domain.Order.fromDoc)
                .toList(growable: true);
            list.sort((a, b) {
              final aTime =
                  a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bTime =
                  b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return bTime.compareTo(aTime);
            });
            return list;
          });
        },
      );
    },
  );
});

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);
    final userAsync = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
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
              onAction: () => ref.invalidate(ordersProvider),
            ),
            data: (user) {
              if (user == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sign in to view your orders.',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
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
                onAction: () => ref.invalidate(ordersProvider),
              );
            },
          );
        },
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No orders yet.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final o = orders[index];
              final created = o.createdAt;
              final subtitle = created == null
                  ? 'Status: ${o.status}'
                  : '${created.toLocal()} • ${o.status}';

              return Card(
                child: ListTile(
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
                ),
              );
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return const Shimmer(child: SkeletonBox(height: 76, radius: 14));
      },
    );
  }
}
