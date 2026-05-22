class AuthAccountDetails {
  const AuthAccountDetails({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.isEmailVerified,
    required this.phoneNumber,
    required this.isPhoneVerified,
    required this.isAnonymous,
    required this.isDemo,
  });

  final String uid;
  final String displayName;
  final String? email;
  final bool isEmailVerified;
  final String? phoneNumber;
  final bool isPhoneVerified;
  final bool isAnonymous;
  final bool isDemo;
}

class PhoneVerificationSession {
  const PhoneVerificationSession({required this.verificationId});

  final String verificationId;
}
