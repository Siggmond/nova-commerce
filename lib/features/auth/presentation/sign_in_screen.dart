import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/auth_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../domain/repositories/auth_repository.dart';

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

  String? _emailError;
  String? _passwordError;

  bool _showPassword = false;

  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? _validateEmail(String v) {
    final trimmed = v.trim();
    if (trimmed.isEmpty) return 'Email is required';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
    if (!ok) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String v) {
    if (v.isEmpty) return 'Password is required';
    return null;
  }

  bool _validateForm() {
    final emailError = _validateEmail(_email.text);
    final passwordError = _validatePassword(_password.text);

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    return emailError == null && passwordError == null;
  }

  Future<void> _signInEmail() async {
    final auth = ref.read(authRepositoryProvider);
    final email = _email.text.trim();
    final password = _password.text;

    if (!_validateForm()) return;

    setState(() => _busy = true);
    try {
      await auth.signInEmail(email: email, password: password);
      _maybeShowFallbackNotice(auth);
      if (!mounted) return;
      context.pop();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signUpEmail() async {
    final auth = ref.read(authRepositoryProvider);
    final email = _email.text.trim();
    final password = _password.text;

    if (!_validateForm()) return;

    setState(() => _busy = true);
    try {
      await auth.createAccount(email: email, password: password);
      _maybeShowFallbackNotice(auth);
      if (!mounted) return;
      context.pop();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInGoogle() async {
    final auth = ref.read(authRepositoryProvider);

    setState(() => _busy = true);
    try {
      await auth.signInWithGoogle();
      _maybeShowFallbackNotice(auth);
      if (!mounted) return;
      context.pop();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _continueAsGuest() async {
    final auth = ref.read(authRepositoryProvider);
    setState(() => _busy = true);
    try {
      await auth.signInAnonymously();
      _maybeShowFallbackNotice(auth);
      if (!mounted) return;
      context.pop();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _maybeShowFallbackNotice(AuthRepository auth) {
    final notice = auth.takeFallbackNotice();
    if (notice == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(notice)));
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      body: AbsorbPointer(
        absorbing: _busy,
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
            Positioned(
              top: -120,
              right: -140,
              child: Container(
                width: 340,
                height: 340,
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
                                title: 'Nova',
                                subtitle: 'Welcome back — sign in to continue',
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
                                          'Sign in',
                                          style: t.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        SizedBox(height: AppSpace.md),
                                        Text(
                                          'Use your email and password to access your account.',
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
                                          labelText: 'Email',
                                          hintText: 'you@example.com',
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [
                                            AutofillHints.email,
                                          ],
                                          errorText: _emailError,
                                          prefixIcon: Icons.mail_outline,
                                          onChanged: (_) {
                                            if (_emailError != null) {
                                              setState(
                                                () => _emailError = null,
                                              );
                                            }
                                          },
                                          onSubmitted: () {
                                            _passwordFocus.requestFocus();
                                          },
                                        ),
                                        SizedBox(height: fieldGap),
                                        _PremiumTextField(
                                          controller: _password,
                                          focusNode: _passwordFocus,
                                          labelText: 'Password',
                                          hintText: '••••••••',
                                          obscureText: !_showPassword,
                                          textInputAction: TextInputAction.done,
                                          autofillHints: const [
                                            AutofillHints.password,
                                          ],
                                          errorText: _passwordError,
                                          prefixIcon: Icons.lock_outline,
                                          suffix: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _showPassword = !_showPassword;
                                              });
                                            },
                                            icon: Icon(
                                              _showPassword
                                                  ? Icons
                                                        .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                            ),
                                          ),
                                          onChanged: (_) {
                                            if (_passwordError != null) {
                                              setState(
                                                () => _passwordError = null,
                                              );
                                            }
                                          },
                                          onSubmitted: _signInEmail,
                                        ),
                                        SizedBox(height: AppSpace.xs),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: _busy
                                                ? null
                                                : () {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Password reset is not available yet.',
                                                        ),
                                                      ),
                                                    );
                                                  },
                                            child: const Text(
                                              'Forgot password?',
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: AppSpace.sm),
                                        SizedBox(
                                          width: double.infinity,
                                          child: AppButton.primary(
                                            label: 'Sign in',
                                            onPressed: _signInEmail,
                                            isLoading: _busy,
                                            icon: Icons.lock_open_outlined,
                                          ),
                                        ),
                                        SizedBox(height: AppSpace.sm),
                                        SizedBox(
                                          width: double.infinity,
                                          child: AppButton.outlined(
                                            label: 'Continue with Google',
                                            onPressed: _signInGoogle,
                                            isLoading: _busy,
                                            icon: Icons.g_mobiledata,
                                          ),
                                        ),
                                        SizedBox(height: AppSpace.sm),
                                        SizedBox(
                                          width: double.infinity,
                                          child: AppButton.outlined(
                                            label: 'Create account',
                                            onPressed: _signUpEmail,
                                            isLoading: _busy,
                                            icon:
                                                Icons.person_add_alt_1_outlined,
                                          ),
                                        ),
                                        SizedBox(height: AppSpace.lg),
                                        SizedBox(
                                          width: double.infinity,
                                          child: AppButton.text(
                                            label: 'Continue as guest',
                                            onPressed: _continueAsGuest,
                                            isLoading: _busy,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: AppSpace.lg),
                              _TrustRow(
                                items: const [
                                  _TrustItem(
                                    icon: Icons.lock_outline,
                                    label: 'Secure',
                                  ),
                                  _TrustItem(
                                    icon: Icons.local_shipping_outlined,
                                    label: 'Fast delivery',
                                  ),
                                  _TrustItem(
                                    icon: Icons.support_agent_outlined,
                                    label: 'Support',
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
              width: 42,
              height: 42,
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
          height: 18,
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
                size: 16,
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
