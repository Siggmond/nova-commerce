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
import '../../../core/widgets/status_pill.dart';
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
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
            child: NovaButton.primary(label: 'Sign in', onPressed: onSignIn),
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

  late final _lifecycle = _ProfileAccountDetailsLifecycle(
    onResume: () {
      ref.read(profileDetailsViewModelProvider.notifier).reload();
    },
  );

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
    assert(() {
      debugPrint('OPENED: NEW ProfileAccountDetailsScreen');
      return true;
    }());
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(profileDetailsViewModelProvider);
    final vm = ref.read(profileDetailsViewModelProvider.notifier);

    ref.listen<ProfileDetailsState>(profileDetailsViewModelProvider, (
      prev,
      next,
    ) {
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

    final verifiedCount = details == null
        ? 0
        : (details.isEmailVerified ? 1 : 0) + (details.isPhoneVerified ? 1 : 0);

    return Scaffold(
      appBar: NovaAppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account details',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Manage your profile & verification',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.70),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: NovaSurface(
              borderRadius: AppRadii.pill,
              padding: EdgeInsets.zero,
              child: IconButton(
                onPressed: state.isLoading ? null : () => vm.reload(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: AppInsets.screen,
              children: [
                if (details == null)
                  _SignInRequiredCard(
                    onSignIn: () => context.push(AppRoutes.signIn),
                  )
                else ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: StatusPill(
                      label: '$verifiedCount/2 verified',
                      variant: verifiedCount == 2
                          ? StatusPillVariant.success
                          : StatusPillVariant.neutral,
                    ),
                  ),
                  SizedBox(height: AppSpace.md),
                  _heroCard(context, details, cs),
                  SizedBox(height: AppSpace.xl),
                  _sectionCard(
                    title: 'Profile',
                    subtitle: 'Keep your account info up to date.',
                    child: _nameCard(details: details, state: state, vm: vm),
                  ),
                  SizedBox(height: AppSpace.xl),
                  _sectionCard(
                    title: 'Email',
                    subtitle: 'Verify to unlock order syncing.',
                    child: _emailCard(details: details, state: state, vm: vm),
                  ),
                  SizedBox(height: AppSpace.xl),
                  _sectionCard(
                    title: 'Phone',
                    subtitle:
                        'Verify for account recovery and delivery updates.',
                    child: _phoneCard(details: details, state: state, vm: vm),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return NovaSurface(
      padding: AppInsets.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NovaSectionHeader(title: title, subtitle: subtitle),
          SizedBox(height: AppSpace.sm),
          child,
        ],
      ),
    );
  }

  Widget _captionMuted(String text) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: cs.onSurface.withValues(alpha: 0.70),
      ),
    );
  }

  Widget _actionsRow({required List<Widget> children}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                SizedBox(width: double.infinity, child: children[i]),
                if (i != children.length - 1) SizedBox(height: AppSpace.sm),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i != children.length - 1) SizedBox(width: AppSpace.sm),
            ],
          ],
        );
      },
    );
  }

  Widget _heroCard(BuildContext context, dynamic details, ColorScheme cs) {
    final avatar = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.22),
            cs.secondary.withValues(alpha: 0.12),
          ],
        ),
        border: Border.all(color: cs.onSurface.withValues(alpha: 0.12)),
      ),
      child: Icon(Icons.person, color: cs.primary, size: 28),
    );

    final title = Text(
      details.displayName.trim().isNotEmpty
          ? details.displayName
          : (details.isAnonymous ? 'Guest session' : 'Your account'),
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final subtitle = Text(
      details.isAnonymous
          ? 'Sign in to sync across devices.'
          : (details.email?.trim().isNotEmpty == true
                ? details.email!
                : 'Signed in'),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: cs.onSurface.withValues(alpha: 0.70),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
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
                    if (details.isDemo) const StatusPill(label: 'DEMO'),
                  ],
                ),
                SizedBox(height: AppSpace.xxs),
                subtitle,
                if (details.isAnonymous) ...[
                  SizedBox(height: AppSpace.sm),
                  NovaSurface(
                    borderRadius: AppRadii.lg,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: cs.onSurface.withValues(alpha: 0.70),
                        ),
                        SizedBox(width: AppSpace.xs),
                        Expanded(
                          child: Text(
                            'Sign in to sync and verify your account.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.75),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NovaSurface(
          padding: AppInsets.card,
          child: NovaTextField(
            controller: _nameController,
            density: NovaFieldDensity.comfortable,
            labelText: 'Name',
            hintText: 'Your name',
            enabled: _editingName && !state.isSavingName,
          ),
        ),
        SizedBox(height: AppSpace.sm),
        _actionsRow(
          children: [
            _editingName
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
            if (_editingName)
              NovaButton.outlined(
                label: 'Cancel',
                onPressed: () => setState(() => _editingName = false),
              ),
          ],
        ),
        if (details.isAnonymous) ...[
          SizedBox(height: AppSpace.xs),
          Text(
            'Sign in to edit your profile.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.70),
            ),
          ),
        ],
      ],
    );
  }

  Widget _emailCard({
    required dynamic details,
    required ProfileDetailsState state,
    required ProfileDetailsViewModel vm,
  }) {
    final emailText = details.email?.isNotEmpty == true
        ? details.email!
        : 'No email';

    final cooldownSeconds = _cooldownRemainingSeconds(_emailCooldownUntil);
    final canSend =
        !details.isAnonymous && !state.isSendingEmail && cooldownSeconds == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                emailText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(width: AppSpace.sm),
            StatusPill(
              label: details.isEmailVerified ? 'Verified' : 'Not verified',
              variant: details.isEmailVerified
                  ? StatusPillVariant.success
                  : StatusPillVariant.neutral,
            ),
          ],
        ),
        if (!details.isEmailVerified) ...[
          SizedBox(height: AppSpace.sm),
          SizedBox(
            width: double.infinity,
            child: NovaButton.primary(
              label: 'Verify email',
              isLoading: state.isSendingEmail,
              onPressed: canSend
                  ? () async {
                      await vm.sendEmailVerification();
                      await vm.reload();
                      _emailCooldownUntil = DateTime.now().add(
                        const Duration(seconds: 30),
                      );
                      _startCooldownTicking();
                      if (mounted) setState(() {});
                    }
                  : null,
            ),
          ),
          if (cooldownSeconds > 0) ...[
            SizedBox(height: AppSpace.xs),
            _captionMuted('Resend available in ${cooldownSeconds}s'),
          ],
        ],
        if (details.isAnonymous) ...[
          SizedBox(height: AppSpace.xs),
          _captionMuted('Sign in to verify your email.'),
        ],
      ],
    );
  }

  Widget _phoneCard({
    required dynamic details,
    required ProfileDetailsState state,
    required ProfileDetailsViewModel vm,
  }) {
    final cooldownSeconds = _cooldownRemainingSeconds(_phoneCooldownUntil);
    final canSend =
        !details.isAnonymous &&
        !state.isSendingPhoneCode &&
        !state.isLinkingPhone &&
        cooldownSeconds == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                details.phoneNumber?.isNotEmpty == true
                    ? details.phoneNumber!
                    : 'No phone linked',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(width: AppSpace.sm),
            StatusPill(
              label: details.isPhoneVerified ? 'Verified' : 'Not verified',
              variant: details.isPhoneVerified
                  ? StatusPillVariant.success
                  : StatusPillVariant.neutral,
            ),
          ],
        ),
        if (!details.isPhoneVerified) ...[
          SizedBox(height: AppSpace.sm),
          NovaSurface(
            padding: AppInsets.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NovaTextField(
                  controller: _phoneController,
                  density: NovaFieldDensity.comfortable,
                  labelText: 'Phone number',
                  hintText: '+12025550123',
                  enabled:
                      !details.isAnonymous &&
                      !state.isSendingPhoneCode &&
                      !state.isLinkingPhone,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: AppSpace.sm),
                SizedBox(
                  width: double.infinity,
                  child: NovaButton.primary(
                    label: 'Send code',
                    isLoading: state.isSendingPhoneCode,
                    onPressed: canSend
                        ? () async {
                            await vm.startPhoneVerification(
                              _phoneController.text,
                            );
                            _phoneCooldownUntil = DateTime.now().add(
                              const Duration(seconds: 30),
                            );
                            _startCooldownTicking();
                            if (mounted) setState(() {});
                          }
                        : null,
                  ),
                ),
                if (cooldownSeconds > 0) ...[
                  SizedBox(height: AppSpace.xs),
                  _captionMuted('Resend available in ${cooldownSeconds}s'),
                ],
              ],
            ),
          ),
          if (state.phoneVerificationId != null) ...[
            SizedBox(height: AppSpace.sm),
            NovaSurface(
              padding: AppInsets.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NovaTextField(
                    controller: _smsController,
                    density: NovaFieldDensity.comfortable,
                    labelText: 'SMS code',
                    enabled: !details.isAnonymous && !state.isLinkingPhone,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: AppSpace.sm),
                  SizedBox(
                    width: double.infinity,
                    child: NovaButton.primary(
                      label: 'Verify phone',
                      isLoading: state.isLinkingPhone,
                      onPressed: state.isLinkingPhone || details.isAnonymous
                          ? null
                          : () => vm.confirmPhoneCode(_smsController.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
        if (details.isAnonymous) ...[
          SizedBox(height: AppSpace.xs),
          _captionMuted('Sign in to verify your phone.'),
        ],
      ],
    );
  }
}
