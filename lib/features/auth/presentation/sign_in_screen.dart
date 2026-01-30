import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/auth_providers.dart';
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

  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signInEmail() async {
    final auth = ref.read(authRepositoryProvider);
    final email = _email.text.trim();
    final password = _password.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter email and password.')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      await auth.signInEmail(email: email, password: password);
      _maybeShowFallbackNotice(auth);
      if (!mounted) return;
      context.pop();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signUpEmail() async {
    final auth = ref.read(authRepositoryProvider);
    final email = _email.text.trim();
    final password = _password.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter email and password.')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      await auth.createAccount(email: email, password: password);
      _maybeShowFallbackNotice(auth);
      if (!mounted) return;
      context.pop();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _maybeShowFallbackNotice(AuthRepository auth) {
    final notice = auth.takeFallbackNotice();
    if (notice == null || !mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(notice)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: AppInsets.screen,
          children: [
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: AppSpace.sm),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: AppSpace.md),
            SizedBox(
              width: double.infinity,
              child: AppButton.primary(
                label: 'Sign in',
                onPressed: _signInEmail,
                isLoading: _busy,
              ),
            ),
            SizedBox(height: AppSpace.sm),
            SizedBox(
              width: double.infinity,
              child: AppButton.outlined(
                label: 'Create account',
                onPressed: _signUpEmail,
                isLoading: _busy,
              ),
            ),
            SizedBox(height: AppSpace.sm),
            SizedBox(
              width: double.infinity,
              child: AppButton.outlined(
                label: 'Continue with Google',
                onPressed: _signInGoogle,
                isLoading: _busy,
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
    );
  }
}
