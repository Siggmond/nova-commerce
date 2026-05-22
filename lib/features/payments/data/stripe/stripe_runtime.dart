import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

import '../../../../app/config/app_env.dart';

class StripeRuntime {
  StripeRuntime._();

  static Future<void>? _inFlight;
  static bool _configured = false;

  static Future<void> ensureConfigured() {
    if (_configured || kIsWeb) {
      return Future<void>.value();
    }

    final active = _inFlight;
    if (active != null) {
      return active;
    }

    final future = _configure();
    _inFlight = future;
    return future;
  }

  static Future<void> _configure() async {
    final publishableKey = AppEnv.stripePublishableKey.trim();
    if (publishableKey.isEmpty) {
      _configured = false;
      _inFlight = null;
      return;
    }

    try {
      stripe.Stripe.publishableKey = publishableKey;
      await stripe.Stripe.instance.applySettings();
      _configured = true;
    } catch (e) {
      _configured = false;
      if (!kReleaseMode) {
        debugPrint('StripeRuntime ensureConfigured failed: $e');
      }
      rethrow;
    } finally {
      _inFlight = null;
    }
  }
}
