import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_number/phone_number.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../../../core/config/app_env.dart';
import '../../../core/config/auth_providers.dart';
import '../../../core/config/providers.dart';
import '../../../core/errors/checkout_exceptions.dart';
import '../../../data/datasources/shared_prefs_checkout_address_datasource.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/cart_line.dart';
import '../domain/checkout_cart_summary.dart';
import '../../cart/presentation/cart_viewmodel.dart';

class PlaceSuggestion {
  const PlaceSuggestion({
    required this.placeId,
    required this.description,
  });

  final String placeId;
  final String description;
}

abstract class PhoneNormalizer {
  Future<String?> toE164({
    required String input,
    required String regionCode,
  });
}

class PhoneNumberNormalizer implements PhoneNormalizer {
  PhoneNumberNormalizer() : _util = PhoneNumberUtil();

  final PhoneNumberUtil _util;

  @override
  Future<String?> toE164({
    required String input,
    required String regionCode,
  }) async {
    if (input.trim().isEmpty) return null;

    final trimmed = input.trim();
    final normalized = trimmed.startsWith('+')
        ? trimmed.replaceAll(RegExp(r'[^\d\+]'), '')
        : trimmed.replaceAll(RegExp(r'[^\d]'), '');

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

      final ok = RegExp(r'^(3\d{6}|7\d{7})$').hasMatch(digits);
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

final checkoutCartSummaryProvider = Provider<CheckoutCartSummary>((ref) {
  final items = ref.watch(selectedCartItemsProvider);
  final currency = items.isNotEmpty ? items.first.product.currency : 'USD';
  final subtotal = items.fold<double>(0, (sum, i) => sum + i.total);
  const shippingFee = 0.0;
  final total = subtotal + shippingFee;

  return CheckoutCartSummary(
    currency: currency,
    subtotal: subtotal,
    shippingFee: shippingFee,
    total: total,
    hasItems: items.isNotEmpty,
    items: items,
  );
});

sealed class CheckoutEvent {
  const CheckoutEvent();

  const factory CheckoutEvent.showSnack(String message) = CheckoutShowSnack;
  const factory CheckoutEvent.goToSignIn() = CheckoutGoToSignIn;
  const factory CheckoutEvent.goToSuccess(String orderId) = CheckoutGoToSuccess;
}

class CheckoutShowSnack extends CheckoutEvent {
  const CheckoutShowSnack(this.message);

  final String message;
}

class CheckoutGoToSignIn extends CheckoutEvent {
  const CheckoutGoToSignIn();
}

class CheckoutGoToSuccess extends CheckoutEvent {
  const CheckoutGoToSuccess(this.orderId);

  final String orderId;
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

  final String? fullNameError;
  final String? phoneError;
  final String? addressError;
  final String? cityError;
  final String? stateError;
  final String? postalCodeError;
  final String? countryError;

  final bool isSubmitting;
  final bool hasSelectedItems;
  final bool isSignedIn;

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
    String? fullNameError,
    String? phoneError,
    String? addressError,
    String? cityError,
    String? stateError,
    String? postalCodeError,
    String? countryError,
    bool clearErrors = false,
    bool? isSubmitting,
    bool? hasSelectedItems,
    bool? isSignedIn,
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
      postalCodeError:
          clearErrors ? null : (postalCodeError ?? this.postalCodeError),
      countryError: clearErrors ? null : (countryError ?? this.countryError),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasSelectedItems: hasSelectedItems ?? this.hasSelectedItems,
      isSignedIn: isSignedIn ?? this.isSignedIn,
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
  })  : _phoneNormalizer = phoneNormalizer ?? PhoneNumberNormalizer(),
        _httpClient = httpClient ?? http.Client(),
        _addressStore = SharedPrefsCheckoutAddressDataSource(),
        super(
          CheckoutState(
            placesAvailable: AppEnv.enablePlacesAutocomplete &&
                AppEnv.googlePlacesApiKey.isNotEmpty,
            placesConfigured: AppEnv.enablePlacesAutocomplete,
          ),
        ) {
    _ref.listen<List<CartItem>>(selectedCartItemsProvider, (_, next) {
      state = state.copyWith(hasSelectedItems: next.isNotEmpty);
    });
    _ref.listen<String?>(currentUidProvider, (_, next) {
      state = state.copyWith(isSignedIn: next != null && next.trim().isNotEmpty);
    });
  }

  final Ref _ref;
  final PhoneNormalizer _phoneNormalizer;
  final http.Client _httpClient;
  final SharedPrefsCheckoutAddressDataSource _addressStore;

  Timer? _autocompleteDebounce;
  String? _placesSessionToken;
  int _autocompleteRequestId = 0;

  int _requestId = 0;

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
    _placesSessionToken = null;
    state = CheckoutState(
      placesAvailable: AppEnv.enablePlacesAutocomplete &&
          AppEnv.googlePlacesApiKey.isNotEmpty,
      placesConfigured: AppEnv.enablePlacesAutocomplete,
      placesUnavailable: false,
    );
  }

  void setFullName(String v) {
    state = state.copyWith(fullName: v, fullNameError: null);
    unawaited(_persistAddress());
  }

  void setPhone(String v) {
    state = state.copyWith(phone: v, phoneError: null);
    unawaited(_persistAddress());
  }

  void setPhoneRegionInfo({
    required String regionCode,
    required String dialCode,
  }) {
    state = state.copyWith(
      phoneRegionCode: regionCode,
      phoneDialCode: dialCode,
      phoneError: null,
    );
    unawaited(_persistAddress());
  }

  void setAddress(String v) {
    state = state.copyWith(address: v, addressError: null);
    _scheduleAutocomplete(v);
    unawaited(_persistAddress());
  }

  void setCity(String v) {
    state = state.copyWith(city: v, cityError: null);
    unawaited(_persistAddress());
  }

  void setStateRegion(String v) {
    state = state.copyWith(state: v, stateError: null);
    unawaited(_persistAddress());
  }

  void setPostalCode(String v) {
    state = state.copyWith(postalCode: v, postalCodeError: null);
    unawaited(_persistAddress());
  }

  void setCountry(String v) {
    state = state.copyWith(country: v, countryError: null);
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
    return _phoneNormalizer.toE164(
      input: input,
      regionCode: regionCode,
    );
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

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String?;
      if (status != 'OK' && status != 'ZERO_RESULTS') {
        _markAutocompleteFailed(requestId: requestId);
        return;
      }

      final predictions = data['predictions'] as List<dynamic>? ?? const [];
      final suggestions = predictions
          .whereType<Map<String, dynamic>>()
          .map(
            (p) => PlaceSuggestion(
              placeId: (p['place_id'] as String?) ?? '',
              description: (p['description'] as String?) ?? '',
            ),
          )
          .where((s) => s.placeId.isNotEmpty && s.description.isNotEmpty)
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
    final token = _placesSessionToken ??
        DateTime.now().millisecondsSinceEpoch.toString();

    state = state.copyWith(isFetchingSuggestions: true);
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/details/json',
        {
          'place_id': suggestion.placeId,
          'key': AppEnv.googlePlacesApiKey,
          'sessiontoken': token,
          'fields': 'address_component,formatted_address',
        },
      );

      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) {
        _markAutocompleteFailed(requestId: requestId);
        return;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String?;
      if (status != 'OK') {
        _markAutocompleteFailed(requestId: requestId);
        return;
      }

      final result = data['result'] as Map<String, dynamic>? ?? const {};
      final components =
          result['address_components'] as List<dynamic>? ?? const [];
      final parsed = _parseAddressComponents(components);
      if (parsed == null) {
        _markAutocompleteFailed(requestId: requestId);
        return;
      }

      if (requestId != _autocompleteRequestId) return;
      state = state.copyWith(
        address: parsed.addressLine,
        city: parsed.city,
        state: parsed.state,
        postalCode: parsed.postalCode,
        country: parsed.country,
        addressSuggestions: const [],
        isFetchingSuggestions: false,
        placesUnavailable: false,
      );
    } catch (_) {
      _markAutocompleteFailed(requestId: requestId);
    } finally {
      _placesSessionToken = null;
    }
  }

  ParsedAddress? _parseAddressComponents(List<dynamic> components) {
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
          .toList();
      final longName = (raw['long_name'] as String?) ?? '';

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

    final streetLine = [streetNumber, route]
        .where((e) => e.trim().isNotEmpty)
        .join(' ')
        .trim();
    if (streetLine.isEmpty && locality.isEmpty && country.isEmpty) {
      return null;
    }

    return ParsedAddress(
      addressLine: streetLine,
      city: locality,
      state: adminArea,
      postalCode: postalCode,
      country: country,
    );
  }

  @visibleForTesting
  ParsedAddress? parseAddressComponentsForTest(List<dynamic> components) {
    return _parseAddressComponents(components);
  }

  @override
  void dispose() {
    _autocompleteDebounce?.cancel();
    _httpClient.close();
    super.dispose();
  }

  Future<void> submit() async {
    final requestId = ++_requestId;

    final cart = _ref.read(selectedCartItemsProvider);
    if (cart.isEmpty) {
      _emit(const CheckoutEvent.showSnack('Your cart is empty.'));
      return;
    }

    final uid = _ref.read(currentUidProvider);
    if (uid == null || uid.trim().isEmpty) {
      _emit(const CheckoutEvent.showSnack('Please sign in to continue.'));
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

    final fullNameError = fullName.isEmpty ? 'Required' : null;
    final phoneError = phoneRaw.isEmpty ? 'Required' : null;
    final addressError = address.isEmpty ? 'Required' : null;
    final cityError = city.isEmpty ? 'Required' : null;
    final countryError = country.isEmpty ? 'Required' : null;

    final hasErrors =
        fullNameError != null ||
        phoneError != null ||
        addressError != null ||
        cityError != null ||
        countryError != null;

    if (hasErrors) {
      state = state.copyWith(
        fullNameError: fullNameError,
        phoneError: phoneError,
        addressError: addressError,
        cityError: cityError,
        countryError: countryError,
      );
      return;
    }

    final normalizedPhone = await normalizePhoneToE164(
      input: phoneRaw,
      regionCode: state.phoneRegionCode,
    );
    if (normalizedPhone == null) {
      state = state.copyWith(phoneError: 'Invalid phone number');
      return;
    }

    state = state.copyWith(isSubmitting: true);
    try {
      final summary = _ref.read(checkoutCartSummaryProvider);
      final deviceId = await _ref.read(deviceIdDataSourceProvider).getOrCreate();

      // Keep the server cart in sync before checkout (Cloud Function reads cart server-side).
      final allItems = _ref.read(cartItemsProvider);
      await _ref.read(cartRepositoryProvider).saveCartLines(
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

      final repo = _ref.read(orderRepositoryProvider);
      final orderId = await repo.placeOrder(
        uid: uid,
        deviceId: deviceId,
        items: cart,
        shipping: {
          'fullName': fullName,
          'phone': normalizedPhone,
          'address': address,
          'city': city,
          'state': stateRegion,
          'postalCode': postalCode,
          'country': country,
        },
        subtotal: summary.subtotal,
        shippingFee: summary.shippingFee,
        total: summary.total,
        currency: summary.currency,
      );

      if (requestId != _requestId) return;

      final selectedIds = _ref.read(selectedCartItemIdsProvider);
      final cartItems = _ref.read(cartItemsProvider);
      final allIds = cartItems.map((i) => i.product.id).toSet();
      if (selectedIds.isEmpty || (allIds.isNotEmpty && selectedIds.length == allIds.length)) {
        _ref.read(cartClearProvider).call();
      } else {
        _ref
            .read(cartViewModelProvider.notifier)
            .removeByProductIds(selectedIds);
      }
      _ref.read(selectedCartItemIdsProvider.notifier).selectAll(const []);
      _emit(CheckoutEvent.goToSuccess(orderId));
    } on CheckoutOutOfStockException catch (e) {
      if (requestId != _requestId) return;
      _emit(CheckoutEvent.showSnack(e.message));
    } on CheckoutCartEmptyException {
      if (requestId != _requestId) return;
      _emit(const CheckoutEvent.showSnack('Your cart is empty.'));
    } on CheckoutSignInRequiredException {
      if (requestId != _requestId) return;
      _emit(const CheckoutEvent.showSnack('Please sign in to continue.'));
      _emit(const CheckoutEvent.goToSignIn());
    } catch (e) {
      if (requestId != _requestId) return;
      _emit(const CheckoutEvent.showSnack(
        'Something went wrong. Please try again.',
      ));
    } finally {
      if (requestId == _requestId) {
        state = state.copyWith(isSubmitting: false);
      }
    }
  }

  void _emit(CheckoutEvent event) {
    state = state.copyWith(event: event, eventId: state.eventId + 1);
  }
}
