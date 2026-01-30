import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/auth_providers.dart';
import '../../../domain/entities/auth_account_details.dart';
import '../../../domain/repositories/auth_repository.dart';

class ProfileDetailsState {
  const ProfileDetailsState({
    this.details,
    this.isLoading = false,
    this.isSavingName = false,
    this.isSendingEmail = false,
    this.isSendingPhoneCode = false,
    this.isLinkingPhone = false,
    this.phoneVerificationId,
    this.event,
    this.eventId = 0,
  });

  final AuthAccountDetails? details;
  final bool isLoading;
  final bool isSavingName;
  final bool isSendingEmail;
  final bool isSendingPhoneCode;
  final bool isLinkingPhone;
  final String? phoneVerificationId;

  final String? event;
  final int eventId;

  static const Object _unset = Object();

  ProfileDetailsState copyWith({
    AuthAccountDetails? details,
    bool? isLoading,
    bool? isSavingName,
    bool? isSendingEmail,
    bool? isSendingPhoneCode,
    bool? isLinkingPhone,
    String? phoneVerificationId,
    Object? event = _unset,
    int? eventId,
  }) {
    return ProfileDetailsState(
      details: details ?? this.details,
      isLoading: isLoading ?? this.isLoading,
      isSavingName: isSavingName ?? this.isSavingName,
      isSendingEmail: isSendingEmail ?? this.isSendingEmail,
      isSendingPhoneCode: isSendingPhoneCode ?? this.isSendingPhoneCode,
      isLinkingPhone: isLinkingPhone ?? this.isLinkingPhone,
      phoneVerificationId: phoneVerificationId ?? this.phoneVerificationId,
      event: event == _unset ? this.event : event as String?,
      eventId: eventId ?? this.eventId,
    );
  }
}

final profileDetailsViewModelProvider =
    StateNotifierProvider<ProfileDetailsViewModel, ProfileDetailsState>((ref) {
  return ProfileDetailsViewModel(ref.read(authRepositoryProvider));
});

class ProfileDetailsViewModel extends StateNotifier<ProfileDetailsState> {
  ProfileDetailsViewModel(this._auth) : super(const ProfileDetailsState()) {
    load();
  }

  final AuthRepository _auth;
  int _requestId = 0;

  Future<void> load() async {
    final requestId = ++_requestId;
    state = state.copyWith(isLoading: true);
    try {
      final details = await _auth.getAccountDetails();
      if (requestId != _requestId) return;
      state = state.copyWith(details: details, isLoading: false);
    } catch (e) {
      if (requestId != _requestId) return;
      state = state.copyWith(isLoading: false);
      _emit(e.toString());
    }
  }

  Future<void> reload() async {
    final requestId = ++_requestId;
    state = state.copyWith(isLoading: true);
    try {
      final details = await _auth.reloadAccountDetails();
      if (requestId != _requestId) return;
      state = state.copyWith(details: details, isLoading: false);
    } catch (e) {
      if (requestId != _requestId) return;
      state = state.copyWith(isLoading: false);
      _emit(e.toString());
    }
  }

  Future<void> saveDisplayName(String displayName) async {
    final details = state.details;
    if (details == null) return;
    if (details.isAnonymous) {
      _emit('Please sign in to edit your name.');
      return;
    }

    final requestId = ++_requestId;
    state = state.copyWith(isSavingName: true);
    try {
      await _auth.updateDisplayName(displayName.trim());
      final updated = await _auth.reloadAccountDetails();
      if (requestId != _requestId) return;
      state = state.copyWith(details: updated, isSavingName: false);
      _emit('Name updated');
    } catch (e) {
      if (requestId != _requestId) return;
      state = state.copyWith(isSavingName: false);
      _emit(e.toString());
    }
  }

  Future<void> sendEmailVerification() async {
    final details = state.details;
    if (details == null) return;
    if (details.isAnonymous || details.email == null || details.email!.isEmpty) {
      _emit('No email attached to this account.');
      return;
    }

    final requestId = ++_requestId;
    state = state.copyWith(isSendingEmail: true);
    try {
      await _auth.sendEmailVerification();
      if (requestId != _requestId) return;
      state = state.copyWith(isSendingEmail: false);
      _emit('Verification email sent');
    } catch (e) {
      if (requestId != _requestId) return;
      state = state.copyWith(isSendingEmail: false);
      _emit(e.toString());
    }
  }

  Future<void> startPhoneVerification(String phoneNumber) async {
    final details = state.details;
    if (details == null) return;
    if (details.isAnonymous) {
      _emit('Please sign in to verify a phone number.');
      return;
    }
    if (phoneNumber.trim().isEmpty) {
      _emit('Enter a phone number');
      return;
    }

    final requestId = ++_requestId;
    state = state.copyWith(isSendingPhoneCode: true, phoneVerificationId: null);
    try {
      final session = await _auth.startPhoneVerification(
        phoneNumber: phoneNumber.trim(),
      );
      if (requestId != _requestId) return;
      state = state.copyWith(
        isSendingPhoneCode: false,
        phoneVerificationId: session.verificationId.isEmpty
            ? null
            : session.verificationId,
      );
      _emit('SMS code sent');
    } catch (e) {
      if (requestId != _requestId) return;
      state = state.copyWith(isSendingPhoneCode: false);
      _emit(e.toString());
    }
  }

  Future<void> confirmPhoneCode(String smsCode) async {
    final details = state.details;
    final verificationId = state.phoneVerificationId;
    if (details == null) return;
    if (verificationId == null || verificationId.isEmpty) {
      _emit('Start phone verification first.');
      return;
    }
    if (smsCode.trim().isEmpty) {
      _emit('Enter the SMS code');
      return;
    }

    final requestId = ++_requestId;
    state = state.copyWith(isLinkingPhone: true);
    try {
      await _auth.linkPhoneWithSmsCode(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      final updated = await _auth.reloadAccountDetails();
      if (requestId != _requestId) return;
      state = state.copyWith(
        details: updated,
        isLinkingPhone: false,
        phoneVerificationId: null,
      );
      _emit('Phone verified');
    } catch (e) {
      if (requestId != _requestId) return;
      state = state.copyWith(isLinkingPhone: false);
      _emit(e.toString());
    }
  }

  void _emit(String message) {
    state = state.copyWith(event: message, eventId: state.eventId + 1);
  }
}
