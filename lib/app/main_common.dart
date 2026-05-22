import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nova_commerce/app/di/app_providers.dart';
import 'package:nova_commerce/app/perf/perf_logger.dart';
import '../core/telemetry/telemetry.dart';
import 'app.dart';
import 'startup/deferred_startup_services.dart';

void mainCommon(Telemetry telemetry) {
  PerfLogger.install();
  runApp(
    ProviderScope(
      overrides: [telemetryProvider.overrideWithValue(telemetry)],
      child: const NovaCommerceApp(),
    ),
  );
  scheduleDeferredStartupServices();
}
