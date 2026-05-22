import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nova_commerce/app/di/app_providers.dart';
import 'package:nova_commerce/features/auth/auth.dart';

enum SignInEmailError { requiredField, invalidFormat }

enum SignInPasswordError { requiredField }

sealed class SignInUiEvent {
  const SignInUiEvent();

  const factory SignInUiEvent.showMessage(String message) = SignInShowMessage;
  const factory SignInUiEvent.close() = SignInClose;
}

class SignInShowMessage extends SignInUiEvent {
  const SignInShowMessage(this.message);

  final String message;
}

class SignInClose extends SignInUiEvent {
  const SignInClose();
}

class SignInState {
  const SignInState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.showPassword = false,
    this.isBusy = false,
    this.event,
    this.eventId = 0,
  });

  final String email;
  final String password;
  final SignInEmailError? emailError;
  final SignInPasswordError? passwordError;
  final bool showPassword;
  final bool isBusy;
  final SignInUiEvent? event;
  final int eventId;

  static const Object _unset = Object();

  SignInState copyWith({
    String? email,
    String? password,
    SignInEmailError? emailError,
    SignInPasswordError? passwordError,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool? showPassword,
    bool? isBusy,
    Object? event = _unset,
    int? eventId,
  }) {
    return SignInState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError: clearPasswordError
          ? null
          : (passwordError ?? this.passwordError),
      showPassword: showPassword ?? this.showPassword,
      isBusy: isBusy ?? this.isBusy,
      event: event == _unset ? this.event : event as SignInUiEvent?,
      eventId: eventId ?? this.eventId,
    );
  }
}

final signInControllerProvider =
    StateNotifierProvider.autoDispose<SignInController, SignInState>((ref) {
      return SignInController(ref);
    });

class SignInController extends StateNotifier<SignInState> {
  SignInController(
    this._ref, {
    ValidateAuthCredentialsUseCase validateCredentialsUseCase =
        const ValidateAuthCredentialsUseCase(),
  }) : _validateCredentialsUseCase = validateCredentialsUseCase,
       super(const SignInState());

  final Ref _ref;
  final ValidateAuthCredentialsUseCase _validateCredentialsUseCase;

  void setEmail(String value) {
    state = state.copyWith(email: value, clearEmailError: true);
  }

  void setPassword(String value) {
    state = state.copyWith(password: value, clearPasswordError: true);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(showPassword: !state.showPassword);
  }

  Future<void> signInEmail() {
    return _authenticate(
      action: (auth) =>
          auth.signInEmail(email: state.email.trim(), password: state.password),
      validateCredentials: true,
    );
  }

  Future<void> signUpEmail() {
    return _authenticate(
      action: (auth) => auth.createAccount(
        email: state.email.trim(),
        password: state.password,
      ),
      validateCredentials: true,
    );
  }

  Future<void> signInGoogle() {
    return _authenticate(action: (auth) => auth.signInWithGoogle());
  }

  Future<void> continueAsGuest() {
    return _authenticate(action: (auth) => auth.signInAnonymously());
  }

  Future<void> _authenticate({
    required Future<AuthUser> Function(AuthRepository auth) action,
    bool validateCredentials = false,
  }) async {
    if (state.isBusy) return;

    if (validateCredentials) {
      final validation = _validateCredentialsUseCase(
        email: state.email,
        password: state.password,
      );
      if (!validation.isValid) {
        state = state.copyWith(
          emailError: switch (validation.emailError) {
            EmailValidationError.requiredField =>
              SignInEmailError.requiredField,
            EmailValidationError.invalidFormat =>
              SignInEmailError.invalidFormat,
            null => null,
          },
          passwordError: switch (validation.passwordError) {
            PasswordValidationError.requiredField =>
              SignInPasswordError.requiredField,
            null => null,
          },
        );
        return;
      }
    }

    final auth = _ref.read(authRepositoryProvider);
    state = state.copyWith(
      isBusy: true,
      clearEmailError: true,
      clearPasswordError: true,
    );
    try {
      await action(auth);
      final notice = auth.takeFallbackNotice();
      if (notice != null && notice.trim().isNotEmpty) {
        _emit(SignInUiEvent.showMessage(notice));
      }
      _emit(const SignInUiEvent.close());
    } on AuthException catch (e) {
      _emit(SignInUiEvent.showMessage(e.message));
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }

  void _emit(SignInUiEvent event) {
    state = state.copyWith(event: event, eventId: state.eventId + 1);
  }
}
