import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../core/config/app_routes.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account details'),
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
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
              children: [
                if (details == null)
                  _LegacySignInRequiredCard(
                    onSignIn: () => context.push(AppRoutes.signIn),
                  )
                else ...[
                  _sectionTitle(context, 'Display name'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              enabled: _editingName && !state.isSavingName,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Name',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!_editingName)
                            TextButton(
                              onPressed: details.isAnonymous
                                  ? null
                                  : () => setState(() => _editingName = true),
                              child: const Text('Edit'),
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
                                  ? const Text('Saving...')
                                  : const Text('Save'),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (details.isAnonymous)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Sign in to edit your profile.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  const SizedBox(height: 14),
                  _sectionTitle(context, 'Email'),
                  Card(
                    child: ListTile(
                      title: Text(
                        details.email?.isNotEmpty == true
                            ? details.email!
                            : 'No email',
                      ),
                      subtitle: Text(
                        details.isEmailVerified ? 'Verified' : 'Not verified',
                      ),
                      trailing: details.isEmailVerified
                          ? const Icon(Icons.verified)
                          : ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 140),
                              child: AppButton.tonal(
                                label: 'Verify email',
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
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Sign in to verify your email.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  const SizedBox(height: 14),
                  _sectionTitle(context, 'Phone number'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details.phoneNumber?.isNotEmpty == true
                                ? details.phoneNumber!
                                : 'No phone linked',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            details.isPhoneVerified
                                ? 'Verified'
                                : 'Not verified',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          if (!details.isPhoneVerified) ...[
                            TextField(
                              controller: _phoneController,
                              enabled:
                                  !details.isAnonymous &&
                                  !state.isSendingPhoneCode &&
                                  !state.isLinkingPhone,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Phone number',
                                hintText: '+12025550123',
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 10),
                            AppButton.primary(
                              label: 'Send code',
                              isLoading: state.isSendingPhoneCode,
                              onPressed:
                                  state.isSendingPhoneCode ||
                                      details.isAnonymous
                                  ? null
                                  : () => vm.startPhoneVerification(
                                      _phoneController.text,
                                    ),
                            ),
                            const SizedBox(height: 10),
                            if (state.phoneVerificationId != null) ...[
                              TextField(
                                controller: _smsController,
                                enabled: !state.isLinkingPhone,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'SMS code',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 10),
                              AppButton.primary(
                                label: 'Verify phone',
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
                      padding: const EdgeInsets.only(top: 6),
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

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.person_outline, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sign in required',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sign in to view and update your account details.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.70),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 36,
              child: FilledButton(
                onPressed: onSignIn,
                child: const Text('Sign in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
