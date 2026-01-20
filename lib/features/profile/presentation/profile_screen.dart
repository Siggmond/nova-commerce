import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/config/app_env.dart';
import '../../../core/config/auth_providers.dart';
import '../../../core/config/performance_mode.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final userAsync = ref.watch(authStateProvider);
    final perfEnabled = kDebugMode ? ref.watch(performanceModeProvider) : false;
    return Scaffold(
      appBar: AppBar(title: const Text('You')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
        children: [
          userAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (user) {
              if (user == null) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text('Sign in'),
                    subtitle: const Text('Sync orders across devices'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.signIn),
                  ),
                );
              }

              final label = user.isAnonymous
                  ? 'Guest session'
                  : (user.email?.trim().isNotEmpty == true
                        ? user.email!
                        : 'Signed in');

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.verified_user_outlined),
                  title: Text(label),
                  subtitle: Text(
                    user.isAnonymous
                        ? 'You can create an account anytime.'
                        : 'UID: ${user.uid}',
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: const Text('Sign out'),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 12.h),
          Card(
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.10),
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.primary.withValues(alpha: 0.28),
                          cs.primary.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12.r),
                      child: Icon(Icons.person, size: 28.r),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your control center',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Wishlist, preferences, and order shortcuts.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'Quick actions',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 10.h),
          Card(
            child: ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Wishlist'),
              subtitle: const Text('Saved items'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.wishlist),
            ),
          ),
          SizedBox(height: 12.h),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Orders'),
              subtitle: const Text('Track what you bought'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.orders),
            ),
          ),
          SizedBox(height: 12.h),
          Card(
            child: ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Preferences'),
              subtitle: const Text('Sizes, style, and budget (coming soon)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preferences coming soon')),
                );
              },
            ),
          ),
          if (kDebugMode) ...[
            SizedBox(height: 12.h),
            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.speed),
                value: perfEnabled,
                title: const Text('Performance mode'),
                subtitle: const Text(
                  'Overlay + rebuild/layout/paint profiling',
                ),
                onChanged: (v) =>
                    ref.read(performanceModeProvider.notifier).setEnabled(v),
              ),
            ),
            SizedBox(height: 12.h),
            Card(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diagnostics',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _DiagnosticsRow(
                      label: 'Firestore emulator',
                      value: AppEnv.useFirestoreEmulator
                          ? 'enabled'
                          : 'disabled',
                    ),
                    _DiagnosticsRow(
                      label: 'Firestore host',
                      value: '${AppEnv.firestoreHost}:${AppEnv.firestorePort}',
                    ),
                    userAsync.when(
                      loading: () => const _DiagnosticsRow(
                        label: 'Auth',
                        value: 'loading...',
                      ),
                      error: (_, __) =>
                          const _DiagnosticsRow(label: 'Auth', value: 'error'),
                      data: (user) {
                        if (user == null) {
                          return const _DiagnosticsRow(
                            label: 'Auth',
                            value: 'signed out',
                          );
                        }
                        final type = user.isAnonymous
                            ? 'anonymous'
                            : (user.providerData.isNotEmpty
                                  ? user.providerData.first.providerId
                                  : 'signed in');
                        return _DiagnosticsRow(
                          label: 'Auth',
                          value: '$type | uid: ${user.uid}',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DiagnosticsRow extends StatelessWidget {
  const _DiagnosticsRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.w,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
