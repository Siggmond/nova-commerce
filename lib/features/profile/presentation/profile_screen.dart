import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/config/app_env.dart';
import '../../../core/config/auth_providers.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/nova_app_bar.dart';
import '../../../core/widgets/nova_button.dart';
import '../../../core/widgets/nova_surface.dart';
import '../../../core/config/theme_mode_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final userAsync = ref.watch(authUserProvider);
    final user = userAsync.valueOrNull;
    final authRepo = ref.read(authRepositoryProvider);
    final themeMode = ref.watch(themeModeProvider);

    final useNovaUi = AppEnv.enableNovaUi && AppEnv.enableNovaUiProfile;
    Future<void> confirmSignOut() async {
      final shouldSignOut = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Sign out?'),
            content: const Text('You can sign back in anytime.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sign out'),
              ),
            ],
          );
        },
      );

      if (shouldSignOut == true) {
        await authRepo.signOut();
      }
    }

    String themeLabel(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.light:
          return 'Light';
        case ThemeMode.dark:
          return 'Dark';
        case ThemeMode.system:
          return 'System';
      }
    }

    final listTileTheme = ListTileThemeData(
      dense: true,
      visualDensity: const VisualDensity(horizontal: -1, vertical: -2),
      minLeadingWidth: 28,
      horizontalTitleGap: 12,
    );

    return Scaffold(
      appBar: useNovaUi
          ? NovaAppBar(titleText: 'You')
          : AppBar(title: const Text('You')),
      body: ListTileTheme(
        data: listTileTheme,
        child: IconTheme.merge(
          data: const IconThemeData(size: 18),
          child: ListView(
            padding: useNovaUi
                ? AppInsets.screen
                : EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 16.h),
            children: [
              userAsync.when(
                loading: () => _ProfileHeaderSkeleton(useNovaUi: useNovaUi),
                error: (_, __) => _SignedOutCard(useNovaUi: useNovaUi),
                data: (value) => value == null
                    ? _SignedOutCard(useNovaUi: useNovaUi)
                    : _SignedInCard(
                        useNovaUi: useNovaUi,
                        isAnonymous: value.isAnonymous,
                        email: (value.email ?? '').trim(),
                        onSignOut: () async {
                          await confirmSignOut();
                        },
                      ),
              ),
              SizedBox(height: useNovaUi ? AppSpace.sm : 12.h),
              if (user != null) ...[
                (useNovaUi
                    ? NovaSurface(
                        padding: AppInsets.card,
                        child: _AccountHubHeader(cs: cs),
                      )
                    : Card(
                        elevation: 2,
                        shadowColor: Colors.black.withValues(alpha: 0.10),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
                          child: _AccountHubHeader(cs: cs),
                        ),
                      )),
                SizedBox(height: useNovaUi ? AppSpace.sm : 12.h),
                _SectionTitle(
                  title: 'Account',
                  useNovaUi: useNovaUi,
                ),
                SizedBox(height: useNovaUi ? AppSpace.xs : 8.h),
                (useNovaUi
                    ? NovaSurface(
                        child: ListTile(
                          leading: const Icon(Icons.manage_accounts_outlined),
                          title: const Text('Account details'),
                          subtitle: const Text('Profile info and verification'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            final enableRedesign = AppEnv.enableNovaUi &&
                                AppEnv.enableNovaUiProfileDetails;
                            context.push(
                              enableRedesign
                                  ? AppRoutes.profileAccountDetails
                                  : AppRoutes.profileDetails,
                            );
                          },
                        ),
                      )
                    : Card(
                        child: ListTile(
                          leading: const Icon(Icons.manage_accounts_outlined),
                          title: const Text('Account details'),
                          subtitle: const Text('Profile info and verification'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            final enableRedesign = AppEnv.enableNovaUi &&
                                AppEnv.enableNovaUiProfileDetails;
                            context.push(
                              enableRedesign
                                  ? AppRoutes.profileAccountDetails
                                  : AppRoutes.profileDetails,
                            );
                          },
                        ),
                      )),
                SizedBox(height: useNovaUi ? AppSpace.sm : 12.h),
                _SectionTitle(
                  title: 'About this build',
                  useNovaUi: useNovaUi,
                ),
                SizedBox(height: useNovaUi ? AppSpace.xs : 8.h),
                (useNovaUi
                    ? NovaSurface(
                        padding: AppInsets.card,
                        child: Column(
                          children: const [
                            _BuildStatusRow(
                              title: 'Telemetry',
                              subtitle: 'Set by build configuration',
                              enabled: AppEnv.enableTelemetry,
                            ),
                            SizedBox(height: 8),
                            _BuildStatusRow(
                              title: 'Personalization',
                              subtitle: 'Set by build configuration',
                              enabled: AppEnv.enableHomePersonalization,
                            ),
                          ],
                        ),
                      )
                    : Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          child: Column(
                            children: const [
                              _BuildStatusRow(
                                title: 'Telemetry',
                                subtitle: 'Set by build configuration',
                                enabled: AppEnv.enableTelemetry,
                              ),
                              SizedBox(height: 8),
                              _BuildStatusRow(
                                title: 'Personalization',
                                subtitle: 'Set by build configuration',
                                enabled: AppEnv.enableHomePersonalization,
                              ),
                            ],
                          ),
                        ),
                      )),
              ],
              _SectionTitle(
                title: 'Orders & saved',
                useNovaUi: useNovaUi,
              ),
              SizedBox(height: useNovaUi ? AppSpace.xs : 8.h),
              _SecondaryLinksBlock(useNovaUi: useNovaUi),
              SizedBox(height: useNovaUi ? AppSpace.sm : 12.h),

              _SectionTitle(
                title: 'Preferences',
                useNovaUi: useNovaUi,
              ),
              SizedBox(height: useNovaUi ? AppSpace.xs : 8.h),
              (useNovaUi
                  ? NovaSurface(
                      padding: AppInsets.card,
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.brightness_6_outlined),
                            title: const Text('Theme'),
                            subtitle: Text(themeLabel(themeMode)),
                            trailing: DropdownButtonHideUnderline(
                              child: DropdownButton<ThemeMode>(
                                value: themeMode,
                                items: const [
                                  DropdownMenuItem(
                                    value: ThemeMode.system,
                                    child: Text('System'),
                                  ),
                                  DropdownMenuItem(
                                    value: ThemeMode.light,
                                    child: Text('Light'),
                                  ),
                                  DropdownMenuItem(
                                    value: ThemeMode.dark,
                                    child: Text('Dark'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value == null) return;
                                  ref.read(themeModeProvider.notifier).state =
                                      value;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.brightness_6_outlined),
                            title: const Text('Theme'),
                            subtitle: Text(themeLabel(themeMode)),
                            trailing: DropdownButtonHideUnderline(
                              child: DropdownButton<ThemeMode>(
                                value: themeMode,
                                items: const [
                                  DropdownMenuItem(
                                    value: ThemeMode.system,
                                    child: Text('System'),
                                  ),
                                  DropdownMenuItem(
                                    value: ThemeMode.light,
                                    child: Text('Light'),
                                  ),
                                  DropdownMenuItem(
                                    value: ThemeMode.dark,
                                    child: Text('Dark'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value == null) return;
                                  ref.read(themeModeProvider.notifier).state =
                                      value;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeaderSkeleton extends StatelessWidget {
  const _ProfileHeaderSkeleton({required this.useNovaUi});

  final bool useNovaUi;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final base = cs.surfaceContainerHighest.withValues(alpha: 0.75);
    final line = cs.surfaceContainerHighest.withValues(alpha: 0.95);
    final child = Padding(
      padding: useNovaUi ? AppInsets.card : EdgeInsets.all(12.r),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12.h,
                  width: 160.w,
                  decoration: BoxDecoration(
                    color: line,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 10.h,
                  width: 220.w,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            height: 32.h,
            width: 90.w,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ],
      ),
    );

    return useNovaUi ? NovaSurface(child: child) : Card(child: child);
  }
}

class _SignedOutCard extends StatelessWidget {
  const _SignedOutCard({required this.useNovaUi});

  final bool useNovaUi;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final content = Padding(
      padding: useNovaUi ? AppInsets.card : EdgeInsets.all(12.r),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(Icons.person_outline, color: cs.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign in',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Sync orders and keep your account across devices.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.70),
                      ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          if (useNovaUi)
            SizedBox(
              height: 34.h,
              child: NovaButton.primary(
                onPressed: () => context.push(AppRoutes.signIn),
                label: 'Sign in',
              ),
            )
          else
            SizedBox(
              height: 36.h,
              child: FilledButton(
                onPressed: () => context.push(AppRoutes.signIn),
                child: const Text('Sign in'),
              ),
            ),
        ],
      ),
    );

    return useNovaUi ? NovaSurface(child: content) : Card(child: content);
  }
}

class _SignedInCard extends StatelessWidget {
  const _SignedInCard({
    required this.useNovaUi,
    required this.isAnonymous,
    required this.email,
    required this.onSignOut,
  });

  final bool useNovaUi;
  final bool isAnonymous;
  final String email;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final title = isAnonymous ? 'Guest session' : 'Signed in';
    final subtitle = isAnonymous
        ? 'Sign in to sync orders across devices.'
        : (email.isNotEmpty ? email : 'Account connected');

    final tile = ListTile(
      leading: const Icon(Icons.verified_user_outlined),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: useNovaUi
          ? NovaButton.text(
              label: 'Sign out',
              onPressed: onSignOut,
            )
          : TextButton(
              onPressed: onSignOut,
              child: const Text('Sign out'),
            ),
    );

    return useNovaUi ? NovaSurface(child: tile) : Card(child: tile);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.useNovaUi});

  final String title;
  final bool useNovaUi;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: useNovaUi ? EdgeInsets.zero : EdgeInsets.only(left: 2.w),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _SecondaryLinksBlock extends StatelessWidget {
  const _SecondaryLinksBlock({required this.useNovaUi});

  final bool useNovaUi;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final child = Column(
      children: [
        ListTile(
          leading: const Icon(Icons.receipt_long_outlined),
          title: const Text('Orders'),
          subtitle: const Text('Track purchases and delivery'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(AppRoutes.orders),
        ),
        Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.6)),
        ListTile(
          leading: const Icon(Icons.favorite_border),
          title: const Text('Wishlist'),
          subtitle: const Text('Saved items'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(AppRoutes.wishlist),
        ),
      ],
    );

    return useNovaUi ? NovaSurface(child: child) : Card(child: child);
  }
}

class _BuildStatusRow extends StatelessWidget {
  const _BuildStatusRow({
    required this.title,
    required this.subtitle,
    required this.enabled,
  });

  final String title;
  final String subtitle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final valueLabel = enabled ? 'Enabled' : 'Disabled';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.65),
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: Text(
            valueLabel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ],
    );
  }
}

class _AccountHubHeader extends StatelessWidget {
  const _AccountHubHeader({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            padding: EdgeInsets.all(10.r),
            child: Icon(Icons.person, size: 24.r),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account hub',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 4.h),
              Text(
                'Orders, saved items, and account details.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
