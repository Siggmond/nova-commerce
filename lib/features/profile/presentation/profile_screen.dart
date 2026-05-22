import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/config/app_env.dart';
import '../../../app/config/low_end_device_mode.dart';
import 'package:nova_commerce/app/di/app_providers.dart';
import 'package:nova_commerce/app/config/app_locale_provider.dart';
import '../../../app/perf/performance_engine.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/nova_app_bar.dart';
import '../../../core/widgets/nova_button.dart';
import '../../../app/config/theme_mode_provider.dart';
import '../../loyalty/gold_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final userAsync = ref.watch(authUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.of(context)!;
    final gold = ref.watch(goldBalanceProvider);
    final goldSource = ref.watch(goldSourceLabelProvider);
    final lowEndMode = ref.watch(lowEndDeviceModeProvider);
    final perfReduced = ref.watch(
      performanceEngineProvider.select((s) => !s.allowDecorativeMotion),
    );
    final reduceEffects = lowEndMode || perfReduced;

    final useNovaUi = AppEnv.enableNovaUi && AppEnv.enableNovaUiProfile;

    Future<void> confirmSignOut() async {
      final authRepo = ref.read(authRepositoryProvider);
      final shouldSignOut = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(t.profileSignOutDialogTitle),
            content: Text(t.profileSignOutDialogBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(t.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(t.commonSignOut),
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
          return t.profileThemeLight;
        case ThemeMode.dark:
          return t.profileThemeDark;
        case ThemeMode.system:
          return t.profileThemeSystem;
      }
    }

    AppLanguage languageFromLocale(Locale? locale) {
      if (locale == null) return AppLanguage.system;
      switch (locale.languageCode) {
        case 'en':
          return AppLanguage.en;
        case 'ar':
          return AppLanguage.ar;
        case 'fr':
          return AppLanguage.fr;
        case 'es':
          return AppLanguage.es;
        default:
          return AppLanguage.system;
      }
    }

    String languageLabel(Locale? locale) {
      if (locale == null) {
        return t.languageSystem;
      }
      switch (locale.languageCode) {
        case 'en':
          return t.languageNameEnglish;
        case 'ar':
          return t.languageNameArabic;
        case 'fr':
          return t.languageNameFrench;
        case 'es':
          return t.languageNameSpanish;
        default:
          return t.languageSystem;
      }
    }

    final maxContentWidth = MediaQuery.sizeOf(context).width >= 700
        ? 560.0
        : double.infinity;

    void showLockedSnack(String feature) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.profileSnackbarSignInToAccess(feature))),
      );
    }

    return Scaffold(
      appBar: useNovaUi
          ? NovaAppBar(titleText: t.navAccount)
          : AppBar(title: Text(t.navAccount)),
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
              reduceEffects: reduceEffects,
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
                reduceEffects: reduceEffects,
                onTapGold: () => context.push(AppRoutes.gold),
                onTapSignIn: () => context.push(AppRoutes.signIn),
              ),
              SizedBox(height: AppSpace.lg),
              _QuickActionsRow(
                isSignedIn: isSignedIn,
                reduceEffects: reduceEffects,
                onTapOrders: isSignedIn
                    ? () => context.push(AppRoutes.orders)
                    : () => showLockedSnack(t.profileFeatureOrders),
                onTapWishlist: () => context.push(AppRoutes.wishlist),
                onTapCart: () => context.push(AppRoutes.cart),
                onTapMessages: isSignedIn
                    ? () => context.push(AppRoutes.messages)
                    : () => showLockedSnack(t.profileFeatureMessages),
              ),
              SizedBox(height: AppSpace.lg),
              _SectionLabel(title: t.profileSectionAccount),
              SizedBox(height: AppSpace.md),
              _GroupCard(
                children: [
                  _AccountTile(
                    leading: Icons.manage_accounts_outlined,
                    title: t.profileAccountDetailsTitle,
                    subtitle: t.profileAccountDetailsTileSubtitle,
                    enabled: isSignedIn,
                    onTap: isSignedIn
                        ? () => context.push(
                            enableDetailsRedesign
                                ? AppRoutes.profileAccountDetails
                                : AppRoutes.profileDetails,
                          )
                        : () => showLockedSnack(t.profileAccountDetailsTitle),
                  ),
                  _AccountTile.divider(cs),
                  _AccountTile(
                    leading: Icons.location_on_outlined,
                    title: t.profileAddressesTitle,
                    subtitle: t.profileAddressesSubtitle,
                    enabled: isSignedIn,
                    onTap: isSignedIn
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  t.profileNotAvailableYet(
                                    t.profileAddressesTitle,
                                  ),
                                ),
                              ),
                            );
                          }
                        : () => showLockedSnack(t.profileAddressesTitle),
                  ),
                  _AccountTile.divider(cs),
                  _AccountTile(
                    leading: Icons.credit_card_outlined,
                    title: t.profilePaymentMethodsTitle,
                    subtitle: t.profilePaymentMethodsSubtitle,
                    enabled: isSignedIn,
                    onTap: isSignedIn
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  t.profileNotAvailableYet(
                                    t.profilePaymentMethodsTitle,
                                  ),
                                ),
                              ),
                            );
                          }
                        : () => showLockedSnack(t.profilePaymentMethodsTitle),
                  ),
                ],
              ),
              SizedBox(height: AppSpace.lg),
              _SectionLabel(title: t.profileSectionMyShopping),
              SizedBox(height: AppSpace.md),
              _GroupCard(
                children: [
                  _AccountTile(
                    leading: Icons.receipt_long_outlined,
                    title: t.profileOrdersTitle,
                    subtitle: t.profileOrdersSubtitle,
                    enabled: isSignedIn,
                    onTap: isSignedIn
                        ? () => context.push(AppRoutes.orders)
                        : () => showLockedSnack(t.profileOrdersTitle),
                  ),
                  _AccountTile.divider(cs),
                  _AccountTile(
                    leading: Icons.favorite_border,
                    title: t.profileWishlistTitle,
                    subtitle: t.profileWishlistSubtitle,
                    enabled: true,
                    onTap: () => context.push(AppRoutes.wishlist),
                  ),
                  _AccountTile.divider(cs),
                  _AccountTile(
                    leading: Icons.shopping_cart_outlined,
                    title: t.profileCartTitle,
                    subtitle: t.profileCartSubtitle,
                    enabled: true,
                    onTap: () => context.push(AppRoutes.cart),
                  ),
                ],
              ),
              SizedBox(height: AppSpace.lg),
              _SectionLabel(title: t.profileSectionSupport),
              SizedBox(height: AppSpace.md),
              _GroupCard(
                children: [
                  _AccountTile(
                    leading: Icons.help_outline,
                    title: t.profileHelpCenterTitle,
                    subtitle: t.profileHelpCenterSubtitle,
                    enabled: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            t.profileNotAvailableYet(t.profileHelpCenterTitle),
                          ),
                        ),
                      );
                    },
                  ),
                  _AccountTile.divider(cs),
                  _AccountTile(
                    leading: Icons.support_agent_outlined,
                    title: t.profileContactSupportTitle,
                    subtitle: t.profileContactSupportSubtitle,
                    enabled: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            t.profileNotAvailableYet(
                              t.profileContactSupportTitle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: AppSpace.xl),
              _SectionLabel(title: t.profileSectionApp),
              SizedBox(height: AppSpace.md),
              _GroupCard(
                padding: EdgeInsets.all(AppSpace.xl),
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: AppSpace.xs),
                    leading: const _SoftTileIcon(icon: Icons.language),
                    title: Text(t.language),
                    subtitle: Text(languageLabel(locale)),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<AppLanguage>(
                        value: languageFromLocale(locale),
                        items: [
                          DropdownMenuItem(
                            value: AppLanguage.system,
                            child: Text(t.languageSystem),
                          ),
                          DropdownMenuItem(
                            value: AppLanguage.en,
                            child: Text(t.languageNameEnglish),
                          ),
                          DropdownMenuItem(
                            value: AppLanguage.ar,
                            child: Text(t.languageNameArabic),
                          ),
                          DropdownMenuItem(
                            value: AppLanguage.fr,
                            child: Text(t.languageNameFrench),
                          ),
                          DropdownMenuItem(
                            value: AppLanguage.es,
                            child: Text(t.languageNameSpanish),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          ref
                              .read(appLocaleProvider.notifier)
                              .setLanguage(value);
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
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: AppSpace.xs),
                    leading: _SoftTileIcon(icon: Icons.brightness_6_outlined),
                    title: Text(t.profileThemeTitle),
                    subtitle: Text(themeLabel(themeMode)),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<ThemeMode>(
                        value: themeMode,
                        items: [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text(t.profileThemeSystem),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text(t.profileThemeLight),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text(t.profileThemeDark),
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
                    title: t.profileBuildStatusTelemetryTitle,
                    subtitle: t.profileBuildStatusSubtitle,
                    enabled: AppEnv.enableTelemetry,
                  ),
                  SizedBox(height: AppSpace.md),
                  _BuildStatusRow(
                    title: t.profileBuildStatusPersonalizationTitle,
                    subtitle: t.profileBuildStatusSubtitle,
                    enabled: AppEnv.enableHomePersonalization,
                  ),
                ],
              ),
              SizedBox(height: AppSpace.xl),
              _SectionLabel(title: t.profileSectionAuth),
              SizedBox(height: AppSpace.md),
              _GroupCard(
                children: [
                  if (!isSignedIn) ...[
                    _AccountTile(
                      leading: Icons.login,
                      title: t.commonSignIn,
                      subtitle: t.profileSignInSubtitle,
                      enabled: true,
                      onTap: () => context.push(AppRoutes.signIn),
                    ),
                  ] else ...[
                    _AccountTile(
                      leading: Icons.logout,
                      title: t.commonSignOut,
                      subtitle: t.profileSignOutSubtitle,
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
    return ListView.builder(
      padding: padding,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SizedBox(width: double.infinity, child: children[index]),
          ),
        );
      },
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
    required this.reduceEffects,
    required this.onTapGold,
    required this.onTapSignIn,
  });

  final ColorScheme cs;
  final bool isSignedIn;
  final bool isAnonymous;
  final String email;
  final AsyncValue<int> gold;
  final String goldSource;
  final bool reduceEffects;
  final VoidCallback onTapGold;
  final VoidCallback onTapSignIn;

  String _displayName(AppLocalizations l10n) {
    if (!isSignedIn) return l10n.profileGuestLabel;
    final e = email;
    if (e.isEmpty) return l10n.profileMemberLabel;
    final left = e.split('@').first;
    if (left.trim().isEmpty) return l10n.profileMemberLabel;
    final v = left.trim();
    return v.length <= 1
        ? v.toUpperCase()
        : '${v[0].toUpperCase()}${v.substring(1)}';
  }

  String _initials(AppLocalizations l10n) {
    final name = _displayName(l10n).trim();
    if (name.isEmpty) return l10n.profileGuestInitial;
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = Theme.of(context).textTheme;
    final goldValue = gold.valueOrNull ?? 0;
    final avatarSize = AppHitTargets.min + AppSpace.md;
    final radius = AppRadii.xl;

    final blue = AppColors.categoryChipPalette[0].withValues(alpha: 0.92);
    final red = AppColors.categoryChipPalette[5].withValues(alpha: 0.88);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: reduceEffects ? cs.surfaceContainerLow : null,
        gradient: reduceEffects
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  blue.withValues(alpha: 0.18),
                  cs.primary.withValues(alpha: 0.08),
                  red.withValues(alpha: 0.16),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
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
                    _initials(l10n),
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
                        _displayName(l10n),
                        style: t.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: AppSpace.xs),
                      Text(
                        isSignedIn
                            ? (email.isNotEmpty
                                  ? email
                                  : l10n.profileAccountConnected)
                            : l10n.profileSignInToUnlockBenefits,
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
                          l10n.profileSignInBannerBody,
                          style: t.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpace.sm),
                      SizedBox(
                        height: AppHitTargets.min,
                        child: NovaButton.primary(
                          label: l10n.commonSignIn,
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
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpace.md,
            vertical: AppSpace.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.card_giftcard_outlined, size: 16.r, color: cs.primary),
              SizedBox(width: AppSpace.xs),
              Text(
                l10n.profileGoldPoints(value),
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
    required this.reduceEffects,
    required this.onTapOrders,
    required this.onTapWishlist,
    required this.onTapCart,
    required this.onTapMessages,
  });

  final bool isSignedIn;
  final bool reduceEffects;
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
        label: AppLocalizations.of(context)!.profileOrdersTitle,
        enabled: isSignedIn,
        onTap: onTapOrders,
      ),
      _ActionTileData(
        key: const ValueKey('account_action_wishlist'),
        icon: Icons.favorite_border,
        label: AppLocalizations.of(context)!.profileWishlistTitle,
        enabled: true,
        onTap: onTapWishlist,
      ),
      _ActionTileData(
        key: const ValueKey('account_action_cart'),
        icon: Icons.shopping_cart_outlined,
        label: AppLocalizations.of(context)!.profileCartTitle,
        enabled: true,
        onTap: onTapCart,
      ),
      _ActionTileData(
        key: const ValueKey('account_action_messages'),
        icon: Icons.chat_bubble_outline,
        label: AppLocalizations.of(context)!.profileMessagesTitle,
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
              Expanded(
                child: _QuickActionTile(
                  data: tiles[i],
                  reduceEffects: reduceEffects,
                ),
              ),
              if (i != tiles.length - 1) SizedBox(width: gap),
            ],
          ],
        ),
      );
    }

    final vPad = AppSpace.xs;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpace.sm),
      child: SizedBox(
        height: 88.h + (vPad * 2),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: EdgeInsets.symmetric(vertical: vPad),
          itemCount: tiles.length,
          separatorBuilder: (_, __) => SizedBox(width: gap),
          itemBuilder: (context, index) {
            return SizedBox(
              width: 104.w,
              child: _QuickActionTile(
                data: tiles[index],
                reduceEffects: reduceEffects,
              ),
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
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 20.r,
        color: cs.onSurface.withValues(alpha: 0.92),
      ),
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
  const _QuickActionTile({required this.data, required this.reduceEffects});
  final _ActionTileData data;
  final bool reduceEffects;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final borderRadius = BorderRadius.circular(AppRadii.xl);

    return _PressableScale(
      key: data.key,
      onTap: data.onTap,
      disableScale: reduceEffects,
      borderRadius: borderRadius,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: borderRadius,
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
                  width: 38.r,
                  height: 38.r,
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
                  size: 20.r,
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
                      size: 14.r,
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
    required this.disableScale,
    required this.borderRadius,
    required this.decoration,
    required this.child,
  });

  final VoidCallback onTap;
  final bool disableScale;
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
      scale: widget.disableScale ? 1.0 : (_pressed ? 0.98 : 1.0),
      duration: widget.disableScale
          ? Duration.zero
          : const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: DecoratedBox(
        decoration: widget.decoration,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: widget.disableScale ? null : (_) => _setPressed(true),
            onTapCancel: widget.disableScale ? null : () => _setPressed(false),
            onTapUp: widget.disableScale ? null : (_) => _setPressed(false),
            borderRadius: widget.borderRadius,
            child: widget.child,
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
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Column(children: children),
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
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        alignment: Alignment.center,
        child: Icon(
          leading,
          size: 20.r,
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
    final l10n = AppLocalizations.of(context)!;
    final valueLabel = enabled ? l10n.commonEnabled : l10n.commonDisabled;
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
