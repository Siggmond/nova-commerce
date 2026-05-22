import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import 'profile_details_viewmodel.dart';

class ProfileDetailsScreen extends ConsumerStatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  ConsumerState<ProfileDetailsScreen> createState() =>
      _ProfileDetailsScreenState();
}

class _ProfileDetailsLifecycle extends WidgetsBindingObserver {
  _ProfileDetailsLifecycle({required this.onResume});

  final VoidCallback onResume;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResume();
    }
  }
}

class _ProfileDetailsScreenState extends ConsumerState<ProfileDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycle);
  }

  late final _lifecycle = _ProfileDetailsLifecycle(
    onResume: () {
      ref.read(profileDetailsViewModelProvider.notifier).reload();
    },
  );

  final _nameController = TextEditingController();
  bool _editingName = false;

  final _phoneController = TextEditingController();
  final _smsController = TextEditingController();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycle);
    _nameController.dispose();
    _phoneController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      debugPrint('OPENED: LEGACY ProfileDetailsScreen');
      return true;
    }());
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

    return Scaffold(
      appBar: AppBar(
        title: Text(t.profileAccountDetailsTitle),
        actions: [
          IconButton(
            onPressed: state.isLoading ? null : () => vm.reload(),
            tooltip: t.commonRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 14.h),
              children: [
                if (details == null)
                  _LegacySignInRequiredCard(
                    onSignIn: () => context.push(AppRoutes.signIn),
                  )
                else ...[
                  _sectionTitle(context, t.profileSectionDisplayName),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              enabled: _editingName && !state.isSavingName,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: t.profileFieldNameLabel,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          if (!_editingName)
                            TextButton(
                              onPressed: details.isAnonymous
                                  ? null
                                  : () => setState(() => _editingName = true),
                              child: Text(t.commonEdit),
                            )
                          else
                            TextButton(
                              onPressed: state.isSavingName
                                  ? null
                                  : () async {
                                      await vm.saveDisplayName(
                                        _nameController.text,
                                      );
                                      if (mounted) {
                                        setState(() => _editingName = false);
                                      }
                                    },
                              child: state.isSavingName
                                  ? Text(t.commonSaving)
                                  : Text(t.commonSave),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (details.isAnonymous)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Text(
                        t.profileAnonymousEditBlocked,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  SizedBox(height: 14.h),
                  _sectionTitle(context, t.profileSectionEmail),
                  Card(
                    child: ListTile(
                      title: Text(
                        details.email?.isNotEmpty == true
                            ? details.email!
                            : t.profileNoEmail,
                      ),
                      subtitle: Text(
                        details.isEmailVerified
                            ? t.commonVerified
                            : t.commonNotVerified,
                      ),
                      trailing: details.isEmailVerified
                          ? const Icon(Icons.verified)
                          : ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 140.w),
                              child: AppButton.tonal(
                                label: t.profileVerifyEmailCta,
                                isLoading: state.isSendingEmail,
                                onPressed: state.isSendingEmail
                                    ? null
                                    : details.isAnonymous
                                    ? null
                                    : () => vm.sendEmailVerification(),
                              ),
                            ),
                    ),
                  ),
                  if (details.isAnonymous)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Text(
                        t.profileAnonymousEmailBlocked,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  SizedBox(height: 14.h),
                  _sectionTitle(context, t.profileSectionPhoneNumber),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details.phoneNumber?.isNotEmpty == true
                                ? details.phoneNumber!
                                : t.profileNoPhoneLinked,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            details.isPhoneVerified
                                ? t.commonVerified
                                : t.commonNotVerified,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          SizedBox(height: 12.h),
                          if (!details.isPhoneVerified) ...[
                            TextField(
                              controller: _phoneController,
                              enabled:
                                  !details.isAnonymous &&
                                  !state.isSendingPhoneCode &&
                                  !state.isLinkingPhone,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: t.profileFieldPhoneLabel,
                                hintText: t.profileFieldPhoneHint,
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            SizedBox(height: 10.h),
                            AppButton.primary(
                              label: t.profileSendCodeCta,
                              isLoading: state.isSendingPhoneCode,
                              onPressed:
                                  state.isSendingPhoneCode ||
                                      details.isAnonymous
                                  ? null
                                  : () => vm.startPhoneVerification(
                                      _phoneController.text,
                                    ),
                            ),
                            SizedBox(height: 10.h),
                            if (state.phoneVerificationId != null) ...[
                              TextField(
                                controller: _smsController,
                                enabled: !state.isLinkingPhone,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: t.profileFieldSmsCodeLabel,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              SizedBox(height: 10.h),
                              AppButton.primary(
                                label: t.profileVerifyPhoneCta,
                                isLoading: state.isLinkingPhone,
                                onPressed:
                                    state.isLinkingPhone || details.isAnonymous
                                    ? null
                                    : () => vm.confirmPhoneCode(
                                        _smsController.text,
                                      ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (details.isAnonymous)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Text(
                        t.profileAnonymousPhoneBlocked,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                ],
              ],
            ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _LegacySignInRequiredCard extends StatelessWidget {
  const _LegacySignInRequiredCard({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
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
                    t.profileSignInRequiredTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    t.profileSignInRequiredSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.70),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            SizedBox(
              height: 36.h,
              child: FilledButton(
                onPressed: onSignIn,
                child: Text(t.commonSignIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
