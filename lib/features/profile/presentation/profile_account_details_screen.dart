import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/nova_app_bar.dart';
import '../../../core/widgets/nova_button.dart';
import '../../../core/widgets/nova_section_header.dart';
import '../../../core/widgets/nova_surface.dart';
import '../../../core/widgets/nova_text_field.dart';
import 'profile_details_viewmodel.dart';

class ProfileAccountDetailsScreen extends ConsumerStatefulWidget {
  const ProfileAccountDetailsScreen({super.key});

  @override
  ConsumerState<ProfileAccountDetailsScreen> createState() =>
      _ProfileAccountDetailsScreenState();
}

class _ProfileAccountDetailsLifecycle extends WidgetsBindingObserver {
  _ProfileAccountDetailsLifecycle({required this.onResume});

  final VoidCallback onResume;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResume();
    }
  }
}

class _SignInRequiredCard extends StatelessWidget {
  const _SignInRequiredCard({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return NovaSurface(
      padding: AppInsets.card,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Icon(Icons.person_outline, color: cs.primary),
          ),
          SizedBox(width: AppSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign in required',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: AppSpace.xxs),
                Text(
                  'Sign in to view and update your account details.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.70),
                      ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpace.sm),
          SizedBox(
            height: 36,
            child: NovaButton.primary(
              label: 'Sign in',
              onPressed: onSignIn,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAccountDetailsScreenState
    extends ConsumerState<ProfileAccountDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycle);
  }

  late final _lifecycle = _ProfileAccountDetailsLifecycle(onResume: () {
    ref.read(profileDetailsViewModelProvider.notifier).reload();
  });

  final _nameController = TextEditingController();
  bool _editingName = false;

  final _phoneController = TextEditingController();
  final _smsController = TextEditingController();

  DateTime? _emailCooldownUntil;
  DateTime? _phoneCooldownUntil;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycle);
    _cooldownTimer?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  int _cooldownRemainingSeconds(DateTime? until) {
    if (until == null) return 0;
    final diff = until.difference(DateTime.now());
    final seconds = diff.inSeconds;
    return seconds > 0 ? seconds : 0;
  }

  void _startCooldownTicking() {
    _cooldownTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final emailRemaining = _cooldownRemainingSeconds(_emailCooldownUntil);
      final phoneRemaining = _cooldownRemainingSeconds(_phoneCooldownUntil);
      if (emailRemaining == 0 && phoneRemaining == 0) {
        _cooldownTimer?.cancel();
        _cooldownTimer = null;
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(profileDetailsViewModelProvider);
    final vm = ref.read(profileDetailsViewModelProvider.notifier);

    ref.listen<ProfileDetailsState>(profileDetailsViewModelProvider, (prev, next) {
      if (prev?.eventId == next.eventId) return;
      final msg = next.event;
      if (msg == null || msg.trim().isEmpty) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    });

    final details = state.details;
    if (details != null && !_editingName) {
      final current = _nameController.text;
      if (current.isEmpty) {
        _nameController.text = details.displayName;
      }
    }

    return Scaffold(
      appBar: NovaAppBar(
        titleText: 'Account details',
        actions: [
          IconButton(
            onPressed: state.isLoading ? null : () => vm.reload(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: AppInsets.screen,
              children: [
                if (details == null)
                  _SignInRequiredCard(onSignIn: () => context.push(AppRoutes.signIn))
                else ...[
                  _heroCard(context, details, cs),
                  SizedBox(height: AppSpace.lg),
                  NovaSectionHeader(
                    title: 'Profile',
                    subtitle: 'Keep your account info up to date.',
                  ),
                  _nameCard(details: details, state: state, vm: vm),
                  if (details.isAnonymous)
                    Padding(
                      padding: EdgeInsets.only(top: AppSpace.xs),
                      child: Text(
                        'Sign in to edit your profile.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  SizedBox(height: AppSpace.md),
                  NovaSectionHeader(
                    title: 'Email',
                    subtitle: 'Verify to unlock order syncing.',
                  ),
                  _emailCard(details: details, state: state, vm: vm),
                  if (details.isAnonymous)
                    Padding(
                      padding: EdgeInsets.only(top: AppSpace.xs),
                      child: Text(
                        'Sign in to verify your email.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  SizedBox(height: AppSpace.md),
                  NovaSectionHeader(
                    title: 'Phone',
                    subtitle: 'Verify for account recovery and delivery updates.',
                  ),
                  _phoneCard(details: details, state: state, vm: vm),
                  if (details.isAnonymous)
                    Padding(
                      padding: EdgeInsets.only(top: AppSpace.xs),
                      child: Text(
                        'Sign in to verify your phone.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                ],
              ],
            ),
    );
  }

  Widget _heroCard(
    BuildContext context,
    dynamic details,
    ColorScheme cs,
  ) {
    final avatar = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.22),
            cs.secondary.withValues(alpha: 0.12),
          ],
        ),
      ),
      child: Icon(Icons.person, color: cs.primary, size: 28),
    );

    final title = Text(
      details.displayName.trim().isNotEmpty
          ? details.displayName
          : (details.isAnonymous ? 'Guest session' : 'Your account'),
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.w900),
    );

    final subtitle = Text(
      details.isAnonymous
          ? 'Sign in to sync across devices.'
          : (details.email?.trim().isNotEmpty == true
              ? details.email!
              : 'Signed in'),
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: cs.onSurface.withValues(alpha: 0.70)),
    );

    return NovaSurface(
      padding: AppInsets.card,
      child: Row(
        children: [
          avatar,
          SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: title),
                    if (details.isDemo)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          border: Border.all(
                            color: cs.primary.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Text(
                          'DEMO',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.primary,
                              ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: AppSpace.xxs),
                subtitle,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nameCard({
    required dynamic details,
    required ProfileDetailsState state,
    required ProfileDetailsViewModel vm,
  }) {
    return NovaSurface(
      padding: AppInsets.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NovaTextField(
            controller: _nameController,
            labelText: 'Name',
            hintText: 'Your name',
            enabled: _editingName && !state.isSavingName,
          ),
          SizedBox(height: AppSpace.sm),
          Row(
            children: [
              Expanded(
                child: _editingName
                    ? NovaButton.primary(
                        label: state.isSavingName ? 'Saving...' : 'Save',
                        isLoading: state.isSavingName,
                        onPressed: state.isSavingName
                            ? null
                            : () async {
                                await vm.saveDisplayName(_nameController.text);
                                if (mounted) {
                                  setState(() => _editingName = false);
                                }
                              },
                      )
                    : NovaButton.tonal(
                        label: 'Edit',
                        onPressed: details.isAnonymous
                            ? null
                            : () => setState(() => _editingName = true),
                      ),
              ),
              if (_editingName) ...[
                SizedBox(width: AppSpace.sm),
                Expanded(
                  child: NovaButton.outlined(
                    label: 'Cancel',
                    onPressed: () => setState(() => _editingName = false),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _emailCard({
    required dynamic details,
    required ProfileDetailsState state,
    required ProfileDetailsViewModel vm,
  }) {
    final cs = Theme.of(context).colorScheme;
    final emailText = details.email?.isNotEmpty == true ? details.email! : 'No email';
    final statusText = details.isEmailVerified ? 'Verified ✅' : 'Not verified';

    final cooldownSeconds = _cooldownRemainingSeconds(_emailCooldownUntil);
    final canSend =
        !details.isAnonymous && !state.isSendingEmail && cooldownSeconds == 0;

    return NovaSurface(
      padding: AppInsets.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emailText,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: AppSpace.xxs),
          Row(
            children: [
              Icon(
                details.isEmailVerified ? Icons.verified : Icons.error_outline,
                size: 18,
                color: details.isEmailVerified
                    ? cs.primary
                    : cs.onSurface.withValues(alpha: 0.60),
              ),
              SizedBox(width: AppSpace.xxs),
              Text(
                statusText,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: cs.onSurface.withValues(alpha: 0.75)),
              ),
            ],
          ),
          if (!details.isEmailVerified) ...[
            SizedBox(height: AppSpace.sm),
            NovaButton.tonal(
              label: cooldownSeconds > 0
                  ? 'Resend in ${cooldownSeconds}s'
                  : 'Verify email',
              isLoading: state.isSendingEmail,
              onPressed: canSend
                  ? () async {
                      await vm.sendEmailVerification();
                      await vm.reload();
                      _emailCooldownUntil =
                          DateTime.now().add(const Duration(seconds: 30));
                      _startCooldownTicking();
                      if (mounted) setState(() {});
                    }
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _phoneCard({
    required dynamic details,
    required ProfileDetailsState state,
    required ProfileDetailsViewModel vm,
  }) {
    final cs = Theme.of(context).colorScheme;
    final cooldownSeconds = _cooldownRemainingSeconds(_phoneCooldownUntil);
    final canSend =
        !details.isAnonymous &&
        !state.isSendingPhoneCode &&
        !state.isLinkingPhone &&
        cooldownSeconds == 0;

    return NovaSurface(
      padding: AppInsets.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            details.phoneNumber?.isNotEmpty == true
                ? details.phoneNumber!
                : 'No phone linked',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: AppSpace.xxs),
          Row(
            children: [
              Icon(
                details.isPhoneVerified ? Icons.verified : Icons.error_outline,
                size: 18,
                color: details.isPhoneVerified
                    ? cs.primary
                    : cs.onSurface.withValues(alpha: 0.60),
              ),
              SizedBox(width: AppSpace.xxs),
              Text(
                details.isPhoneVerified ? 'Verified ✅' : 'Not verified',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: cs.onSurface.withValues(alpha: 0.75)),
              ),
            ],
          ),
          if (!details.isPhoneVerified) ...[
            SizedBox(height: AppSpace.md),
            NovaTextField(
              controller: _phoneController,
              labelText: 'Phone number',
              hintText: '+12025550123',
              enabled: !details.isAnonymous &&
                  !state.isSendingPhoneCode &&
                  !state.isLinkingPhone,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: AppSpace.sm),
            NovaButton.primary(
              label: cooldownSeconds > 0
                  ? 'Resend in ${cooldownSeconds}s'
                  : 'Send code',
              isLoading: state.isSendingPhoneCode,
              onPressed: canSend
                  ? () async {
                      await vm.startPhoneVerification(_phoneController.text);
                      _phoneCooldownUntil =
                          DateTime.now().add(const Duration(seconds: 30));
                      _startCooldownTicking();
                      if (mounted) setState(() {});
                    }
                  : null,
            ),
            if (state.phoneVerificationId != null) ...[
              SizedBox(height: AppSpace.md),
              NovaTextField(
                controller: _smsController,
                labelText: 'SMS code',
                enabled: !details.isAnonymous && !state.isLinkingPhone,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: AppSpace.sm),
              NovaButton.primary(
                label: 'Verify phone',
                isLoading: state.isLinkingPhone,
                onPressed: state.isLinkingPhone || details.isAnonymous
                    ? null
                    : () => vm.confirmPhoneCode(_smsController.text),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
