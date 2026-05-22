enum EmailValidationError { requiredField, invalidFormat }

enum PasswordValidationError { requiredField }

class AuthCredentialsValidationResult {
  const AuthCredentialsValidationResult({this.emailError, this.passwordError});

  final EmailValidationError? emailError;
  final PasswordValidationError? passwordError;

  bool get isValid => emailError == null && passwordError == null;
}

class ValidateAuthCredentialsUseCase {
  const ValidateAuthCredentialsUseCase();

  AuthCredentialsValidationResult call({
    required String email,
    required String password,
  }) {
    final trimmedEmail = email.trim();

    final emailError = trimmedEmail.isEmpty
        ? EmailValidationError.requiredField
        : (_isValidEmail(trimmedEmail)
              ? null
              : EmailValidationError.invalidFormat);

    final passwordError = password.isEmpty
        ? PasswordValidationError.requiredField
        : null;

    return AuthCredentialsValidationResult(
      emailError: emailError,
      passwordError: passwordError,
    );
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }
}
