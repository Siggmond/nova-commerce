import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import 'package:nova_commerce/features/auth/presentation/state/sign_in_controller.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  String? _mapEmailError(SignInEmailError? error) {
    final l10n = _l10n;
    return switch (error) {
      SignInEmailError.requiredField => l10n.authEmailRequired,
      SignInEmailError.invalidFormat => l10n.authInvalidEmail,
      null => null,
    };
  }

  String? _mapPasswordError(SignInPasswordError? error) {
    final l10n = _l10n;
    return switch (error) {
      SignInPasswordError.requiredField => l10n.authPasswordRequired,
      null => null,
    };
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;
    final signInState = ref.watch(signInControllerProvider);
    final signInController = ref.read(signInControllerProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;
    final maxCardWidth = width >= 600 ? 520.0 : double.infinity;
    final headerTopPad = AppSpace.lg;
    final cardPad = AppSpace.xl;
    final cardRadius = AppRadii.xl;
    final fieldGap = AppSpace.xs;

    final blue = AppColors.categoryChipPalette[0].withValues(alpha: 0.92);
    final red = AppColors.categoryChipPalette[5].withValues(alpha: 0.86);

    ref.listen<int>(signInControllerProvider.select((s) => s.eventId), (
      previous,
      next,
    ) {
      final event = ref.read(signInControllerProvider).event;
      if (event is SignInShowMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(event.message)));
      } else if (event is SignInClose) {
        context.pop();
      }
    });

    return Scaffold(
      body: AbsorbPointer(
        absorbing: signInState.isBusy,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [cs.surface, cs.surface],
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: -120.h,
              end: -140.w,
              child: Container(
                width: 340.r,
                height: 340.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      blue.withValues(alpha: 0.22),
                      red.withValues(alpha: 0.18),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: AppInsets.screen,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight - (AppInsets.screen.vertical),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxCardWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: headerTopPad),
                              _BrandHeader(
                                title: l10n.brandName,
                                subtitle: l10n.authWelcomeBackSubtitle,
                              ),
                              SizedBox(height: AppSpace.lg),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(
                                    cardRadius,
                                  ),
                                  boxShadow: AppShadows.lg(),
                                  border: Border.all(
                                    color: cs.outlineVariant.withValues(
                                      alpha: 0.55,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(cardPad),
                                  child: AutofillGroup(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          l10n.authSignInTitle,
                                          style: t.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        SizedBox(height: AppSpace.md),
                                        Text(
                                          l10n.authSignInBody,
                                          style: t.bodyMedium?.copyWith(
                                            color: cs.onSurface.withValues(
                                              alpha: 0.70,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: AppSpace.xl),
                                        _PremiumTextField(
                                          controller: _email,
                                          focusNode: _emailFocus,
                                          labelText: l10n.authEmailLabel,
                                          hintText: l10n.authEmailHint,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [
                                            AutofillHints.email,
                                          ],
                                          errorText: _mapEmailError(
                                            signInState.emailError,
                                          ),
                                          prefixIcon: Icons.mail_outline,
                                          onChanged: signInController.setEmail,
                                          onSubmitted: () {
                                            _passwordFocus.requestFocus();
                                          },
                                        ),
                                        SizedBox(height: fieldGap),
                                        _PremiumTextField(
                                          controller: _password,
                                          focusNode: _passwordFocus,
                                          labelText: l10n.authPasswordLabel,
                                          hintText: l10n.authPasswordHint,
                                          obscureText:
                                              !signInState.showPassword,
                                          textInputAction: TextInputAction.done,
                                          autofillHints: const [
                                            AutofillHints.password,
                                          ],
                                          errorText: _mapPasswordError(
                                            signInState.passwordError,
                                          ),
                                          prefixIcon: Icons.lock_outline,
                                          suffix: IconButton(
                                            onPressed: signInController
                                                .togglePasswordVisibility,
                                            icon: Icon(
                                              signInState.showPassword
                                                  ? Icons
                                                        .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                            ),
                                          ),
                                          onChanged:
                                              signInController.setPassword,
                                          onSubmitted:
                                              signInController.signInEmail,
                                        ),
                                        SizedBox(height: AppSpace.xs),
                                        Align(
                                          alignment:
                                              AlignmentDirectional.centerEnd,
                                          child: TextButton(
                                            onPressed: signInState.isBusy
                                                ? null
                                                : () {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          l10n.authPasswordResetUnavailable,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                            child: Text(
                                              l10n.authForgotPassword,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: AppSpace.sm),
                                        SizedBox(
                                          width: double.infinity,
                                          child: AppButton.primary(
                                            label: l10n.authSignInTitle,
                                            onPressed:
                                                signInController.signInEmail,
                                            isLoading: signInState.isBusy,
                                            icon: Icons.lock_open_outlined,
                                          ),
                                        ),
                                        SizedBox(height: AppSpace.sm),
                                        SizedBox(
                                          width: double.infinity,
                                          child: AppButton.outlined(
                                            label: l10n.authContinueWithGoogle,
                                            onPressed:
                                                signInController.signInGoogle,
                                            isLoading: signInState.isBusy,
                                            icon: Icons.g_mobiledata,
                                          ),
                                        ),
                                        SizedBox(height: AppSpace.sm),
                                        SizedBox(
                                          width: double.infinity,
                                          child: AppButton.outlined(
                                            label: l10n.authCreateAccount,
                                            onPressed:
                                                signInController.signUpEmail,
                                            isLoading: signInState.isBusy,
                                            icon:
                                                Icons.person_add_alt_1_outlined,
                                          ),
                                        ),
                                        SizedBox(height: AppSpace.lg),
                                        SizedBox(
                                          width: double.infinity,
                                          child: AppButton.text(
                                            label: l10n.authContinueAsGuest,
                                            onPressed: signInController
                                                .continueAsGuest,
                                            isLoading: signInState.isBusy,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: AppSpace.lg),
                              _TrustRow(
                                items: [
                                  _TrustItem(
                                    icon: Icons.lock_outline,
                                    label: l10n.trustSecure,
                                  ),
                                  _TrustItem(
                                    icon: Icons.local_shipping_outlined,
                                    label: l10n.trustFastDelivery,
                                  ),
                                  _TrustItem(
                                    icon: Icons.support_agent_outlined,
                                    label: l10n.trustSupport,
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSpace.sm),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.md),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withValues(alpha: 0.95),
                    cs.tertiary.withValues(alpha: 0.92),
                  ],
                ),
                boxShadow: AppShadows.md(),
              ),
              child: Icon(Icons.shopping_bag_outlined, color: cs.onPrimary),
            ),
            SizedBox(width: AppSpace.sm),
            Expanded(
              child: Text(
                title,
                style: t.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpace.sm),
        Text(
          subtitle,
          style: t.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.70),
          ),
        ),
      ],
    );
  }
}

class _PremiumTextField extends StatelessWidget {
  const _PremiumTextField({
    required this.controller,
    required this.labelText,
    this.hintText,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.errorText,
    this.prefixIcon,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<String>? autofillHints;
  final bool obscureText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppRadii.xl);

    final border = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.75)),
    );

    final focused = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: cs.primary, width: 1.6),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: cs.error, width: 1.4),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          obscureText: obscureText,
          onChanged: onChanged,
          onSubmitted: (_) => onSubmitted?.call(),
          style: t.bodyMedium,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            isDense: true,
            filled: true,
            fillColor: cs.surface,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
            suffixIcon: suffix,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpace.lg,
              vertical: AppSpace.sm,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: focused,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder,
          ),
        ),
        SizedBox(height: AppSpace.xs),
        SizedBox(
          height: 18.h,
          child: Text(
            errorText ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.bodySmall?.copyWith(color: cs.error),
          ),
        ),
      ],
    );
  }
}

class _TrustItem {
  const _TrustItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _TrustRow extends StatelessWidget {
  const _TrustRow({required this.items});
  final List<_TrustItem> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpace.lg,
      runSpacing: AppSpace.sm,
      children: [
        for (final i in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                i.icon,
                size: 16.r,
                color: cs.onSurface.withValues(alpha: 0.65),
              ),
              SizedBox(width: AppSpace.xs),
              Text(
                i.label,
                style: t.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.70),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
