import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

bool _authFeatureInitialized = false;
bool _checkoutFeatureInitialized = false;
bool _cartFeatureInitialized = false;
bool _productsFeatureInitialized = false;
const Duration _authInitTimeout = Duration(seconds: 4);

void initAuthFeatureOnce() {
  if (_authFeatureInitialized) return;
  _authFeatureInitialized = true;
  unawaited(_ensureAnonymousAuthSession());
}

void initCheckoutFeatureOnce() {
  if (_checkoutFeatureInitialized) return;
  _checkoutFeatureInitialized = true;
}

void initCartFeatureOnce() {
  if (_cartFeatureInitialized) return;
  _cartFeatureInitialized = true;
}

void initProductsFeatureOnce() {
  if (_productsFeatureInitialized) return;
  _productsFeatureInitialized = true;
}

bool get isCartFeatureInitialized => _cartFeatureInitialized;

Future<void> _ensureAnonymousAuthSession() async {
  if (Firebase.apps.isEmpty) return;
  try {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) return;
    await auth.signInAnonymously().timeout(_authInitTimeout);
  } on TimeoutException {
    _debugLog(
      'Auth init timed out after ${_authInitTimeout.inSeconds}s; continuing.',
    );
  } catch (error) {
    _debugLog('Auth init skipped; continuing without auth: $error');
  }
}

void _debugLog(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}
