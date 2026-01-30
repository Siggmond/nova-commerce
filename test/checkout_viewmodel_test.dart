import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nova_commerce/core/config/auth_providers.dart';
import 'package:nova_commerce/core/config/providers.dart';
import 'package:nova_commerce/data/repositories/fake_auth_repository.dart';
import 'package:nova_commerce/data/repositories/fallback_auth_repository.dart';
import 'package:nova_commerce/data/datasources/device_id_datasource.dart';
import 'package:nova_commerce/domain/entities/cart_item.dart';
import 'package:nova_commerce/domain/entities/cart_line.dart';
import 'package:nova_commerce/domain/entities/auth_account_details.dart';
import 'package:nova_commerce/domain/entities/auth_user.dart';
import 'package:nova_commerce/domain/entities/product.dart';
import 'package:nova_commerce/domain/entities/variant.dart';
import 'package:nova_commerce/domain/repositories/auth_repository.dart';
import 'package:nova_commerce/domain/repositories/cart_repository.dart';
import 'package:nova_commerce/domain/repositories/order_repository.dart';
import 'package:nova_commerce/features/cart/presentation/cart_viewmodel.dart';
import 'package:nova_commerce/features/checkout/presentation/checkout_viewmodel.dart';

class _ClearCounter {
  int calls = 0;
}

class _InvalidApiKeyAuthRepository implements AuthRepository {
  @override
  Stream<AuthUser?> authStateChanges() => const Stream<AuthUser?>.empty();

  @override
  AuthUser? get currentUser => null;

  @override
  Future<AuthAccountDetails?> getAccountDetails() async => null;

  @override
  Future<AuthAccountDetails?> reloadAccountDetails() async => null;

  @override
  Future<void> updateDisplayName(String displayName) {
    throw const AuthException(
      message: 'API key not valid. Please pass a valid API key.',
      code: 'invalid-api-key',
    );
  }

  @override
  Future<void> sendEmailVerification() {
    throw const AuthException(
      message: 'API key not valid. Please pass a valid API key.',
      code: 'invalid-api-key',
    );
  }

  @override
  Future<PhoneVerificationSession> startPhoneVerification({
    required String phoneNumber,
  }) {
    throw const AuthException(
      message: 'API key not valid. Please pass a valid API key.',
      code: 'invalid-api-key',
    );
  }

  @override
  Future<void> linkPhoneWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) {
    throw const AuthException(
      message: 'API key not valid. Please pass a valid API key.',
      code: 'invalid-api-key',
    );
  }

  @override
  Future<AuthUser> createAccount({
    required String email,
    required String password,
  }) {
    throw const AuthException(
      message: 'API key not valid. Please pass a valid API key.',
      code: 'invalid-api-key',
    );
  }

  @override
  Future<AuthUser> signInEmail({
    required String email,
    required String password,
  }) {
    throw const AuthException(
      message: 'API key not valid. Please pass a valid API key.',
      code: 'invalid-api-key',
    );
  }

  @override
  Future<AuthUser> signInWithGoogle() {
    throw const AuthException(
      message: 'API key not valid. Please pass a valid API key.',
      code: 'invalid-api-key',
    );
  }

  @override
  Future<AuthUser> signInAnonymously() {
    throw const AuthException(
      message: 'API key not valid. Please pass a valid API key.',
      code: 'invalid-api-key',
    );
  }

  @override
  Future<void> signOut() async {}

  @override
  String? takeFallbackNotice() => null;
}

class _FakePhoneNormalizer implements PhoneNormalizer {
  _FakePhoneNormalizer({this.next});

  final String? next;

  @override
  Future<String?> toE164({
    required String input,
    required String regionCode,
  }) async {
    return next ?? '+12025550123';
  }
}

class _TestDeviceIdDataSource extends DeviceIdDataSource {
  @override
  Future<String> getOrCreate() async {
    return 'device_test';
  }
}

class _TestOrderRepository implements OrderRepository {
  int calls = 0;
  Map<String, String>? lastShipping;

  @override
  Future<String> placeOrder({
    required String uid,
    required String deviceId,
    required List<CartItem> items,
    required Map<String, String> shipping,
    required double subtotal,
    required double shippingFee,
    required double total,
    required String currency,
  }) async {
    calls++;
    lastShipping = shipping;
    return 'order_test_1';
  }
}

class _NoopCartRepository implements CartRepository {
  @override
  Future<List<CartLine>> loadCartLines() async {
    return const <CartLine>[];
  }

  @override
  Future<void> saveCartLines(List<CartLine> items) async {}
}

Product _p() {
  return const Product(
    id: 'p1',
    title: 'T',
    brand: 'B',
    price: 10,
    currency: 'USD',
    imageUrls: <String>[],
    description: 'd',
    variants: <Variant>[Variant(color: 'Black', size: 'M', stock: 1)],
  );
}

CartItem _item() {
  return CartItem(
    product: _p(),
    quantity: 2,
    selectedColor: 'Black',
    selectedSize: 'M',
  );
}

void main() {
  test('Lebanon phone normalization supports leading 0 local format', () async {
    final normalizer = PhoneNumberNormalizer();
    final normalized = await normalizer.toE164(
      input: '03 123456',
      regionCode: 'LB',
    );

    expect(normalized, '+9613123456');
  });

  test(
    'Lebanon phone normalization supports local format without leading 0',
    () async {
      final normalizer = PhoneNumberNormalizer();
      final normalized = await normalizer.toE164(
        input: '3 123456',
        regionCode: 'LB',
      );

      expect(normalized, '+9613123456');
    },
  );

  test(
    'Lebanon phone normalization supports international +961 input',
    () async {
      final normalizer = PhoneNumberNormalizer();
      final normalized = await normalizer.toE164(
        input: '+961 3 123456',
        regionCode: 'LB',
      );

      expect(normalized, '+9613123456');
    },
  );

  test('Phone normalization handles leading zero local formats', () async {
    final container = ProviderContainer(
      overrides: [
        checkoutViewModelProvider.overrideWith(
          (ref) => CheckoutViewModel(
            ref,
            phoneNormalizer: _FakePhoneNormalizer(next: '+442079460123'),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final vm = container.read(checkoutViewModelProvider.notifier);
    final normalized = await vm.normalizePhoneToE164(
      input: '020 7946 0123',
      regionCode: 'GB',
    );

    expect(normalized, '+442079460123');
  });

  test(
    'Fallback auth (invalid API key) still allows checkout without redirect',
    () async {
      final repo = _TestOrderRepository();

      final fallback = FakeAuthRepository();
      final authRepo = FallbackAuthRepository(
        primary: _InvalidApiKeyAuthRepository(),
        fallback: fallback,
      );

      final clearCounter = _ClearCounter();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
          checkoutViewModelProvider.overrideWith(
            (ref) => CheckoutViewModel(
              ref,
              phoneNormalizer: _FakePhoneNormalizer(next: '+12025550123'),
            ),
          ),
          deviceIdDataSourceProvider.overrideWithValue(
            _TestDeviceIdDataSource(),
          ),
          cartRepositoryProvider.overrideWithValue(_NoopCartRepository()),
          orderRepositoryProvider.overrideWithValue(repo),
          cartItemsProvider.overrideWithValue(<CartItem>[_item()]),
          cartClearProvider.overrideWithValue(() => clearCounter.calls++),
        ],
      );
      addTearDown(container.dispose);

      // This triggers fallback-to-demo. Historically, authUserProvider could stay null
      // because the stream came from primary and never switched.
      await authRepo.signInEmail(email: 'user@nova.dev', password: 'secret');

      // Force provider evaluation and ensure uid is available before submitting.
      final user = await container.read(authUserProvider.future);
      expect(user, isNotNull);
      expect(container.read(currentUidProvider), isNotNull);

      final vm = container.read(checkoutViewModelProvider.notifier);
      vm.setFullName('Nova User');
      vm.setPhone('2025550123');
      vm.setAddress('123 Main St');
      vm.setCity('Seattle');
      vm.setStateRegion('WA');
      vm.setPostalCode('98101');
      vm.setCountry('United States');

      await vm.submit();

      final state = container.read(checkoutViewModelProvider);
      expect(state.event, isNot(isA<CheckoutGoToSignIn>()));
      expect(repo.calls, 1);
      expect(state.event, isA<CheckoutGoToSuccess>());
    },
  );

  test('Signed-in user can place order without sign-in redirect', () async {
    final repo = _TestOrderRepository();
    final authRepo = FakeAuthRepository();
    final clearCounter = _ClearCounter();

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepo),
        checkoutViewModelProvider.overrideWith(
          (ref) => CheckoutViewModel(
            ref,
            phoneNormalizer: _FakePhoneNormalizer(next: '+12025550123'),
          ),
        ),
        deviceIdDataSourceProvider.overrideWithValue(_TestDeviceIdDataSource()),
        cartRepositoryProvider.overrideWithValue(_NoopCartRepository()),
        orderRepositoryProvider.overrideWithValue(repo),
        cartItemsProvider.overrideWithValue(<CartItem>[_item()]),
        cartClearProvider.overrideWithValue(() => clearCounter.calls++),
      ],
    );
    addTearDown(container.dispose);

    await authRepo.signInEmail(email: 'user@nova.dev', password: 'secret');
    final user = await container.read(authUserProvider.future);
    expect(user, isNotNull);
    expect(container.read(currentUidProvider), isNotNull);

    final vm = container.read(checkoutViewModelProvider.notifier);
    vm.setFullName('Nova User');
    vm.setPhone('2025550123');
    vm.setAddress('123 Main St');
    vm.setCity('Seattle');
    vm.setStateRegion('WA');
    vm.setPostalCode('98101');
    vm.setCountry('United States');

    await vm.submit();

    final state = container.read(checkoutViewModelProvider);
    expect(state.event, isNot(isA<CheckoutGoToSignIn>()));
    expect(repo.calls, 1);
    expect(state.event, isA<CheckoutGoToSuccess>());
  });

  test('Places mapping parses address components correctly', () async {
    final container = ProviderContainer(
      overrides: [
        checkoutViewModelProvider.overrideWith(
          (ref) =>
              CheckoutViewModel(ref, phoneNormalizer: _FakePhoneNormalizer()),
        ),
      ],
    );
    addTearDown(container.dispose);

    final vm = container.read(checkoutViewModelProvider.notifier);
    final parsed = vm.parseAddressComponentsForTest([
      {
        'long_name': '1600',
        'types': ['street_number'],
      },
      {
        'long_name': 'Amphitheatre Parkway',
        'types': ['route'],
      },
      {
        'long_name': 'Mountain View',
        'types': ['locality'],
      },
      {
        'long_name': 'CA',
        'types': ['administrative_area_level_1'],
      },
      {
        'long_name': '94043',
        'types': ['postal_code'],
      },
      {
        'long_name': 'United States',
        'types': ['country'],
      },
    ]);

    expect(parsed, isNotNull);
    expect(parsed!.addressLine, '1600 Amphitheatre Parkway');
    expect(parsed.city, 'Mountain View');
    expect(parsed.state, 'CA');
    expect(parsed.postalCode, '94043');
    expect(parsed.country, 'United States');
  });

  test('Manual entry path works when Places disabled', () async {
    final container = ProviderContainer(
      overrides: [
        checkoutViewModelProvider.overrideWith(
          (ref) =>
              CheckoutViewModel(ref, phoneNormalizer: _FakePhoneNormalizer()),
        ),
      ],
    );
    addTearDown(container.dispose);

    final vm = container.read(checkoutViewModelProvider.notifier);
    vm.setAddress('123 Main');

    final state = container.read(checkoutViewModelProvider);
    expect(state.placesAvailable, isFalse);
    expect(state.isFetchingSuggestions, isFalse);
    expect(state.addressSuggestions, isEmpty);
  });

  test('CheckoutViewModel emits snack when cart is empty', () async {
    final repo = _TestOrderRepository();

    final clearCounter = _ClearCounter();
    final container = ProviderContainer(
      overrides: [
        checkoutViewModelProvider.overrideWith(
          (ref) => CheckoutViewModel(
            ref,
            phoneNormalizer: _FakePhoneNormalizer(next: '+12025550123'),
          ),
        ),
        currentUidProvider.overrideWithValue('uid_1'),
        deviceIdDataSourceProvider.overrideWithValue(_TestDeviceIdDataSource()),
        cartRepositoryProvider.overrideWithValue(_NoopCartRepository()),
        orderRepositoryProvider.overrideWithValue(repo),
        cartItemsProvider.overrideWithValue(const <CartItem>[]),
        cartClearProvider.overrideWithValue(() => clearCounter.calls++),
      ],
    );
    addTearDown(container.dispose);

    final vm = container.read(checkoutViewModelProvider.notifier);
    await vm.submit();

    final state = container.read(checkoutViewModelProvider);
    expect(state.event, isA<CheckoutShowSnack>());
    expect((state.event as CheckoutShowSnack).message, 'Your cart is empty.');
    expect(state.isSubmitting, isFalse);
    expect(repo.calls, 0);
  });

  test('CheckoutViewModel emits sign-in event when uid is missing', () async {
    final repo = _TestOrderRepository();

    final clearCounter = _ClearCounter();
    final container = ProviderContainer(
      overrides: [
        currentUidProvider.overrideWithValue(null),
        deviceIdDataSourceProvider.overrideWithValue(_TestDeviceIdDataSource()),
        cartRepositoryProvider.overrideWithValue(_NoopCartRepository()),
        orderRepositoryProvider.overrideWithValue(repo),
        cartItemsProvider.overrideWithValue(<CartItem>[_item()]),
        cartClearProvider.overrideWithValue(() => clearCounter.calls++),
      ],
    );
    addTearDown(container.dispose);

    final vm = container.read(checkoutViewModelProvider.notifier);
    await vm.submit();

    final state = container.read(checkoutViewModelProvider);
    expect(state.eventId, 2);
    expect(state.event, isA<CheckoutGoToSignIn>());
    expect(state.isSubmitting, isFalse);
    expect(repo.calls, 0);
  });

  test('CheckoutViewModel validates required fields', () async {
    final repo = _TestOrderRepository();

    final clearCounter = _ClearCounter();
    final container = ProviderContainer(
      overrides: [
        checkoutViewModelProvider.overrideWith(
          (ref) => CheckoutViewModel(
            ref,
            phoneNormalizer: _FakePhoneNormalizer(next: '+12025550123'),
          ),
        ),
        currentUidProvider.overrideWithValue('uid_1'),
        deviceIdDataSourceProvider.overrideWithValue(_TestDeviceIdDataSource()),
        cartRepositoryProvider.overrideWithValue(_NoopCartRepository()),
        orderRepositoryProvider.overrideWithValue(repo),
        cartItemsProvider.overrideWithValue(<CartItem>[_item()]),
        cartClearProvider.overrideWithValue(() => clearCounter.calls++),
      ],
    );
    addTearDown(container.dispose);

    final vm = container.read(checkoutViewModelProvider.notifier);
    await vm.submit();

    final state = container.read(checkoutViewModelProvider);
    expect(state.fullNameError, isNotNull);
    expect(state.phoneError, isNotNull);
    expect(state.addressError, isNotNull);
    expect(state.cityError, isNotNull);
    expect(state.countryError, isNotNull);
    expect(state.eventId, 0);
    expect(repo.calls, 0);
  });

  test('CheckoutViewModel places order and clears cart', () async {
    final repo = _TestOrderRepository();

    final clearCounter = _ClearCounter();
    final container = ProviderContainer(
      overrides: [
        checkoutViewModelProvider.overrideWith(
          (ref) => CheckoutViewModel(
            ref,
            phoneNormalizer: _FakePhoneNormalizer(next: '+12025550123'),
          ),
        ),
        currentUidProvider.overrideWithValue('uid_1'),
        deviceIdDataSourceProvider.overrideWithValue(_TestDeviceIdDataSource()),
        cartRepositoryProvider.overrideWithValue(_NoopCartRepository()),
        orderRepositoryProvider.overrideWithValue(repo),
        cartItemsProvider.overrideWithValue(<CartItem>[_item()]),
        cartClearProvider.overrideWithValue(() => clearCounter.calls++),
      ],
    );
    addTearDown(container.dispose);

    final vm = container.read(checkoutViewModelProvider.notifier);
    vm.setFullName('A');
    vm.setPhone('1');
    vm.setAddress('X');
    vm.setCity('C');
    vm.setStateRegion('CA');
    vm.setPostalCode('94043');
    vm.setCountry('Y');

    await vm.submit();

    final state = container.read(checkoutViewModelProvider);
    expect(state.event, isA<CheckoutGoToSuccess>());
    expect((state.event as CheckoutGoToSuccess).orderId, 'order_test_1');
    expect(state.isSubmitting, isFalse);
    expect(repo.calls, 1);
    expect(repo.lastShipping?['phone'], '+12025550123');
    expect(clearCounter.calls, 1);
  });
}
