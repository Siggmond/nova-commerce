import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phone_number/phone_number.dart';
import 'package:http/http.dart' as http;

import 'package:nova_commerce/app/config/app_env.dart';
import 'package:nova_commerce/app/di/app_providers.dart';
import 'package:nova_commerce/core/errors/checkout_exceptions.dart';
import 'package:nova_commerce/core/perf/perf_markers.dart';
import 'package:nova_commerce/features/cart/cart.dart';
import 'package:nova_commerce/features/checkout/domain/checkout_address_store.dart';
import 'package:nova_commerce/features/checkout/domain/checkout_cart_summary.dart';
import 'package:nova_commerce/features/checkout/domain/usecases/build_checkout_summary_use_case.dart';
import 'package:nova_commerce/features/checkout/domain/usecases/validate_checkout_form_use_case.dart';

enum CheckoutSnackKey { cartEmpty, signInRequired, somethingWentWrongTryAgain }

enum CheckoutFieldErrorKey { requiredField, invalidPhone }

class PlaceSuggestion {
  const PlaceSuggestion({required this.placeId, required this.description});

  final String placeId;
  final String description;
}

abstract class PhoneNormalizer {
  Future<String?> toE164({required String input, required String regionCode});
}

class PhoneNumberNormalizer implements PhoneNormalizer {
  PhoneNumberNormalizer() : _util = PhoneNumberUtil();

  final PhoneNumberUtil _util;
  static final RegExp _nonDigitOrPlusRegExp = RegExp(r'[^\d\+]');
  static final RegExp _nonDigitRegExp = RegExp(r'[^\d]');
  static final RegExp _lbPhonePattern = RegExp(r'^(3\d{6}|7\d{7})$');

  @override
  Future<String?> toE164({
    required String input,
    required String regionCode,
  }) async {
    if (input.trim().isEmpty) return null;

    final trimmed = input.trim();
    final normalized = trimmed.startsWith('+')
        ? trimmed.replaceAll(_nonDigitOrPlusRegExp, '')
        : trimmed.replaceAll(_nonDigitRegExp, '');

    if (normalized.isEmpty) return null;

    final rc = regionCode.toUpperCase();
    if (rc == 'LB') {
      String digits;
      if (normalized.startsWith('+')) {
        digits = normalized.substring(1);
      } else {
        digits = normalized;
      }

      if (digits.startsWith('961')) {
        digits = digits.substring(3);
      } else if (digits.startsWith('0') && digits.length > 1) {
        digits = digits.substring(1);
      }

      final ok = _lbPhonePattern.hasMatch(digits);
      if (!ok) return null;
      return '+961$digits';
    }

    try {
      final parsed = await _util.parse(normalized, regionCode: regionCode);
      return parsed.e164;
    } catch (_) {
      return null;
    }
  }
}

class ParsedAddress {
  const ParsedAddress({
    required this.addressLine,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  final String addressLine;
  final String city;
  final String state;
  final String postalCode;
  final String country;
}

Map<String, Object?> _parseAutocompletePayload(String rawBody) {
  try {
    final decoded = jsonDecode(rawBody);
    if (decoded is! Map<String, dynamic>) {
      return {'ok': false, 'suggestions': const <Map<String, String>>[]};
    }

    final status = decoded['status'] as String?;
    if (status != 'OK' && status != 'ZERO_RESULTS') {
      return {'ok': false, 'suggestions': const <Map<String, String>>[]};
    }

    final rawPredictions = decoded['predictions'] as List<dynamic>? ?? const [];
    final suggestions = <Map<String, String>>[];
    for (final raw in rawPredictions) {
      if (raw is! Map<String, dynamic>) continue;
      final placeId = (raw['place_id'] as String? ?? '').trim();
      final description = (raw['description'] as String? ?? '').trim();
      if (placeId.isEmpty || description.isEmpty) continue;
      suggestions.add({'placeId': placeId, 'description': description});
    }

    return {'ok': true, 'suggestions': suggestions};
  } catch (_) {
    return {'ok': false, 'suggestions': const <Map<String, String>>[]};
  }
}

Map<String, Object?> _parsePlaceDetailsPayload(String rawBody) {
  try {
    final decoded = jsonDecode(rawBody);
    if (decoded is! Map<String, dynamic>) return {'ok': false};

    final status = decoded['status'] as String?;
    if (status != 'OK') return {'ok': false};

    final result = decoded['result'] as Map<String, dynamic>? ?? const {};
    final components =
        result['address_components'] as List<dynamic>? ?? const <dynamic>[];
    final parsed = _extractAddressPartsFromComponents(components);
    if (parsed == null) return {'ok': false};

    return {'ok': true, ...parsed};
  } catch (_) {
    return {'ok': false};
  }
}

Map<String, String>? _extractAddressPartsFromComponents(
  List<dynamic> components,
) {
  String streetNumber = '';
  String route = '';
  String locality = '';
  String adminArea = '';
  String postalCode = '';
  String country = '';

  for (final raw in components) {
    if (raw is! Map<String, dynamic>) continue;
    final types = (raw['types'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toSet();
    final longName = (raw['long_name'] as String? ?? '').trim();

    if (types.contains('street_number')) {
      streetNumber = longName;
    } else if (types.contains('route')) {
      route = longName;
    } else if (types.contains('locality')) {
      locality = longName;
    } else if (types.contains('postal_town') && locality.isEmpty) {
      locality = longName;
    } else if (types.contains('administrative_area_level_1')) {
      adminArea = longName;
    } else if (types.contains('postal_code')) {
      postalCode = longName;
    } else if (types.contains('country')) {
      country = longName;
    }
  }

  final streetLine = [
    streetNumber,
    route,
  ].where((e) => e.isNotEmpty).join(' ').trim();
  if (streetLine.isEmpty && locality.isEmpty && country.isEmpty) {
    return null;
  }

  return {
    'addressLine': streetLine,
    'city': locality,
    'state': adminArea,
    'postalCode': postalCode,
    'country': country,
  };
}

const Duration _checkoutPricingIsolateThreshold = Duration(microseconds: 8000);

Map<String, double> _evaluateCheckoutPricingPayload(Map<String, Object?> raw) {
  final subtotal = (raw['subtotal'] as num? ?? 0).toDouble();
  final itemCount = (raw['itemCount'] as num? ?? 0).toInt();
  final country = (raw['country'] as String? ?? '').trim().toUpperCase();
  final state = (raw['state'] as String? ?? '').trim().toUpperCase();
  final postalCode = (raw['postalCode'] as String? ?? '').trim();
  final city = (raw['city'] as String? ?? '').trim().toUpperCase();
  final address = (raw['address'] as String? ?? '').trim().toUpperCase();

  double shippingFee = 0;
  if (subtotal > 0 && subtotal < 50 && itemCount > 0) {
    shippingFee = 4.99;
    if (country != 'US') shippingFee = 8.99;
  }

  var taxRate = 0.0;
  if (country == 'US') {
    taxRate = 0.05;
    if (state == 'CA') taxRate = 0.0825;
    if (state == 'NY') taxRate = 0.08875;
  }

  if (postalCode.startsWith('9')) taxRate += 0.0025;
  if (city.contains('NEW YORK')) taxRate += 0.001;
  if (address.contains('APT')) taxRate += 0.0;

  final taxAmount = (subtotal * taxRate).clamp(0, double.infinity).toDouble();
  const discountAmount = 0.0;
  return <String, double>{
    'shippingFee': shippingFee,
    'taxAmount': taxAmount,
    'discountAmount': discountAmount,
  };
}

final checkoutCartSummaryProvider = Provider<CheckoutCartSummary>((ref) {
  return ref.watch(checkoutViewModelProvider.select((s) => s.summary));
});

typedef CheckoutFormViewState = ({
  String fullName,
  String phone,
  String phoneDialCode,
  CheckoutFieldErrorKey? fullNameError,
  CheckoutFieldErrorKey? phoneError,
  String address,
  CheckoutFieldErrorKey? addressError,
  bool placesConfigured,
  bool manualEntryOnly,
  bool isFetchingSuggestions,
  bool placesUnavailable,
  bool placesAvailable,
  List<PlaceSuggestion> addressSuggestions,
  String city,
  CheckoutFieldErrorKey? cityError,
  String state,
  CheckoutFieldErrorKey? stateError,
  String postalCode,
  CheckoutFieldErrorKey? postalCodeError,
  String country,
  CheckoutFieldErrorKey? countryError,
});

final checkoutFormViewProvider = Provider<CheckoutFormViewState>((ref) {
  return ref.watch(
    checkoutViewModelProvider.select(
      (s) => (
        fullName: s.fullName,
        phone: s.phone,
        phoneDialCode: s.phoneDialCode,
        fullNameError: s.fullNameError,
        phoneError: s.phoneError,
        address: s.address,
        addressError: s.addressError,
        placesConfigured: s.placesConfigured,
        manualEntryOnly: s.manualEntryOnly,
        isFetchingSuggestions: s.isFetchingSuggestions,
        placesUnavailable: s.placesUnavailable,
        placesAvailable: s.placesAvailable,
        addressSuggestions: s.addressSuggestions,
        city: s.city,
        cityError: s.cityError,
        state: s.state,
        stateError: s.stateError,
        postalCode: s.postalCode,
        postalCodeError: s.postalCodeError,
        country: s.country,
        countryError: s.countryError,
      ),
    ),
  );
});

typedef CheckoutActionViewState = ({
  bool isSubmitting,
  bool hasSelectedItems,
  bool isSignedIn,
  bool isRecalculatingSummary,
});

final checkoutActionViewProvider = Provider<CheckoutActionViewState>((ref) {
  return ref.watch(
    checkoutViewModelProvider.select(
      (s) => (
        isSubmitting: s.isSubmitting,
        hasSelectedItems: s.hasSelectedItems,
        isSignedIn: s.isSignedIn,
        isRecalculatingSummary: s.isRecalculatingSummary,
      ),
    ),
  );
});

sealed class CheckoutEvent {
  const CheckoutEvent();

  const factory CheckoutEvent.showSnack({
    CheckoutSnackKey? key,
    String? message,
  }) = CheckoutShowSnack;
  const factory CheckoutEvent.goToSignIn() = CheckoutGoToSignIn;
  const factory CheckoutEvent.goToPayment({
    required String uid,
    required String deviceId,
    required Map<String, String> shipping,
  }) = CheckoutGoToPayment;
  const factory CheckoutEvent.goToSuccess(String orderId) = CheckoutGoToSuccess;
}

class CheckoutShowSnack extends CheckoutEvent {
  const CheckoutShowSnack({this.key, this.message});

  final CheckoutSnackKey? key;
  final String? message;
}

class CheckoutGoToSignIn extends CheckoutEvent {
  const CheckoutGoToSignIn();
}

class CheckoutGoToSuccess extends CheckoutEvent {
  const CheckoutGoToSuccess(this.orderId);

  final String orderId;
}

class CheckoutGoToPayment extends CheckoutEvent {
  const CheckoutGoToPayment({
    required this.uid,
    required this.deviceId,
    required this.shipping,
  });

  final String uid;
  final String deviceId;
  final Map<String, String> shipping;
}

class CheckoutState {
  const CheckoutState({
    this.fullName = '',
    this.phone = '',
    this.phoneRegionCode = 'US',
    this.phoneDialCode = '+1',
    this.address = '',
    this.city = '',
    this.state = '',
    this.postalCode = '',
    this.country = '',
    this.addressSuggestions = const [],
    this.isFetchingSuggestions = false,
    this.placesAvailable = false,
    this.placesConfigured = false,
    this.placesUnavailable = false,
    this.manualEntryOnly = false,
    this.fullNameError,
    this.phoneError,
    this.addressError,
    this.cityError,
    this.stateError,
    this.postalCodeError,
    this.countryError,
    this.isSubmitting = false,
    this.hasSelectedItems = false,
    this.isSignedIn = false,
    this.summary = const CheckoutCartSummary.empty(),
    this.isRecalculatingSummary = false,
    this.event,
    this.eventId = 0,
  });

  final String fullName;
  final String phone;
  final String phoneRegionCode;
  final String phoneDialCode;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  final List<PlaceSuggestion> addressSuggestions;
  final bool isFetchingSuggestions;
  final bool placesAvailable;
  final bool placesConfigured;
  final bool placesUnavailable;
  final bool manualEntryOnly;

  final CheckoutFieldErrorKey? fullNameError;
  final CheckoutFieldErrorKey? phoneError;
  final CheckoutFieldErrorKey? addressError;
  final CheckoutFieldErrorKey? cityError;
  final CheckoutFieldErrorKey? stateError;
  final CheckoutFieldErrorKey? postalCodeError;
  final CheckoutFieldErrorKey? countryError;

  final bool isSubmitting;
  final bool hasSelectedItems;
  final bool isSignedIn;
  final CheckoutCartSummary summary;
  final bool isRecalculatingSummary;

  final CheckoutEvent? event;
  final int eventId;

  static const Object _unset = Object();

  CheckoutState copyWith({
    String? fullName,
    String? phone,
    String? phoneRegionCode,
    String? phoneDialCode,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    List<PlaceSuggestion>? addressSuggestions,
    bool? isFetchingSuggestions,
    bool? placesAvailable,
    bool? placesConfigured,
    bool? placesUnavailable,
    bool? manualEntryOnly,
    CheckoutFieldErrorKey? fullNameError,
    CheckoutFieldErrorKey? phoneError,
    CheckoutFieldErrorKey? addressError,
    CheckoutFieldErrorKey? cityError,
    CheckoutFieldErrorKey? stateError,
    CheckoutFieldErrorKey? postalCodeError,
    CheckoutFieldErrorKey? countryError,
    bool clearErrors = false,
    bool? isSubmitting,
    bool? hasSelectedItems,
    bool? isSignedIn,
    CheckoutCartSummary? summary,
    bool? isRecalculatingSummary,
    Object? event = _unset,
    int? eventId,
  }) {
    return CheckoutState(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      phoneRegionCode: phoneRegionCode ?? this.phoneRegionCode,
      phoneDialCode: phoneDialCode ?? this.phoneDialCode,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      addressSuggestions: addressSuggestions ?? this.addressSuggestions,
      isFetchingSuggestions:
          isFetchingSuggestions ?? this.isFetchingSuggestions,
      placesAvailable: placesAvailable ?? this.placesAvailable,
      placesConfigured: placesConfigured ?? this.placesConfigured,
      placesUnavailable: placesUnavailable ?? this.placesUnavailable,
      manualEntryOnly: manualEntryOnly ?? this.manualEntryOnly,
      fullNameError: clearErrors ? null : (fullNameError ?? this.fullNameError),
      phoneError: clearErrors ? null : (phoneError ?? this.phoneError),
      addressError: clearErrors ? null : (addressError ?? this.addressError),
      cityError: clearErrors ? null : (cityError ?? this.cityError),
      stateError: clearErrors ? null : (stateError ?? this.stateError),
      postalCodeError: clearErrors
          ? null
          : (postalCodeError ?? this.postalCodeError),
      countryError: clearErrors ? null : (countryError ?? this.countryError),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasSelectedItems: hasSelectedItems ?? this.hasSelectedItems,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      summary: summary ?? this.summary,
      isRecalculatingSummary:
          isRecalculatingSummary ?? this.isRecalculatingSummary,
      event: event == _unset ? this.event : event as CheckoutEvent?,
      eventId: eventId ?? this.eventId,
    );
  }
}

final checkoutViewModelProvider =
    StateNotifierProvider<CheckoutViewModel, CheckoutState>((ref) {
      return CheckoutViewModel(ref);
    });

class CheckoutViewModel extends StateNotifier<CheckoutState> {
  CheckoutViewModel(
    this._ref, {
    PhoneNormalizer? phoneNormalizer,
    http.Client? httpClient,
    CheckoutAddressStore? addressStore,
    BuildCheckoutSummaryUseCase? buildCheckoutSummaryUseCase,
    ValidateCheckoutFormUseCase? validateCheckoutFormUseCase,
  }) : _phoneNormalizer = phoneNormalizer ?? PhoneNumberNormalizer(),
       _httpClient = httpClient ?? http.Client(),
       _addressStore = addressStore ?? _ref.read(checkoutAddressStoreProvider),
       _buildCheckoutSummaryUseCase =
           buildCheckoutSummaryUseCase ?? const BuildCheckoutSummaryUseCase(),
       _validateCheckoutFormUseCase =
           validateCheckoutFormUseCase ?? const ValidateCheckoutFormUseCase(),
       super(
         CheckoutState(
           placesAvailable:
               AppEnv.enablePlacesAutocomplete &&
               AppEnv.googlePlacesApiKey.isNotEmpty,
           placesConfigured: AppEnv.enablePlacesAutocomplete,
         ),
       ) {
    final initialCart = _ref.read(selectedCartItemsProvider);
    final initialAuth = _ref.read(authUserProvider);
    final initialUser = initialAuth.maybeWhen(
      data: (u) => u,
      orElse: () => null,
    );
    state = state.copyWith(
      hasSelectedItems: initialCart.isNotEmpty,
      isSignedIn: initialUser != null && !initialUser.isAnonymous,
    );

    unawaited(_recalculateSummary(cartItemsOverride: initialCart));

    _ref.listen<List<CartItem>>(selectedCartItemsProvider, (_, next) {
      state = state.copyWith(hasSelectedItems: next.isNotEmpty);
      _scheduleSummaryRebuild(cartItemsOverride: next, immediate: true);
    });
    _ref.listen(authUserProvider, (_, next) {
      final user = next.maybeWhen(data: (u) => u, orElse: () => null);
      state = state.copyWith(isSignedIn: user != null && !user.isAnonymous);
    });
  }

  final Ref _ref;
  final PhoneNormalizer _phoneNormalizer;
  final http.Client _httpClient;
  final CheckoutAddressStore _addressStore;
  final BuildCheckoutSummaryUseCase _buildCheckoutSummaryUseCase;
  final ValidateCheckoutFormUseCase _validateCheckoutFormUseCase;

  Timer? _autocompleteDebounce;
  Timer? _summaryRecalcDebounce;
  String? _placesSessionToken;
  int _autocompleteRequestId = 0;
  int _summaryRequestId = 0;
  bool _runPricingRulesInIsolate = false;

  int _requestId = 0;

  void _scheduleSummaryRebuild({
    List<CartItem>? cartItemsOverride,
    bool immediate = false,
  }) {
    _summaryRecalcDebounce?.cancel();
    if (immediate) {
      unawaited(_recalculateSummary(cartItemsOverride: cartItemsOverride));
      return;
    }

    _summaryRecalcDebounce = Timer(const Duration(milliseconds: 120), () {
      unawaited(_recalculateSummary(cartItemsOverride: cartItemsOverride));
    });
  }

  Future<Map<String, double>> _evaluatePricingRules({
    required List<CartItem> cartItems,
    required String address,
    required String city,
    required String stateRegion,
    required String postalCode,
    required String country,
  }) async {
    final subtotal = cartItems.fold<double>(
      0,
      (subtotalSoFar, item) => subtotalSoFar + item.total,
    );
    final payload = <String, Object?>{
      'subtotal': subtotal,
      'itemCount': cartItems.length,
      'address': address,
      'city': city,
      'state': stateRegion,
      'postalCode': postalCode,
      'country': country,
    };

    if (_runPricingRulesInIsolate) {
      return compute(_evaluateCheckoutPricingPayload, payload);
    }

    final watch = Stopwatch()..start();
    final result = _evaluateCheckoutPricingPayload(payload);
    watch.stop();
    if (watch.elapsed >= _checkoutPricingIsolateThreshold) {
      _runPricingRulesInIsolate = true;
    }
    return result;
  }

  Future<void> _recalculateSummary({List<CartItem>? cartItemsOverride}) async {
    final requestId = ++_summaryRequestId;
    final List<CartItem> currentItems =
        cartItemsOverride ?? _ref.read(selectedCartItemsProvider);
    final address = state.address.trim();
    final city = state.city.trim();
    final stateRegion = state.state.trim();
    final postalCode = state.postalCode.trim();
    final country = state.country.trim();

    state = state.copyWith(
      hasSelectedItems: currentItems.isNotEmpty,
      isRecalculatingSummary: true,
    );
    PerfMarkers.checkoutRecalcStart();
    try {
      final pricing = await _evaluatePricingRules(
        cartItems: currentItems,
        address: address,
        city: city,
        stateRegion: stateRegion,
        postalCode: postalCode,
        country: country,
      );
      if (requestId != _summaryRequestId) return;

      final shippingFee = pricing['shippingFee'] ?? 0;
      final taxAmount = pricing['taxAmount'] ?? 0;
      final discountAmount = pricing['discountAmount'] ?? 0;
      final summary = _buildCheckoutSummaryUseCase(
        currentItems,
        shippingFee: shippingFee,
        taxAmount: taxAmount,
        discountAmount: discountAmount,
      );
      state = state.copyWith(
        summary: summary,
        hasSelectedItems: summary.hasItems,
        isRecalculatingSummary: false,
      );
    } catch (_) {
      if (requestId != _summaryRequestId) return;
      state = state.copyWith(
        summary: _buildCheckoutSummaryUseCase(currentItems),
        hasSelectedItems: currentItems.isNotEmpty,
        isRecalculatingSummary: false,
      );
    } finally {
      PerfMarkers.checkoutRecalcEnd();
    }
  }

  Future<void> hydrateAddress() async {
    try {
      final saved = await _addressStore.loadAddress();
      if (saved == null) return;
      state = state.copyWith(
        fullName: saved['fullName'] ?? state.fullName,
        phone: saved['phone'] ?? state.phone,
        phoneRegionCode: saved['phoneRegionCode'] ?? state.phoneRegionCode,
        phoneDialCode: saved['phoneDialCode'] ?? state.phoneDialCode,
        address: saved['address'] ?? state.address,
        city: saved['city'] ?? state.city,
        state: saved['state'] ?? state.state,
        postalCode: saved['postalCode'] ?? state.postalCode,
        country: saved['country'] ?? state.country,
      );
      _scheduleSummaryRebuild(immediate: true);
    } catch (_) {}
  }

  Future<void> _persistAddress() async {
    try {
      await _addressStore.saveAddress({
        'fullName': state.fullName,
        'phone': state.phone,
        'phoneRegionCode': state.phoneRegionCode,
        'phoneDialCode': state.phoneDialCode,
        'address': state.address,
        'city': state.city,
        'state': state.state,
        'postalCode': state.postalCode,
        'country': state.country,
      });
    } catch (_) {}
  }

  void reset() {
    _requestId++;
    _autocompleteDebounce?.cancel();
    _summaryRecalcDebounce?.cancel();
    _placesSessionToken = null;
    state = CheckoutState(
      placesAvailable:
          AppEnv.enablePlacesAutocomplete &&
          AppEnv.googlePlacesApiKey.isNotEmpty,
      placesConfigured: AppEnv.enablePlacesAutocomplete,
      placesUnavailable: false,
      hasSelectedItems: state.hasSelectedItems,
      isSignedIn: state.isSignedIn,
      summary: state.summary,
    );
    _scheduleSummaryRebuild(immediate: true);
  }

  void setFullName(String v) {
    if (v == state.fullName) return;
    state = state.copyWith(fullName: v, fullNameError: null);
    _scheduleSummaryRebuild();
    unawaited(_persistAddress());
  }

  void setPhone(String v) {
    if (v == state.phone) return;
    state = state.copyWith(phone: v, phoneError: null);
    _scheduleSummaryRebuild();
    unawaited(_persistAddress());
  }

  void setPhoneRegionInfo({
    required String regionCode,
    required String dialCode,
  }) {
    if (regionCode == state.phoneRegionCode &&
        dialCode == state.phoneDialCode) {
      return;
    }
    state = state.copyWith(
      phoneRegionCode: regionCode,
      phoneDialCode: dialCode,
      phoneError: null,
    );
    _scheduleSummaryRebuild();
    unawaited(_persistAddress());
  }

  void setAddress(String v) {
    if (v == state.address) return;
    state = state.copyWith(address: v, addressError: null);
    _scheduleAutocomplete(v);
    _scheduleSummaryRebuild();
    unawaited(_persistAddress());
  }

  void setCity(String v) {
    if (v == state.city) return;
    state = state.copyWith(city: v, cityError: null);
    _scheduleSummaryRebuild();
    unawaited(_persistAddress());
  }

  void setStateRegion(String v) {
    if (v == state.state) return;
    state = state.copyWith(state: v, stateError: null);
    _scheduleSummaryRebuild();
    unawaited(_persistAddress());
  }

  void setPostalCode(String v) {
    if (v == state.postalCode) return;
    state = state.copyWith(postalCode: v, postalCodeError: null);
    _scheduleSummaryRebuild();
    unawaited(_persistAddress());
  }

  void setCountry(String v) {
    if (v == state.country) return;
    state = state.copyWith(country: v, countryError: null);
    _scheduleSummaryRebuild();
    unawaited(_persistAddress());
  }

  void markManualEntry() {
    state = state.copyWith(
      manualEntryOnly: true,
      addressSuggestions: const [],
      isFetchingSuggestions: false,
    );
  }

  Future<String?> normalizePhoneToE164({
    required String input,
    required String regionCode,
  }) async {
    return _phoneNormalizer.toE164(input: input, regionCode: regionCode);
  }

  void _scheduleAutocomplete(String query) {
    if (!state.placesAvailable || state.manualEntryOnly) {
      if (state.addressSuggestions.isNotEmpty || state.isFetchingSuggestions) {
        state = state.copyWith(
          addressSuggestions: const [],
          isFetchingSuggestions: false,
        );
      }
      return;
    }

    _autocompleteDebounce?.cancel();
    if (query.trim().length < 3) {
      _autocompleteRequestId++;
      state = state.copyWith(
        addressSuggestions: const [],
        isFetchingSuggestions: false,
      );
      return;
    }

    _autocompleteDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _fetchSuggestions(query.trim()),
    );
  }

  Future<void> _fetchSuggestions(String query) async {
    if (!state.placesAvailable || state.manualEntryOnly) return;

    final requestId = ++_autocompleteRequestId;
    _placesSessionToken ??= DateTime.now().millisecondsSinceEpoch.toString();
    final token = _placesSessionToken!;

    state = state.copyWith(isFetchingSuggestions: true);
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        {
          'input': query,
          'key': AppEnv.googlePlacesApiKey,
          'sessiontoken': token,
          'types': 'address',
        },
      );

      final response = await _httpClient.get(uri);
      if (requestId != _autocompleteRequestId) return;
      if (response.statusCode != 200) {
        _markAutocompleteFailed(requestId: requestId);
        return;
      }

      final parsed = await compute(_parseAutocompletePayload, response.body);
      final isOk = parsed['ok'] == true;
      if (!isOk) {
        _markAutocompleteFailed(requestId: requestId);
        return;
      }

      final rawSuggestions =
          parsed['suggestions'] as List<dynamic>? ?? const <dynamic>[];
      final suggestions = rawSuggestions
          .whereType<Map<String, String>>()
          .map(
            (raw) => PlaceSuggestion(
              placeId: raw['placeId'] ?? '',
              description: raw['description'] ?? '',
            ),
          )
          .toList(growable: false);

      if (requestId != _autocompleteRequestId) return;
      state = state.copyWith(
        addressSuggestions: suggestions,
        isFetchingSuggestions: false,
        placesUnavailable: false,
      );
    } catch (_) {
      _markAutocompleteFailed(requestId: requestId);
    }
  }

  void _markAutocompleteFailed({required int requestId}) {
    if (requestId != _autocompleteRequestId) return;
    state = state.copyWith(
      addressSuggestions: const [],
      isFetchingSuggestions: false,
      placesUnavailable: true,
    );
  }

  Future<void> selectSuggestion(PlaceSuggestion suggestion) async {
    if (!state.placesAvailable || suggestion.placeId.trim().isEmpty) return;
    final requestId = ++_autocompleteRequestId;
    final token =
        _placesSessionToken ?? DateTime.now().millisecondsSinceEpoch.toString();

    state = state.copyWith(isFetchingSuggestions: true);
    try {
      final uri =
          Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
            'place_id': suggestion.placeId,
            'key': AppEnv.googlePlacesApiKey,
            'sessiontoken': token,
            'fields': 'address_component,formatted_address',
          });

      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) {
        _markAutocompleteFailed(requestId: requestId);
        return;
      }

      final parsed = await compute(_parsePlaceDetailsPayload, response.body);
      final isOk = parsed['ok'] == true;
      if (!isOk) {
        _markAutocompleteFailed(requestId: requestId);
        return;
      }

      if (requestId != _autocompleteRequestId) return;
      state = state.copyWith(
        address: parsed['addressLine'] as String? ?? '',
        city: parsed['city'] as String? ?? '',
        state: parsed['state'] as String? ?? '',
        postalCode: parsed['postalCode'] as String? ?? '',
        country: parsed['country'] as String? ?? '',
        addressSuggestions: const [],
        isFetchingSuggestions: false,
        placesUnavailable: false,
      );
      _scheduleSummaryRebuild(immediate: true);
    } catch (_) {
      _markAutocompleteFailed(requestId: requestId);
    } finally {
      _placesSessionToken = null;
    }
  }

  ParsedAddress? _parseAddressComponents(List<dynamic> components) {
    final parsed = _extractAddressPartsFromComponents(components);
    if (parsed == null) return null;

    return ParsedAddress(
      addressLine: parsed['addressLine'] ?? '',
      city: parsed['city'] ?? '',
      state: parsed['state'] ?? '',
      postalCode: parsed['postalCode'] ?? '',
      country: parsed['country'] ?? '',
    );
  }

  @visibleForTesting
  ParsedAddress? parseAddressComponentsForTest(List<dynamic> components) {
    return _parseAddressComponents(components);
  }

  @override
  void dispose() {
    _autocompleteDebounce?.cancel();
    _summaryRecalcDebounce?.cancel();
    _httpClient.close();
    super.dispose();
  }

  Future<void> submit() async {
    PerfMarkers.checkoutSubmitStart();
    final requestId = ++_requestId;
    try {
      final summary = state.summary;
      final cart = summary.items;
      if (cart.isEmpty) {
        _emit(const CheckoutEvent.showSnack(key: CheckoutSnackKey.cartEmpty));
        return;
      }

      final user = _ref
          .read(authUserProvider)
          .maybeWhen(data: (u) => u, orElse: () => null);
      final uidFromProvider = _ref.read(currentUidProvider);
      final uid = uidFromProvider ?? user?.uid;

      if (!kReleaseMode) {
        debugPrint(
          'Checkout.submit auth uid=${uid ?? ''} isAnonymous=${user?.isAnonymous ?? true} email=${user?.email ?? ''}',
        );
      }

      final needsNonAnonymous = uidFromProvider == null;
      if (uid == null || uid.trim().isEmpty) {
        _emit(
          const CheckoutEvent.showSnack(key: CheckoutSnackKey.signInRequired),
        );
        _emit(const CheckoutEvent.goToSignIn());
        return;
      }
      if (needsNonAnonymous && (user == null || user.isAnonymous)) {
        _emit(
          const CheckoutEvent.showSnack(key: CheckoutSnackKey.signInRequired),
        );
        _emit(const CheckoutEvent.goToSignIn());
        return;
      }

      final fullName = state.fullName.trim();
      final phoneRaw = state.phone.trim();
      final address = state.address.trim();
      final city = state.city.trim();
      final stateRegion = state.state.trim();
      final postalCode = state.postalCode.trim();
      final country = state.country.trim();

      final validation = _validateCheckoutFormUseCase(
        CheckoutValidationInput(
          fullName: fullName,
          phone: phoneRaw,
          address: address,
          city: city,
          country: country,
        ),
      );

      if (validation.hasErrors) {
        state = state.copyWith(
          fullNameError: validation.fullNameMissing
              ? CheckoutFieldErrorKey.requiredField
              : null,
          phoneError: validation.phoneMissing
              ? CheckoutFieldErrorKey.requiredField
              : null,
          addressError: validation.addressMissing
              ? CheckoutFieldErrorKey.requiredField
              : null,
          cityError: validation.cityMissing
              ? CheckoutFieldErrorKey.requiredField
              : null,
          countryError: validation.countryMissing
              ? CheckoutFieldErrorKey.requiredField
              : null,
        );
        return;
      }

      final normalizedPhone = await normalizePhoneToE164(
        input: phoneRaw,
        regionCode: state.phoneRegionCode,
      );
      if (normalizedPhone == null) {
        state = state.copyWith(phoneError: CheckoutFieldErrorKey.invalidPhone);
        return;
      }

      state = state.copyWith(isSubmitting: true);
      try {
        final deviceId = await _ref
            .read(deviceIdDataSourceProvider)
            .getOrCreate();

        // Keep the server cart in sync before checkout (Cloud Function reads cart server-side).
        final allItems = _ref.read(cartItemsProvider);
        await _ref
            .read(cartRepositoryProvider)
            .saveCartLines(
              allItems
                  .map(
                    (i) => CartLine(
                      productId: i.product.id,
                      quantity: i.quantity,
                      selectedColor: i.selectedColor,
                      selectedSize: i.selectedSize,
                    ),
                  )
                  .toList(growable: false),
            );

        if (requestId != _requestId) return;

        _emit(
          CheckoutEvent.goToPayment(
            uid: uid,
            deviceId: deviceId,
            shipping: {
              'fullName': fullName,
              'phone': normalizedPhone,
              'address': address,
              'city': city,
              'state': stateRegion,
              'postalCode': postalCode,
              'country': country,
            },
          ),
        );
      } on CheckoutOutOfStockException catch (e) {
        if (requestId != _requestId) return;
        _emit(CheckoutEvent.showSnack(message: e.message));
      } on CheckoutCartEmptyException {
        if (requestId != _requestId) return;
        _emit(const CheckoutEvent.showSnack(key: CheckoutSnackKey.cartEmpty));
      } on CheckoutSignInRequiredException {
        if (requestId != _requestId) return;
        _emit(
          const CheckoutEvent.showSnack(key: CheckoutSnackKey.signInRequired),
        );
        _emit(const CheckoutEvent.goToSignIn());
      } on FirebaseException catch (e) {
        if (requestId != _requestId) return;

        if (!kReleaseMode) {
          debugPrint(
            'PLACE_ORDER failed: FirebaseException(code=${e.code}, message=${e.message})',
          );
        }

        _emit(
          CheckoutEvent.showSnack(
            key: kReleaseMode
                ? CheckoutSnackKey.somethingWentWrongTryAgain
                : null,
            message: kReleaseMode ? null : 'Checkout failed: ${e.code}',
          ),
        );
      } catch (e) {
        if (requestId != _requestId) return;
        if (!kReleaseMode) {
          debugPrint('PLACE_ORDER failed: $e');
        }
        _emit(
          CheckoutEvent.showSnack(
            key: kReleaseMode
                ? CheckoutSnackKey.somethingWentWrongTryAgain
                : null,
            message: kReleaseMode ? null : 'Checkout failed: ${e.runtimeType}',
          ),
        );
      } finally {
        if (requestId == _requestId) {
          state = state.copyWith(isSubmitting: false);
        }
      }
    } finally {
      PerfMarkers.checkoutSubmitEnd();
    }
  }

  void _emit(CheckoutEvent event) {
    state = state.copyWith(event: event, eventId: state.eventId + 1);
  }
}
