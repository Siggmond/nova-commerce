import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:nova_commerce/core/runtime/local_storage_runtime.dart';
import 'package:nova_commerce/features/payments/data/stripe/stripe_runtime.dart';

bool _deferredStartupScheduled = false;

void scheduleDeferredStartupServices() {
  if (_deferredStartupScheduled) return;
  _deferredStartupScheduled = true;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_runDeferredStartupServices());
  });
}

Future<void> _runDeferredStartupServices() async {
  unawaited(LocalStorageRuntime.prime().catchError((_) {}));

  if (!kIsWeb) {
    unawaited(StripeRuntime.ensureConfigured().catchError((_) {}));
  }
}
