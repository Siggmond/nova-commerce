import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'memory_sample.dart';

class PerfMarkers {
  PerfMarkers._();

  static final Stopwatch _clock = Stopwatch()..start();
  static final Set<String> _onceMarkers = <String>{};
  static final Map<String, int> _markerTimesUs = <String, int>{};
  static final Map<String, double?> _memorySamplesMb = <String, double?>{};
  static final Map<String, String> _memorySampleNotes = <String, String>{};

  static bool _timingsInstalled = false;
  static bool _productsScrollActive = false;
  static int? _productsScrollStartUs;

  static bool _deterministicTestMode = false;
  static bool _reportPrintedThisRun = false;
  static String? _lastReportLine;
  static double? _lastMemorySampleMb;
  static String _lastMemorySampleSource = 'unavailable';

  static int _currentProductsScrollFrames = 0;
  static int _currentProductsScrollJankyFrames = 0;
  static double _currentProductsScrollWorstFrameMs = 0;

  static int? _lastProductsScrollDurationMs;
  static int _lastProductsScrollFrames = 0;
  static int _lastProductsScrollJankyFrames = 0;
  static double _lastProductsScrollWorstFrameMs = 0;

  static bool get _enabled => kProfileMode;

  static void appStart() => _markOnce('appStart');

  static void firstFrame() => _markOnce('firstFrame');

  static void firstProductsFrame() {
    _markOnce('firstProductsFrame');
    _maybePrintDebugReport(trigger: 'first_products_frame');
  }

  /// Resets all in-memory perf state for deterministic integration test runs.
  static void resetForTest() {
    _deterministicTestMode = true;
    _reportPrintedThisRun = false;
    _lastReportLine = null;
    _lastMemorySampleMb = null;
    _lastMemorySampleSource = 'unavailable';

    _onceMarkers.clear();
    _markerTimesUs.clear();
    _memorySamplesMb.clear();
    _memorySampleNotes.clear();

    _productsScrollActive = false;
    _productsScrollStartUs = null;
    _currentProductsScrollFrames = 0;
    _currentProductsScrollJankyFrames = 0;
    _currentProductsScrollWorstFrameMs = 0;
    _lastProductsScrollDurationMs = null;
    _lastProductsScrollFrames = 0;
    _lastProductsScrollJankyFrames = 0;
    _lastProductsScrollWorstFrameMs = 0;

    _clock
      ..reset()
      ..start();

    if (_timingsInstalled) {
      SchedulerBinding.instance.removeTimingsCallback(_handleFrameTimings);
      _timingsInstalled = false;
    }
  }

  static void productsScrollStart() {
    if (!_enabled) return;
    _productsScrollActive = true;
    _productsScrollStartUs = _clock.elapsedMicroseconds;
    _currentProductsScrollFrames = 0;
    _currentProductsScrollJankyFrames = 0;
    _currentProductsScrollWorstFrameMs = 0;
    _mark('productsScrollStart');
  }

  static void productsScrollEnd() {
    if (!_enabled) return;
    _mark('productsScrollEnd');
    if (!_productsScrollActive) return;

    _productsScrollActive = false;
    final startUs = _productsScrollStartUs;
    _productsScrollStartUs = null;

    if (startUs != null) {
      _lastProductsScrollDurationMs =
          ((_clock.elapsedMicroseconds - startUs) / 1000).round();
    }
    _lastProductsScrollFrames = _currentProductsScrollFrames;
    _lastProductsScrollJankyFrames = _currentProductsScrollJankyFrames;
    _lastProductsScrollWorstFrameMs = _currentProductsScrollWorstFrameMs;

    _maybePrintDebugReport(trigger: 'products_scroll_end');
  }

  static Future<void> memorySample(String label) async {
    if (!_enabled) return;
    final normalizedLabel = label.trim();
    if (normalizedLabel.isEmpty) return;

    final snapshot = await samplePerfMemory(normalizedLabel);
    _lastMemorySampleSource = snapshot.source;

    final mb = snapshot.megabytes == null ? null : _round(snapshot.megabytes!);
    _memorySamplesMb[normalizedLabel] = mb;
    _lastMemorySampleMb = mb ?? _lastMemorySampleMb;

    final note = (snapshot.note ?? '').trim();
    if (note.isNotEmpty) {
      _memorySampleNotes[normalizedLabel] = note;
    }

    _mark('memory_${_sanitizeMarkerName(normalizedLabel)}');
  }

  static void cartOpen() => _mark('cartOpen');

  static void checkoutOpen() => _mark('checkoutOpen');

  static void checkoutRecalcStart() => _mark('checkoutRecalcStart');

  static void checkoutRecalcEnd() => _mark('checkoutRecalcEnd');

  static void checkoutSubmitStart() => _mark('checkoutSubmitStart');

  static void checkoutSubmitEnd() => _mark('checkoutSubmitEnd');

  static void cartUpdateStart() => _mark('cartUpdateStart');

  static void cartUpdateEnd() => _mark('cartUpdateEnd');

  static String report({String? trigger}) {
    final payload = <String, Object?>{
      'type': 'perf_report',
      if (trigger != null) 'trigger': trigger,
      'ttff_ms': _durationMs('appStart', 'firstFrame'),
      'first_products_frame_ms': _durationMs('appStart', 'firstProductsFrame'),
      'products_scroll_jank_count': _lastProductsScrollJankyFrames,
      'products_scroll_duration_ms': _lastProductsScrollDurationMs,
      'products_scroll_frame_count': _lastProductsScrollFrames,
      'products_scroll_worst_frame_ms': _roundMs(
        _lastProductsScrollWorstFrameMs,
      ),
      'checkout_open_ms': _durationMs('appStart', 'checkoutOpen'),
      'checkout_recalc_ms': _durationMs(
        'checkoutRecalcStart',
        'checkoutRecalcEnd',
      ),
      'checkout_submit_ms': _durationMs(
        'checkoutSubmitStart',
        'checkoutSubmitEnd',
      ),
      'memory_mb': _lastMemorySampleMb,
      'memory_sample_source': _lastMemorySampleSource,
      'memory_samples_mb': _memorySamplesMb,
      if (_memorySampleNotes.isNotEmpty)
        'memory_sample_notes': _memorySampleNotes,
    };
    final line = jsonEncode(payload);
    if (_deterministicTestMode) {
      if (_reportPrintedThisRun) {
        return _lastReportLine ?? line;
      }
      _reportPrintedThisRun = true;
      _lastReportLine = line;
      debugPrint(line);
      return line;
    }

    debugPrint(line);
    return line;
  }

  static bool hasMarker(String name) => _markerTimesUs.containsKey(name);

  static void _markOnce(String name) {
    if (!_enabled) return;
    if (!_onceMarkers.add(name)) return;
    _mark(name);
  }

  static void _mark(String name) {
    if (!_enabled) return;
    _ensureFrameTimingsCallback();
    _markerTimesUs[name] = _clock.elapsedMicroseconds;
    developer.Timeline.instantSync('nova.$name');
  }

  static int? _durationMs(String startMarker, String endMarker) {
    final startUs = _markerTimesUs[startMarker];
    final endUs = _markerTimesUs[endMarker];
    if (startUs == null || endUs == null || endUs < startUs) {
      return null;
    }
    return ((endUs - startUs) / 1000).round();
  }

  static double _roundMs(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  static double _round(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  static void _ensureFrameTimingsCallback() {
    if (_timingsInstalled) return;
    _timingsInstalled = true;
    SchedulerBinding.instance.addTimingsCallback(_handleFrameTimings);
  }

  static void _handleFrameTimings(List<FrameTiming> timings) {
    if (!_productsScrollActive) return;
    for (final timing in timings) {
      final frameMs =
          (timing.buildDuration.inMicroseconds +
              timing.rasterDuration.inMicroseconds) /
          1000.0;
      _currentProductsScrollFrames += 1;
      if (frameMs > 16) {
        _currentProductsScrollJankyFrames += 1;
      }
      if (frameMs > _currentProductsScrollWorstFrameMs) {
        _currentProductsScrollWorstFrameMs = frameMs;
      }
    }
  }

  static void _maybePrintDebugReport({required String trigger}) {
    if (_deterministicTestMode) return;
    if (!_enabled || kReleaseMode) return;
    report(trigger: trigger);
  }

  static String _sanitizeMarkerName(String value) {
    final sanitized = value.replaceAll(RegExp(r'[^a-zA-Z0-9_]+'), '_');
    return sanitized.isEmpty ? 'sample' : sanitized;
  }
}
