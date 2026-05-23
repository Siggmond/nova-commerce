import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_tokens.dart';
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
    final t = AppLocalizations.of(context)!;
    return NovaSurface(
      elevation: 0,
      clipBehavior: Clip.none,
      color: cs.surface,
      borderRadius: AppRadii.xl,
      borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.28)),
      padding: AppInsets.card,
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
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
                  t.profileSignInRequiredTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: AppSpace.xxs),
                Text(
                  t.profileSignInRequiredSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.70),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpace.sm),
          SizedBox(
            height: AppHitTargets.min,
            child: NovaButton.primary(
              label: t.commonSignIn,
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
    final t = AppLocalizations.of(context)!;

    ref.listen<ProfileDetailsState>(profileDetailsViewModelProvider, (
      prev,
      next,
    ) {
      if (prev?.eventId == next.eventId) return;

      final err = next.eventError;
      if (err != null && err.trim().isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
        return;
      }

      final event = next.event;
      if (event == null) return;
      final msg = switch (event) {
        ProfileDetailsEvent.nameUpdated => t.profileSnackbarNameUpdated,
        ProfileDetailsEvent.verificationEmailSent =>
          t.profileSnackbarVerificationEmailSent,
        ProfileDetailsEvent.smsCodeSent => t.profileSnackbarSmsCodeSent,
        ProfileDetailsEvent.phoneVerified => t.profileSnackbarPhoneVerified,
        ProfileDetailsEvent.pleaseSignInToEditName =>
          t.profileSnackbarPleaseSignInToEditName,
        ProfileDetailsEvent.noEmailAttached => t.profileSnackbarNoEmailAttached,
        ProfileDetailsEvent.pleaseSignInToVerifyPhone =>
          t.profileSnackbarPleaseSignInToVerifyPhone,
        ProfileDetailsEvent.enterPhoneNumber => t.profileSnackbarEnterPhone,
        ProfileDetailsEvent.startPhoneVerificationFirst =>
          t.profileSnackbarStartPhoneVerificationFirst,
        ProfileDetailsEvent.enterSmsCode => t.profileSnackbarEnterSmsCode,
      };
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
              t.profileAccountDetailsTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              t.profileAccountDetailsSubtitle,
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
            padding: EdgeInsets.only(right: 8.w),
            child: _flatSurface(
              borderRadius: AppRadii.pill,
              padding: EdgeInsets.zero,
              child: IconButton(
                onPressed: state.isLoading ? null : () => vm.reload(),
                icon: const Icon(Icons.refresh),
                tooltip: t.commonRefresh,
              ),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
              children: [
                if (details == null)
                  _SignInRequiredCard(
                    onSignIn: () => context.push(AppRoutes.signIn),
                  )
                else ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: StatusPill(
                      label: t.profileVerifiedCountLabel(verifiedCount),
                      variant: verifiedCount == 2
                          ? StatusPillVariant.success
                          : StatusPillVariant.neutral,
                    ),
                  ),
                  SizedBox(height: AppSpace.md),
                  _heroCard(context, details, cs),
                  SizedBox(height: AppSpace.xl),
                  _sectionCard(
                    title: t.profileSectionProfileTitle,
                    subtitle: t.profileSectionProfileSubtitle,
                    child: _nameCard(details: details, state: state, vm: vm),
                  ),
                  SizedBox(height: AppSpace.xl),
                  _sectionCard(
                    title: t.profileSectionEmailTitle,
                    subtitle: t.profileSectionEmailSubtitle,
                    child: _emailCard(details: details, state: state, vm: vm),
                  ),
                  SizedBox(height: AppSpace.xl),
                  _sectionCard(
                    title: t.profileSectionPhoneTitle,
                    subtitle: t.profileSectionPhoneSubtitle,
                    child: _phoneCard(details: details, state: state, vm: vm),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _flatSurface({
    required Widget child,
    EdgeInsets? padding,
    Color? color,
    double? borderRadius,
  }) {
    final cs = Theme.of(context).colorScheme;
    return NovaSurface(
      padding: padding,
      color: color ?? cs.surface,
      borderRadius: borderRadius ?? AppRadii.xl,
      elevation: 0,
      clipBehavior: Clip.none,
      borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.28)),
      child: child,
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return _flatSurface(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
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
        height: 1.25,
      ),
    );
  }

  Widget _verificationSummary({
    required IconData icon,
    required String value,
    required bool verified,
  }) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;
    final tone = verified ? cs.primary : cs.onSurface;

    return Row(
      children: [
        Container(
          width: 42.r,
          height: 42.r,
          decoration: BoxDecoration(
            color: verified
                ? cs.primary.withValues(alpha: 0.10)
                : cs.surfaceContainerHighest.withValues(alpha: 0.44),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: verified
                  ? cs.primary.withValues(alpha: 0.18)
                  : cs.outlineVariant.withValues(alpha: 0.24),
            ),
          ),
          child: Icon(
            verified ? Icons.verified_rounded : icon,
            size: 20.r,
            color: verified ? cs.primary : tone.withValues(alpha: 0.64),
          ),
        ),
        SizedBox(width: AppSpace.md),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(width: AppSpace.sm),
        StatusPill(
          label: verified ? t.commonVerified : t.commonNotVerified,
          variant: verified
              ? StatusPillVariant.success
              : StatusPillVariant.neutral,
        ),
      ],
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
    final t = AppLocalizations.of(context)!;
    final avatar = Container(
      width: 56.r,
      height: 56.r,
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
      child: Icon(Icons.person, color: cs.primary, size: 28.r),
    );

    final title = Text(
      details.displayName.trim().isNotEmpty
          ? details.displayName
          : (details.isAnonymous
                ? t.profileGuestSessionTitle
                : t.profileYourAccountTitle),
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final subtitle = Text(
      details.isAnonymous
          ? t.profileAnonymousSyncHint
          : (details.email?.trim().isNotEmpty == true
                ? details.email!
                : t.profileSignedInLabel),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: cs.onSurface.withValues(alpha: 0.70),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    return _flatSurface(
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
                      StatusPill(label: t.profileDemoBadgeLabel),
                  ],
                ),
                SizedBox(height: AppSpace.xxs),
                subtitle,
                if (details.isAnonymous) ...[
                  SizedBox(height: AppSpace.sm),
                  _flatSurface(
                    borderRadius: AppRadii.lg,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 18.r,
                          color: cs.onSurface.withValues(alpha: 0.70),
                        ),
                        SizedBox(width: AppSpace.xs),
                        Expanded(
                          child: Text(
                            t.profileAnonymousSyncAndVerifyHint,
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
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NovaTextField(
          controller: _nameController,
          density: NovaFieldDensity.comfortable,
          labelText: t.profileFieldNameLabel,
          hintText: t.profileFieldNameHint,
          enabled: _editingName && !state.isSavingName,
        ),
        SizedBox(height: AppSpace.sm),
        _actionsRow(
          children: [
            _editingName
                ? NovaButton.primary(
                    label: state.isSavingName ? t.commonSaving : t.commonSave,
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
                    label: t.commonEdit,
                    onPressed: details.isAnonymous
                        ? null
                        : () => setState(() => _editingName = true),
                  ),
            if (_editingName)
              NovaButton.outlined(
                label: t.commonCancel,
                onPressed: () => setState(() => _editingName = false),
              ),
          ],
        ),
        if (details.isAnonymous) ...[
          SizedBox(height: AppSpace.xs),
          Text(
            t.profileAnonymousEditBlocked,
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
    final t = AppLocalizations.of(context)!;
    final emailText = details.email?.isNotEmpty == true
        ? details.email!
        : t.profileNoEmail;

    final cooldownSeconds = _cooldownRemainingSeconds(_emailCooldownUntil);
    final canSend =
        !details.isAnonymous && !state.isSendingEmail && cooldownSeconds == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _verificationSummary(
          icon: Icons.alternate_email_rounded,
          value: emailText,
          verified: details.isEmailVerified,
        ),
        if (!details.isEmailVerified) ...[
          SizedBox(height: AppSpace.sm),
          SizedBox(
            width: double.infinity,
            child: NovaButton.primary(
              label: t.profileVerifyEmailCta,
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
            _captionMuted(t.profileResendAvailableInSeconds(cooldownSeconds)),
          ],
        ],
        if (details.isAnonymous) ...[
          SizedBox(height: AppSpace.xs),
          _captionMuted(t.profileAnonymousEmailBlocked),
        ],
      ],
    );
  }

  Widget _phoneCard({
    required dynamic details,
    required ProfileDetailsState state,
    required ProfileDetailsViewModel vm,
  }) {
    final t = AppLocalizations.of(context)!;
    final cooldownSeconds = _cooldownRemainingSeconds(_phoneCooldownUntil);
    final canSend =
        !details.isAnonymous &&
        !state.isSendingPhoneCode &&
        !state.isLinkingPhone &&
        cooldownSeconds == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _verificationSummary(
          icon: Icons.phone_iphone_rounded,
          value: details.phoneNumber?.isNotEmpty == true
              ? details.phoneNumber!
              : t.profileNoPhoneLinked,
          verified: details.isPhoneVerified,
        ),
        if (!details.isPhoneVerified) ...[
          SizedBox(height: AppSpace.sm),
          _flatSurface(
            padding: AppInsets.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NovaTextField(
                  controller: _phoneController,
                  density: NovaFieldDensity.comfortable,
                  labelText: t.profileFieldPhoneLabel,
                  hintText: t.profileFieldPhoneHint,
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
                    label: t.profileSendCodeCta,
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
                  _captionMuted(
                    t.profileResendAvailableInSeconds(cooldownSeconds),
                  ),
                ],
              ],
            ),
          ),
          if (state.phoneVerificationId != null) ...[
            SizedBox(height: AppSpace.sm),
            _flatSurface(
              padding: AppInsets.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NovaTextField(
                    controller: _smsController,
                    density: NovaFieldDensity.comfortable,
                    labelText: t.profileFieldSmsCodeLabel,
                    enabled: !details.isAnonymous && !state.isLinkingPhone,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: AppSpace.sm),
                  SizedBox(
                    width: double.infinity,
                    child: NovaButton.primary(
                      label: t.profileVerifyPhoneCta,
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
          _captionMuted(t.profileAnonymousPhoneBlocked),
        ],
      ],
    );
  }
}
