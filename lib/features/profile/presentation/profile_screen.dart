import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/config/app_env.dart';
import '../../../core/config/auth_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/nova_app_bar.dart';
import '../../../core/widgets/nova_button.dart';
import '../../../core/config/theme_mode_provider.dart';
import '../../loyalty/gold_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final userAsync = ref.watch(authUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final gold = ref.watch(goldBalanceProvider);
    final goldSource = ref.watch(goldSourceLabelProvider);

    final useNovaUi = AppEnv.enableNovaUi && AppEnv.enableNovaUiProfile;

    Future<void> confirmSignOut() async {
      final authRepo = ref.read(authRepositoryProvider);
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

    final maxContentWidth = MediaQuery.sizeOf(context).width >= 700
        ? 560.0
        : double.infinity;

    void showLockedSnack(String feature) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign in to access $feature.')));
    }

    return Scaffold(
      appBar: useNovaUi
          ? NovaAppBar(titleText: 'Account')
          : AppBar(title: const Text('Account')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _AccountHubScaffold(
          maxWidth: maxContentWidth,
          padding: AppInsets.screen,
          children: [
            _AccountHeader(
              cs: cs,
              isSignedIn: false,
              isAnonymous: true,
              email: '',
              gold: gold,
              goldSource: goldSource,
              onTapGold: () => context.push(AppRoutes.gold),
              onTapSignIn: () => context.push(AppRoutes.signIn),
            ),
          ],
        ),
        data: (value) {
          final user = value;
          final isSignedIn = user != null && !user.isAnonymous;
          final email = (user?.email ?? '').trim();

          final enableDetailsRedesign =
              AppEnv.enableNovaUi && AppEnv.enableNovaUiProfileDetails;

          return _AccountHubScaffold(
            maxWidth: maxContentWidth,
            padding: AppInsets.screen,
            children: [
              _AccountHeader(
                cs: cs,
                isSignedIn: isSignedIn,
                isAnonymous: user?.isAnonymous ?? true,
                email: email,
                gold: gold,
                goldSource: goldSource,
                onTapGold: () => context.push(AppRoutes.gold),
                onTapSignIn: () => context.push(AppRoutes.signIn),
              ),
              SizedBox(height: AppSpace.lg),
              _QuickActionsRow(
                isSignedIn: isSignedIn,
                onTapOrders: isSignedIn
                    ? () => context.push(AppRoutes.orders)
                    : () => showLockedSnack('Orders'),
                onTapWishlist: () => context.push(AppRoutes.wishlist),
                onTapCart: () => context.push(AppRoutes.cart),
                onTapMessages: isSignedIn
                    ? () => context.push(AppRoutes.messages)
                    : () => showLockedSnack('Messages'),
              ),
              SizedBox(height: AppSpace.lg),
              const _SectionLabel(title: 'Account'),
              SizedBox(height: AppSpace.md),
              _GroupCard(
                children: [
                  _AccountTile(
                    leading: Icons.manage_accounts_outlined,
                    title: 'Account details',
                    subtitle: 'Profile info and verification',
                    enabled: isSignedIn,
                    onTap: isSignedIn
                        ? () => context.push(
                            enableDetailsRedesign
                                ? AppRoutes.profileAccountDetails
                                : AppRoutes.profileDetails,
                          )
                        : () => showLockedSnack('Account details'),
                  ),
                  _AccountTile.divider(cs),
                  _AccountTile(
                    leading: Icons.location_on_outlined,
                    title: 'Addresses',
                    subtitle: 'Delivery addresses',
                    enabled: isSignedIn,
                    onTap: isSignedIn
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Addresses are not available yet.',
                                ),
                              ),
                            );
                          }
                        : () => showLockedSnack('Addresses'),
                  ),
                  _AccountTile.divider(cs),
                  _AccountTile(
                    leading: Icons.credit_card_outlined,
                    title: 'Payment methods',
                    subtitle: 'Cards and wallets',
                    enabled: isSignedIn,
                    onTap: isSignedIn
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Payment methods are not available yet.',
                                ),
                              ),
                            );
                          }
                        : () => showLockedSnack('Payment methods'),
                  ),
                ],
              ),
              SizedBox(height: AppSpace.lg),
              const _SectionLabel(title: 'My Shopping'),
              SizedBox(height: AppSpace.md),
              _GroupCard(
                children: [
                  _AccountTile(
                    leading: Icons.receipt_long_outlined,
                    title: 'Orders',
                    subtitle: 'Track purchases and delivery',
                    enabled: isSignedIn,
                    onTap: isSignedIn
                        ? () => context.push(AppRoutes.orders)
                        : () => showLockedSnack('Orders'),
                  ),
                  _AccountTile.divider(cs),
                  _AccountTile(
                    leading: Icons.favorite_border,
                    title: 'Wishlist',
                    subtitle: 'Saved items',
                    enabled: true,
                    onTap: () => context.push(AppRoutes.wishlist),
                  ),
                  _AccountTile.divider(cs),
                  _AccountTile(
                    leading: Icons.shopping_cart_outlined,
                    title: 'Cart',
                    subtitle: 'Items ready for checkout',
                    enabled: true,
                    onTap: () => context.push(AppRoutes.cart),
                  ),
                ],
              ),
              SizedBox(height: AppSpace.lg),
              const _SectionLabel(title: 'Support'),
              SizedBox(height: AppSpace.md),
              _GroupCard(
                children: [
                  _AccountTile(
                    leading: Icons.help_outline,
                    title: 'Help Center',
                    subtitle: 'Answers to common questions',
                    enabled: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Help Center is not available yet.'),
                        ),
                      );
                    },
                  ),
                  _AccountTile.divider(cs),
                  _AccountTile(
                    leading: Icons.support_agent_outlined,
                    title: 'Contact support',
                    subtitle: 'We\'re here to help',
                    enabled: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Support is not available yet.'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: AppSpace.xl),
              const _SectionLabel(title: 'App'),
              SizedBox(height: AppSpace.md),
              _GroupCard(
                padding: EdgeInsets.all(AppSpace.xl),
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: AppSpace.xs),
                    leading: _SoftTileIcon(icon: Icons.brightness_6_outlined),
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
                          ref.read(themeModeProvider.notifier).state = value;
                        },
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 64,
                    color: cs.outlineVariant.withValues(alpha: 0.35),
                  ),
                  SizedBox(height: AppSpace.md),
                  _BuildStatusRow(
                    title: 'Telemetry',
                    subtitle: 'Set by build configuration',
                    enabled: AppEnv.enableTelemetry,
                  ),
                  SizedBox(height: AppSpace.md),
                  _BuildStatusRow(
                    title: 'Personalization',
                    subtitle: 'Set by build configuration',
                    enabled: AppEnv.enableHomePersonalization,
                  ),
                ],
              ),
              SizedBox(height: AppSpace.xl),
              const _SectionLabel(title: 'Auth'),
              SizedBox(height: AppSpace.md),
              _GroupCard(
                children: [
                  if (!isSignedIn) ...[
                    _AccountTile(
                      leading: Icons.login,
                      title: 'Sign in',
                      subtitle: 'Unlock orders sync and messages',
                      enabled: true,
                      onTap: () => context.push(AppRoutes.signIn),
                    ),
                  ] else ...[
                    _AccountTile(
                      leading: Icons.logout,
                      title: 'Sign out',
                      subtitle: 'You can sign back in anytime',
                      enabled: true,
                      onTap: confirmSignOut,
                    ),
                  ],
                ],
              ),
              SizedBox(height: AppSpace.xl),
            ],
          );
        },
      ),
    );
  }
}

class _AccountHubScaffold extends StatelessWidget {
  const _AccountHubScaffold({
    required this.children,
    required this.padding,
    required this.maxWidth,
  });

  final List<Widget> children;
  final EdgeInsets padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: padding,
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({
    required this.cs,
    required this.isSignedIn,
    required this.isAnonymous,
    required this.email,
    required this.gold,
    required this.goldSource,
    required this.onTapGold,
    required this.onTapSignIn,
  });

  final ColorScheme cs;
  final bool isSignedIn;
  final bool isAnonymous;
  final String email;
  final AsyncValue<int> gold;
  final String goldSource;
  final VoidCallback onTapGold;
  final VoidCallback onTapSignIn;

  String _displayName() {
    if (!isSignedIn) return 'Guest';
    final e = email;
    if (e.isEmpty) return 'Member';
    final left = e.split('@').first;
    if (left.trim().isEmpty) return 'Member';
    final v = left.trim();
    return v.length <= 1
        ? v.toUpperCase()
        : '${v[0].toUpperCase()}${v.substring(1)}';
  }

  String _initials() {
    final name = _displayName().trim();
    if (name.isEmpty) return 'G';
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final goldValue = gold.valueOrNull ?? 0;
    final avatarSize = AppHitTargets.min + AppSpace.md;
    final radius = AppRadii.xl;

    final blue = AppColors.categoryChipPalette[0].withValues(alpha: 0.92);
    final red = AppColors.categoryChipPalette[5].withValues(alpha: 0.88);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            blue.withValues(alpha: 0.18),
            cs.primary.withValues(alpha: 0.08),
            red.withValues(alpha: 0.16),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        boxShadow: AppShadows.md(),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpace.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cs.primary.withValues(alpha: 0.92),
                        cs.tertiary.withValues(alpha: 0.86),
                      ],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials(),
                    style: t.titleMedium?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName(),
                        style: t.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: AppSpace.xs),
                      Text(
                        isSignedIn
                            ? (email.isNotEmpty ? email : 'Account connected')
                            : 'Sign in to unlock benefits',
                        style: t.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.70),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpace.sm),
                _GoldPill(
                  value: goldValue,
                  source: goldSource,
                  onTap: onTapGold,
                ),
              ],
            ),
            if (!isSignedIn || isAnonymous) ...[
              SizedBox(height: AppSpace.md),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.55),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppSpace.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Sign in to sync orders and access messages across devices.',
                          style: t.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpace.sm),
                      SizedBox(
                        height: AppHitTargets.min,
                        child: NovaButton.primary(
                          label: 'Sign in',
                          onPressed: onTapSignIn,
                          icon: Icons.login,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GoldPill extends StatelessWidget {
  const _GoldPill({
    required this.value,
    required this.source,
    required this.onTap,
  });

  final int value;
  final String source;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
          boxShadow: AppShadows.sm(),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpace.md,
            vertical: AppSpace.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.card_giftcard_outlined, size: 16, color: cs.primary),
              SizedBox(width: AppSpace.xs),
              Text(
                '$value Gold',
                style: t.labelMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              SizedBox(width: AppSpace.xs),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.isSignedIn,
    required this.onTapOrders,
    required this.onTapWishlist,
    required this.onTapCart,
    required this.onTapMessages,
  });

  final bool isSignedIn;
  final VoidCallback onTapOrders;
  final VoidCallback onTapWishlist;
  final VoidCallback onTapCart;
  final VoidCallback onTapMessages;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 520;
    final gap = AppSpace.xl;

    final tiles = [
      _ActionTileData(
        key: const ValueKey('account_action_orders'),
        icon: Icons.receipt_long_outlined,
        label: 'Orders',
        enabled: isSignedIn,
        onTap: onTapOrders,
      ),
      _ActionTileData(
        key: const ValueKey('account_action_wishlist'),
        icon: Icons.favorite_border,
        label: 'Wishlist',
        enabled: true,
        onTap: onTapWishlist,
      ),
      _ActionTileData(
        key: const ValueKey('account_action_cart'),
        icon: Icons.shopping_cart_outlined,
        label: 'Cart',
        enabled: true,
        onTap: onTapCart,
      ),
      _ActionTileData(
        key: const ValueKey('account_action_messages'),
        icon: Icons.chat_bubble_outline,
        label: 'Messages',
        enabled: isSignedIn,
        onTap: onTapMessages,
      ),
    ];

    if (isWide) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpace.sm),
        child: Row(
          children: [
            for (int i = 0; i < tiles.length; i++) ...[
              Expanded(child: _QuickActionTile(data: tiles[i])),
              if (i != tiles.length - 1) SizedBox(width: gap),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpace.sm),
      child: SizedBox(
        height: 88,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: tiles.length,
          separatorBuilder: (_, __) => SizedBox(width: gap),
          itemBuilder: (context, index) {
            return SizedBox(
              width: 104,
              child: _QuickActionTile(data: tiles[index]),
            );
          },
        ),
      ),
    );
  }
}

class _SoftTileIcon extends StatelessWidget {
  const _SoftTileIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20, color: cs.onSurface.withValues(alpha: 0.92)),
    );
  }
}

class _ActionTileData {
  const _ActionTileData({
    required this.key,
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final Key key;
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.data});
  final _ActionTileData data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final borderRadius = BorderRadius.circular(AppRadii.xl);

    return _PressableScale(
      key: data.key,
      onTap: data.onTap,
      borderRadius: borderRadius,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: borderRadius,
        boxShadow: AppShadows.sm(
          color: AppShadows.shadowColor.withValues(alpha: 0.10),
        ),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.30)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpace.sm,
          vertical: AppSpace.sm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cs.primary.withValues(alpha: 0.12),
                        cs.tertiary.withValues(alpha: 0.10),
                      ],
                    ),
                  ),
                ),
                Icon(
                  data.icon,
                  size: 20,
                  color: data.enabled
                      ? cs.onSurface.withValues(alpha: 0.92)
                      : cs.onSurface.withValues(alpha: 0.45),
                ),
                if (!data.enabled)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppSpace.xs),
            Text(
              data.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: data.enabled
                    ? cs.onSurface.withValues(alpha: 0.92)
                    : cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PressableScale extends StatefulWidget {
  const _PressableScale({
    super.key,
    required this.onTap,
    required this.borderRadius,
    required this.decoration,
    required this.child,
  });

  final VoidCallback onTap;
  final BorderRadius borderRadius;
  final BoxDecoration decoration;
  final Widget child;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: DecoratedBox(
        decoration: widget.decoration,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapCancel: () => _setPressed(false),
            onTapUp: (_) => _setPressed(false),
            borderRadius: widget.borderRadius,
            child: ClipRRect(
              borderRadius: widget.borderRadius,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Text(
      title,
      style: t.titleSmall?.copyWith(
        fontWeight: FontWeight.w900,
        color: cs.onSurface.withValues(alpha: 0.92),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children, this.padding});

  final List<Widget> children;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadii.xl);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: radius,
        boxShadow: AppShadows.md(),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Column(children: children),
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  final IconData leading;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  static Widget divider(ColorScheme cs) {
    return Divider(
      height: 1,
      thickness: 1,
      color: cs.outlineVariant.withValues(alpha: 0.35),
      indent: 64,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final iconBg = cs.primary.withValues(alpha: 0.10);

    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.xs,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        alignment: Alignment.center,
        child: Icon(
          leading,
          size: 20,
          color: enabled
              ? cs.onSurface.withValues(alpha: 0.92)
              : cs.onSurface.withValues(alpha: 0.45),
        ),
      ),
      title: Text(title),
      titleTextStyle: t.bodyLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: enabled
            ? cs.onSurface.withValues(alpha: 0.92)
            : cs.onSurface.withValues(alpha: 0.55),
      ),
      subtitle: Text(subtitle),
      subtitleTextStyle: t.bodySmall?.copyWith(
        color: cs.onSurface.withValues(alpha: 0.70),
      ),
      trailing: enabled
          ? const Icon(Icons.chevron_right)
          : Icon(
              Icons.lock_outline,
              color: cs.onSurface.withValues(alpha: 0.45),
            ),
      onTap: onTap,
      enabled: true,
    );
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpace.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: AppSpace.xs),
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
            padding: EdgeInsets.symmetric(
              horizontal: AppSpace.md,
              vertical: AppSpace.xs,
            ),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Text(
              valueLabel,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
