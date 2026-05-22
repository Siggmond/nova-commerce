import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../config/perf_flags.dart';

class PerfLogger {
  static bool _installed = false;
  static int _lastJankLogMs = 0;
  static int _lastSummaryLogMs = 0;
  static int _framesSinceSummary = 0;
  static int _jankySinceSummary = 0;
  static double _worstTotalMsSinceSummary = 0;

  static const bool _verboseFrames = bool.fromEnvironment(
    'PERF_VERBOSE_FRAMES',
    defaultValue: false,
  );
  static const int _jankLogCooldownMs = 900;
  static const int _summaryEveryMs = 3000;
  static const double _jankThresholdMs = 16.7;
  static const double _severeJankThresholdMs = 42.0;

  static void install() {
    if (_installed) return;
    if (!PerfFlags.isActive) return;

    _installed = true;

    SchedulerBinding.instance.addTimingsCallback((timings) {
      for (final t in timings) {
        final buildMs = t.buildDuration.inMicroseconds / 1000.0;
        final rasterMs = t.rasterDuration.inMicroseconds / 1000.0;
        final totalMs = buildMs + rasterMs;
        final now = DateTime.now().millisecondsSinceEpoch;

        _framesSinceSummary += 1;
        if (totalMs > _jankThresholdMs) {
          _jankySinceSummary += 1;
        }
        if (totalMs > _worstTotalMsSinceSummary) {
          _worstTotalMsSinceSummary = totalMs;
        }

        if (_verboseFrames) {
          debugPrint(
            'PERF frame: build=${buildMs.toStringAsFixed(1)}ms raster=${rasterMs.toStringAsFixed(1)}ms',
          );
        } else if (totalMs >= _severeJankThresholdMs &&
            now - _lastJankLogMs >= _jankLogCooldownMs) {
          _lastJankLogMs = now;
          debugPrint(
            'PERF severe-jank: build=${buildMs.toStringAsFixed(1)}ms raster=${rasterMs.toStringAsFixed(1)}ms total=${totalMs.toStringAsFixed(1)}ms',
          );
        }

        if (now - _lastSummaryLogMs >= _summaryEveryMs &&
            _framesSinceSummary > 0) {
          final jankRatio = _jankySinceSummary / _framesSinceSummary;
          debugPrint(
            'PERF summary: frames=$_framesSinceSummary jankRatio=${jankRatio.toStringAsFixed(2)} worst=${_worstTotalMsSinceSummary.toStringAsFixed(1)}ms',
          );
          _lastSummaryLogMs = now;
          _framesSinceSummary = 0;
          _jankySinceSummary = 0;
          _worstTotalMsSinceSummary = 0;
        }
      }
    });

    debugPrint('PERF enabled (dart-define PERF=true).');
  }
}
