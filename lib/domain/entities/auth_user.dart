class AuthUser {
  const AuthUser({
    required this.uid,
    this.email,
    required this.isAnonymous,
    required this.isDemo,
  });

  final String uid;
  final String? email;
  final bool isAnonymous;
  final bool isDemo;
}
