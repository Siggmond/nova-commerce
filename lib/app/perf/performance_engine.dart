import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/cart/domain/state/cart_state.dart';
import '../../features/home/presentation/home_viewmodel.dart';
import '../../features/offers/presentation/offers_viewmodel.dart';
import '../../features/search/presentation/search_viewmodel.dart';
import 'performance_runtime_hints.dart';

enum PerformancePressureLevel { normal, elevated, critical }

class PerformanceEngineState {
  const PerformanceEngineState({
    required this.pressureLevel,
    required this.highPressure,
    required this.navigationPressure,
    required this.jankRatio,
    required this.buildP95Ms,
    required this.rasterP95Ms,
    required this.currentRoute,
    required this.homePrecacheImageCount,
    required this.homeScrollCacheExtent,
    required this.homeLoadMoreThrottleMs,
    required this.homeLoadMoreTriggerExtent,
    required this.tabSwitchThrottleMs,
    required this.allowDecorativeMotion,
    required this.homeHeroItemsMax,
    required this.homeTrendingItemsMax,
    required this.homePickedItemsMax,
    required this.hideNonEssentialHomeSections,
    required this.routeTransitionsEnabled,
    required this.imageDecodeMaxDimension,
    required this.imageDecodeScalePercent,
    required this.imageFadeInMs,
    required this.backgroundWarmupsEnabled,
    required this.maxWarmupsPerMinute,
  });

  const PerformanceEngineState.initial()
    : pressureLevel = PerformancePressureLevel.normal,
      highPressure = false,
      navigationPressure = false,
      jankRatio = 0,
      buildP95Ms = 0,
      rasterP95Ms = 0,
      currentRoute = '/',
      homePrecacheImageCount = 10,
      homeScrollCacheExtent = 1320,
      homeLoadMoreThrottleMs = 320,
      homeLoadMoreTriggerExtent = 980,
      tabSwitchThrottleMs = 48,
      allowDecorativeMotion = true,
      homeHeroItemsMax = 5,
      homeTrendingItemsMax = 10,
      homePickedItemsMax = 10,
      hideNonEssentialHomeSections = false,
      routeTransitionsEnabled = true,
      imageDecodeMaxDimension = 1600,
      imageDecodeScalePercent = 100,
      imageFadeInMs = 120,
      backgroundWarmupsEnabled = true,
      maxWarmupsPerMinute = 12;

  final PerformancePressureLevel pressureLevel;
  final bool highPressure;
  final bool navigationPressure;
  final double jankRatio;
  final double buildP95Ms;
  final double rasterP95Ms;
  final String currentRoute;

  final int homePrecacheImageCount;
  final double homeScrollCacheExtent;
  final int homeLoadMoreThrottleMs;
  final double homeLoadMoreTriggerExtent;
  final int tabSwitchThrottleMs;
  final bool allowDecorativeMotion;
  final int homeHeroItemsMax;
  final int homeTrendingItemsMax;
  final int homePickedItemsMax;
  final bool hideNonEssentialHomeSections;
  final bool routeTransitionsEnabled;
  final int imageDecodeMaxDimension;
  final int imageDecodeScalePercent;
  final int imageFadeInMs;
  final bool backgroundWarmupsEnabled;
  final int maxWarmupsPerMinute;

  PerformanceEngineState copyWith({
    PerformancePressureLevel? pressureLevel,
    bool? highPressure,
    bool? navigationPressure,
    double? jankRatio,
    double? buildP95Ms,
    double? rasterP95Ms,
    String? currentRoute,
    int? homePrecacheImageCount,
    double? homeScrollCacheExtent,
    int? homeLoadMoreThrottleMs,
    double? homeLoadMoreTriggerExtent,
    int? tabSwitchThrottleMs,
    bool? allowDecorativeMotion,
    int? homeHeroItemsMax,
    int? homeTrendingItemsMax,
    int? homePickedItemsMax,
    bool? hideNonEssentialHomeSections,
    bool? routeTransitionsEnabled,
    int? imageDecodeMaxDimension,
    int? imageDecodeScalePercent,
    int? imageFadeInMs,
    bool? backgroundWarmupsEnabled,
    int? maxWarmupsPerMinute,
  }) {
    return PerformanceEngineState(
      pressureLevel: pressureLevel ?? this.pressureLevel,
      highPressure: highPressure ?? this.highPressure,
      navigationPressure: navigationPressure ?? this.navigationPressure,
      jankRatio: jankRatio ?? this.jankRatio,
      buildP95Ms: buildP95Ms ?? this.buildP95Ms,
      rasterP95Ms: rasterP95Ms ?? this.rasterP95Ms,
      currentRoute: currentRoute ?? this.currentRoute,
      homePrecacheImageCount:
          homePrecacheImageCount ?? this.homePrecacheImageCount,
      homeScrollCacheExtent:
          homeScrollCacheExtent ?? this.homeScrollCacheExtent,
      homeLoadMoreThrottleMs:
          homeLoadMoreThrottleMs ?? this.homeLoadMoreThrottleMs,
      homeLoadMoreTriggerExtent:
          homeLoadMoreTriggerExtent ?? this.homeLoadMoreTriggerExtent,
      tabSwitchThrottleMs: tabSwitchThrottleMs ?? this.tabSwitchThrottleMs,
      allowDecorativeMotion:
          allowDecorativeMotion ?? this.allowDecorativeMotion,
      homeHeroItemsMax: homeHeroItemsMax ?? this.homeHeroItemsMax,
      homeTrendingItemsMax: homeTrendingItemsMax ?? this.homeTrendingItemsMax,
      homePickedItemsMax: homePickedItemsMax ?? this.homePickedItemsMax,
      hideNonEssentialHomeSections:
          hideNonEssentialHomeSections ?? this.hideNonEssentialHomeSections,
      routeTransitionsEnabled:
          routeTransitionsEnabled ?? this.routeTransitionsEnabled,
      imageDecodeMaxDimension:
          imageDecodeMaxDimension ?? this.imageDecodeMaxDimension,
      imageDecodeScalePercent:
          imageDecodeScalePercent ?? this.imageDecodeScalePercent,
      imageFadeInMs: imageFadeInMs ?? this.imageFadeInMs,
      backgroundWarmupsEnabled:
          backgroundWarmupsEnabled ?? this.backgroundWarmupsEnabled,
      maxWarmupsPerMinute: maxWarmupsPerMinute ?? this.maxWarmupsPerMinute,
    );
  }
}

final performanceEngineProvider =
    StateNotifierProvider<PerformanceEngineController, PerformanceEngineState>((
      ref,
    ) {
      return PerformanceEngineController(ref);
    });

class PerformanceEngineController extends StateNotifier<PerformanceEngineState>
    with WidgetsBindingObserver {
  PerformanceEngineController(this._ref)
    : super(const PerformanceEngineState.initial()) {
    WidgetsBinding.instance.addObserver(this);
    _configureImageCache(level: _appliedPressureLevel);
    _applyRuntimeHints(_profileForLevel(_appliedPressureLevel));
    _installFrameTimingListener();
    if (_enableStartupWarmups) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_disposed) return;
        _warmScope('home', () => _ref.read(homeViewModelProvider.notifier));
      });
    }
  }

  static const int _frameWindowSize = 120;
  static const int _navigationWindowMs = 18000;
  static const int _navigationPressureSwitches = 8;
  static const int _warmupWindowMs = 60000;
  static const int _churnCacheShedCooldownMs = 4500;
  static const int _pressureHoldMs = 14000;
  static const int _criticalHoldMs = 24000;
  static const int _metricsUpdateIntervalMs = 420;
  static const bool _enableStartupWarmups = bool.fromEnvironment(
    'ENABLE_STARTUP_WARMUPS',
    defaultValue: false,
  );

  static const double _elevatedJankRatio = 0.07;
  static const double _criticalJankRatio = 0.14;
  static const double _elevatedP95Ms = 10.5;
  static const double _criticalP95Ms = 15.5;

  final Ref _ref;
  final List<double> _buildMsWindow = <double>[];
  final List<double> _rasterMsWindow = <double>[];
  final List<int> _jankWindow = <int>[];
  final Queue<int> _routeSwitchesMs = Queue<int>();
  final Queue<int> _warmupStartedMs = Queue<int>();
  final Set<String> _warmedScopes = <String>{};
  final LinkedHashMap<String, void Function()> _deferredWarmups =
      LinkedHashMap<String, void Function()>();
  final Map<String, int> _actionTimestamps = <String, int>{};

  TimingsCallback? _timingsCallback;
  int _pressureHoldUntilMs = 0;
  int _lastChurnShedMs = 0;
  int _lastMetricsPublishedMs = 0;
  PerformancePressureLevel _appliedPressureLevel =
      PerformancePressureLevel.normal;
  bool _disposed = false;

  bool shouldAllowAction(String key, {int? minIntervalMs}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    var interval = minIntervalMs ?? state.tabSwitchThrottleMs;
    if (_appliedPressureLevel == PerformancePressureLevel.critical &&
        interval < 280) {
      interval = 280;
    }
    final last = _actionTimestamps[key];
    if (last != null && now - last < interval) return false;
    _actionTimestamps[key] = now;
    return true;
  }

  void markRouteVisible(String rawRoute) {
    final route = _normalizeRoute(rawRoute);
    final current = state.currentRoute;
    if (current == route) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    _routeSwitchesMs.addLast(now);
    _trimOldRouteSwitches(now);
    final navPressure = _routeSwitchesMs.length >= _navigationPressureSwitches;

    _updateState(navigationPressure: navPressure, currentRoute: route);
    _maybeShedCachesOnRouteChurn(nowMs: now, navPressure: navPressure);
    _warmScopeForRoute(route);
  }

  void _installFrameTimingListener() {
    _timingsCallback = (timings) {
      for (final frame in timings) {
        final buildMs = frame.buildDuration.inMicroseconds / 1000.0;
        final rasterMs = frame.rasterDuration.inMicroseconds / 1000.0;
        final totalMs = frame.totalSpan.inMicroseconds / 1000.0;

        _pushWindow(_buildMsWindow, buildMs);
        _pushWindow(_rasterMsWindow, rasterMs);
        _pushWindow(_jankWindow, totalMs > 16.7 ? 1 : 0);
      }

      if (_buildMsWindow.length < 24) return;

      final buildP95 = _percentile(_buildMsWindow, 0.95);
      final rasterP95 = _percentile(_rasterMsWindow, 0.95);
      final jankRatio =
          _jankWindow.fold<int>(0, (sum, bit) => sum + bit) /
          _jankWindow.length;

      final now = DateTime.now().millisecondsSinceEpoch;
      final signalLevel = _signalPressureLevel(
        navigationPressure: state.navigationPressure,
        jankRatio: jankRatio,
        buildP95Ms: buildP95,
        rasterP95Ms: rasterP95,
      );
      final shouldEscalate = signalLevel.index > _appliedPressureLevel.index;
      if (!shouldEscalate &&
          now - _lastMetricsPublishedMs < _metricsUpdateIntervalMs) {
        return;
      }
      _lastMetricsPublishedMs = now;

      _updateState(
        jankRatio: jankRatio,
        buildP95Ms: buildP95,
        rasterP95Ms: rasterP95,
      );
    };

    SchedulerBinding.instance.addTimingsCallback(_timingsCallback!);
  }

  void _updateState({
    bool? navigationPressure,
    double? jankRatio,
    double? buildP95Ms,
    double? rasterP95Ms,
    String? currentRoute,
    PerformancePressureLevel? forcedPressureLevel,
  }) {
    final nextNavPressure = navigationPressure ?? state.navigationPressure;
    final nextJankRatio = _quantize(jankRatio ?? state.jankRatio, 2);
    final nextBuildP95 = _quantize(buildP95Ms ?? state.buildP95Ms, 1);
    final nextRasterP95 = _quantize(rasterP95Ms ?? state.rasterP95Ms, 1);

    final nextLevel =
        forcedPressureLevel ??
        _resolvePressureLevel(
          navigationPressure: nextNavPressure,
          jankRatio: nextJankRatio,
          buildP95Ms: nextBuildP95,
          rasterP95Ms: nextRasterP95,
        );

    if (_appliedPressureLevel != nextLevel) {
      _configureImageCache(level: nextLevel);
      if (_appliedPressureLevel != PerformancePressureLevel.critical &&
          nextLevel == PerformancePressureLevel.critical) {
        _dropImageCacheLiveSet(clearMemory: false);
      }
      _appliedPressureLevel = nextLevel;
    }

    final profile = _profileForLevel(nextLevel);
    _applyRuntimeHints(profile);
    final next = state.copyWith(
      pressureLevel: nextLevel,
      highPressure: nextLevel != PerformancePressureLevel.normal,
      navigationPressure: nextNavPressure,
      jankRatio: nextJankRatio,
      buildP95Ms: nextBuildP95,
      rasterP95Ms: nextRasterP95,
      currentRoute: currentRoute,
      homePrecacheImageCount: profile.homePrecacheImageCount,
      homeScrollCacheExtent: profile.homeScrollCacheExtent,
      homeLoadMoreThrottleMs: profile.homeLoadMoreThrottleMs,
      homeLoadMoreTriggerExtent: profile.homeLoadMoreTriggerExtent,
      tabSwitchThrottleMs: profile.tabSwitchThrottleMs,
      allowDecorativeMotion: profile.allowDecorativeMotion,
      homeHeroItemsMax: profile.homeHeroItemsMax,
      homeTrendingItemsMax: profile.homeTrendingItemsMax,
      homePickedItemsMax: profile.homePickedItemsMax,
      hideNonEssentialHomeSections: profile.hideNonEssentialHomeSections,
      routeTransitionsEnabled: profile.routeTransitionsEnabled,
      imageDecodeMaxDimension: profile.imageDecodeMaxDimension,
      imageDecodeScalePercent: profile.imageDecodeScalePercent,
      imageFadeInMs: profile.imageFadeInMs,
      backgroundWarmupsEnabled: profile.backgroundWarmupsEnabled,
      maxWarmupsPerMinute: profile.maxWarmupsPerMinute,
    );

    _flushDeferredWarmups();
    _setStateSafely(next);
  }

  PerformancePressureLevel _resolvePressureLevel({
    required bool navigationPressure,
    required double jankRatio,
    required double buildP95Ms,
    required double rasterP95Ms,
  }) {
    final target = _signalPressureLevel(
      navigationPressure: navigationPressure,
      jankRatio: jankRatio,
      buildP95Ms: buildP95Ms,
      rasterP95Ms: rasterP95Ms,
    );
    final current = _appliedPressureLevel;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (target.index > current.index) {
      _pressureHoldUntilMs =
          now +
          (target == PerformancePressureLevel.critical
              ? _criticalHoldMs
              : _pressureHoldMs);
      return target;
    }

    if (target.index < current.index && now < _pressureHoldUntilMs) {
      return current;
    }

    if (target == current && current != PerformancePressureLevel.normal) {
      final stillUnderPressure =
          navigationPressure ||
          jankRatio >= _elevatedJankRatio ||
          buildP95Ms >= _elevatedP95Ms ||
          rasterP95Ms >= _elevatedP95Ms;
      if (stillUnderPressure) {
        _pressureHoldUntilMs =
            now +
            (current == PerformancePressureLevel.critical
                ? _criticalHoldMs
                : _pressureHoldMs);
      }
    }

    return target;
  }

  PerformancePressureLevel _signalPressureLevel({
    required bool navigationPressure,
    required double jankRatio,
    required double buildP95Ms,
    required double rasterP95Ms,
  }) {
    final elevatedFramePressure =
        jankRatio >= _elevatedJankRatio ||
        buildP95Ms >= _elevatedP95Ms ||
        rasterP95Ms >= _elevatedP95Ms;
    final criticalFramePressure =
        jankRatio >= _criticalJankRatio ||
        buildP95Ms >= _criticalP95Ms ||
        rasterP95Ms >= _criticalP95Ms;

    if (criticalFramePressure ||
        (navigationPressure && elevatedFramePressure)) {
      return PerformancePressureLevel.critical;
    }
    if (navigationPressure || elevatedFramePressure) {
      return PerformancePressureLevel.elevated;
    }
    return PerformancePressureLevel.normal;
  }

  void _setStateSafely(PerformanceEngineState next) {
    if (_equals(next, state)) return;
    final phase = SchedulerBinding.instance.schedulerPhase;
    final shouldDefer =
        phase == SchedulerPhase.transientCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks ||
        phase == SchedulerPhase.persistentCallbacks;
    if (shouldDefer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_disposed) return;
        if (_equals(next, state)) return;
        state = next;
      });
      return;
    }
    state = next;
  }

  _PerfProfile _profileForLevel(PerformancePressureLevel level) {
    return switch (level) {
      PerformancePressureLevel.normal => const _PerfProfile(
        imageCacheMaxEntries: 160,
        imageCacheMaxBytes: 96 * 1024 * 1024,
        homePrecacheImageCount: 2,
        homeScrollCacheExtent: 360,
        homeLoadMoreThrottleMs: 320,
        homeLoadMoreTriggerExtent: 620,
        tabSwitchThrottleMs: 64,
        allowDecorativeMotion: true,
        homeHeroItemsMax: 5,
        homeTrendingItemsMax: 10,
        homePickedItemsMax: 10,
        hideNonEssentialHomeSections: false,
        routeTransitionsEnabled: true,
        imageDecodeMaxDimension: 1080,
        imageDecodeScalePercent: 100,
        imageFadeInMs: 40,
        backgroundWarmupsEnabled: true,
        maxWarmupsPerMinute: 4,
      ),
      PerformancePressureLevel.elevated => const _PerfProfile(
        imageCacheMaxEntries: 96,
        imageCacheMaxBytes: 56 * 1024 * 1024,
        homePrecacheImageCount: 1,
        homeScrollCacheExtent: 220,
        homeLoadMoreThrottleMs: 720,
        homeLoadMoreTriggerExtent: 480,
        tabSwitchThrottleMs: 210,
        allowDecorativeMotion: false,
        homeHeroItemsMax: 3,
        homeTrendingItemsMax: 6,
        homePickedItemsMax: 6,
        hideNonEssentialHomeSections: false,
        routeTransitionsEnabled: false,
        imageDecodeMaxDimension: 900,
        imageDecodeScalePercent: 74,
        imageFadeInMs: 20,
        backgroundWarmupsEnabled: true,
        maxWarmupsPerMinute: 2,
      ),
      PerformancePressureLevel.critical => const _PerfProfile(
        imageCacheMaxEntries: 56,
        imageCacheMaxBytes: 34 * 1024 * 1024,
        homePrecacheImageCount: 0,
        homeScrollCacheExtent: 120,
        homeLoadMoreThrottleMs: 1100,
        homeLoadMoreTriggerExtent: 320,
        tabSwitchThrottleMs: 360,
        allowDecorativeMotion: false,
        homeHeroItemsMax: 2,
        homeTrendingItemsMax: 4,
        homePickedItemsMax: 4,
        hideNonEssentialHomeSections: true,
        routeTransitionsEnabled: false,
        imageDecodeMaxDimension: 680,
        imageDecodeScalePercent: 52,
        imageFadeInMs: 0,
        backgroundWarmupsEnabled: false,
        maxWarmupsPerMinute: 0,
      ),
    };
  }

  void _configureImageCache({required PerformancePressureLevel level}) {
    final imageCache = PaintingBinding.instance.imageCache;
    final profile = _profileForLevel(level);
    final targetSize = profile.imageCacheMaxEntries;
    final targetSizeBytes = profile.imageCacheMaxBytes;

    if (imageCache.maximumSize != targetSize) {
      imageCache.maximumSize = targetSize;
    }
    if (imageCache.maximumSizeBytes != targetSizeBytes) {
      imageCache.maximumSizeBytes = targetSizeBytes;
    }
  }

  void _dropImageCacheLiveSet({required bool clearMemory}) {
    final imageCache = PaintingBinding.instance.imageCache;
    if (clearMemory) {
      imageCache.clear();
    }
    imageCache.clearLiveImages();
  }

  void _applyRuntimeHints(_PerfProfile profile) {
    PerformanceRuntimeHints.applyProfile(
      decodeMaxDimension: profile.imageDecodeMaxDimension,
      decodeScalePercent: profile.imageDecodeScalePercent,
      fadeInMs: profile.imageFadeInMs,
      routeTransitionsEnabled: profile.routeTransitionsEnabled,
    );
  }

  @override
  void didHaveMemoryPressure() {
    _deferredWarmups.clear();
    _warmupStartedMs.clear();
    _dropImageCacheLiveSet(clearMemory: true);
    _pressureHoldUntilMs =
        DateTime.now().millisecondsSinceEpoch + _criticalHoldMs;
    _updateState(forcedPressureLevel: PerformancePressureLevel.critical);
  }

  void _warmScopeForRoute(String route) {
    if (route == '/' || route.startsWith('/product')) {
      _warmScope('home', () => _ref.read(homeViewModelProvider.notifier));
      return;
    }
    if (route.startsWith('/search')) {
      _warmScope('search', () => _ref.read(searchViewModelProvider.notifier));
      return;
    }
    if (route.startsWith('/offers')) {
      _warmScope('offers', () => _ref.read(offersViewModelProvider.notifier));
      return;
    }
    if (route.startsWith('/cart') || route.startsWith('/checkout')) {
      _warmScope('cart', () => _ref.read(cartViewModelProvider.notifier));
    }
  }

  void _maybeShedCachesOnRouteChurn({
    required int nowMs,
    required bool navPressure,
  }) {
    final churnCritical =
        _appliedPressureLevel == PerformancePressureLevel.critical;
    final churnElevated =
        _appliedPressureLevel == PerformancePressureLevel.elevated &&
        navPressure;
    if (!churnCritical && !churnElevated) {
      return;
    }
    if (nowMs - _lastChurnShedMs < _churnCacheShedCooldownMs) {
      return;
    }
    _lastChurnShedMs = nowMs;
    _dropImageCacheLiveSet(clearMemory: false);
  }

  void _warmScope(String key, void Function() action) {
    if (!_warmedScopes.add(key)) return;
    if (!_canStartWarmupNow()) {
      _deferredWarmups[key] = action;
      return;
    }
    _startWarmup(action);
  }

  bool _canStartWarmupNow() {
    final profile = _profileForLevel(_appliedPressureLevel);
    if (!profile.backgroundWarmupsEnabled) return false;
    if (profile.maxWarmupsPerMinute <= 0) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    _trimOldWarmups(now);
    return _warmupStartedMs.length < profile.maxWarmupsPerMinute;
  }

  void _startWarmup(void Function() action) {
    final now = DateTime.now().millisecondsSinceEpoch;
    _trimOldWarmups(now);
    _warmupStartedMs.addLast(now);
    Future<void>.microtask(() {
      if (_disposed) return;
      try {
        action();
      } catch (_) {}
    });
  }

  void _flushDeferredWarmups() {
    while (_deferredWarmups.isNotEmpty && _canStartWarmupNow()) {
      final first = _deferredWarmups.entries.first;
      _deferredWarmups.remove(first.key);
      _startWarmup(first.value);
    }
  }

  void _trimOldWarmups(int nowMs) {
    final lowerBound = nowMs - _warmupWindowMs;
    while (_warmupStartedMs.isNotEmpty && _warmupStartedMs.first < lowerBound) {
      _warmupStartedMs.removeFirst();
    }
  }

  void _trimOldRouteSwitches(int nowMs) {
    final lowerBound = nowMs - _navigationWindowMs;
    while (_routeSwitchesMs.isNotEmpty && _routeSwitchesMs.first < lowerBound) {
      _routeSwitchesMs.removeFirst();
    }
  }

  static String _normalizeRoute(String raw) {
    final route = raw.trim();
    if (route.isEmpty) return '/';
    if (!route.startsWith('/')) return '/$route';
    return route;
  }

  static void _pushWindow<T>(List<T> buffer, T value) {
    buffer.add(value);
    if (buffer.length > _frameWindowSize) {
      buffer.removeAt(0);
    }
  }

  static double _percentile(List<double> values, double percentile) {
    if (values.isEmpty) return 0;
    final sorted = List<double>.of(values)..sort();
    final index = ((sorted.length - 1) * percentile).round().clamp(
      0,
      sorted.length - 1,
    );
    return sorted[index];
  }

  static double _quantize(double value, int decimals) {
    final factor = switch (decimals) {
      0 => 1,
      1 => 10,
      2 => 100,
      3 => 1000,
      _ => 10000,
    };
    return (value * factor).roundToDouble() / factor;
  }

  static bool _equals(PerformanceEngineState a, PerformanceEngineState b) {
    return a.pressureLevel == b.pressureLevel &&
        a.highPressure == b.highPressure &&
        a.navigationPressure == b.navigationPressure &&
        a.jankRatio == b.jankRatio &&
        a.buildP95Ms == b.buildP95Ms &&
        a.rasterP95Ms == b.rasterP95Ms &&
        a.currentRoute == b.currentRoute &&
        a.homePrecacheImageCount == b.homePrecacheImageCount &&
        a.homeScrollCacheExtent == b.homeScrollCacheExtent &&
        a.homeLoadMoreThrottleMs == b.homeLoadMoreThrottleMs &&
        a.homeLoadMoreTriggerExtent == b.homeLoadMoreTriggerExtent &&
        a.tabSwitchThrottleMs == b.tabSwitchThrottleMs &&
        a.allowDecorativeMotion == b.allowDecorativeMotion &&
        a.homeHeroItemsMax == b.homeHeroItemsMax &&
        a.homeTrendingItemsMax == b.homeTrendingItemsMax &&
        a.homePickedItemsMax == b.homePickedItemsMax &&
        a.hideNonEssentialHomeSections == b.hideNonEssentialHomeSections &&
        a.routeTransitionsEnabled == b.routeTransitionsEnabled &&
        a.imageDecodeMaxDimension == b.imageDecodeMaxDimension &&
        a.imageDecodeScalePercent == b.imageDecodeScalePercent &&
        a.imageFadeInMs == b.imageFadeInMs &&
        a.backgroundWarmupsEnabled == b.backgroundWarmupsEnabled &&
        a.maxWarmupsPerMinute == b.maxWarmupsPerMinute;
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    final callback = _timingsCallback;
    if (callback != null) {
      SchedulerBinding.instance.removeTimingsCallback(callback);
    }
    super.dispose();
  }
}

class _PerfProfile {
  const _PerfProfile({
    required this.imageCacheMaxEntries,
    required this.imageCacheMaxBytes,
    required this.homePrecacheImageCount,
    required this.homeScrollCacheExtent,
    required this.homeLoadMoreThrottleMs,
    required this.homeLoadMoreTriggerExtent,
    required this.tabSwitchThrottleMs,
    required this.allowDecorativeMotion,
    required this.homeHeroItemsMax,
    required this.homeTrendingItemsMax,
    required this.homePickedItemsMax,
    required this.hideNonEssentialHomeSections,
    required this.routeTransitionsEnabled,
    required this.imageDecodeMaxDimension,
    required this.imageDecodeScalePercent,
    required this.imageFadeInMs,
    required this.backgroundWarmupsEnabled,
    required this.maxWarmupsPerMinute,
  });

  final int imageCacheMaxEntries;
  final int imageCacheMaxBytes;
  final int homePrecacheImageCount;
  final double homeScrollCacheExtent;
  final int homeLoadMoreThrottleMs;
  final double homeLoadMoreTriggerExtent;
  final int tabSwitchThrottleMs;
  final bool allowDecorativeMotion;
  final int homeHeroItemsMax;
  final int homeTrendingItemsMax;
  final int homePickedItemsMax;
  final bool hideNonEssentialHomeSections;
  final bool routeTransitionsEnabled;
  final int imageDecodeMaxDimension;
  final int imageDecodeScalePercent;
  final int imageFadeInMs;
  final bool backgroundWarmupsEnabled;
  final int maxWarmupsPerMinute;
}

class PerformanceRouteScope extends ConsumerStatefulWidget {
  const PerformanceRouteScope({
    super.key,
    required this.route,
    required this.child,
  });

  final String route;
  final Widget child;

  @override
  ConsumerState<PerformanceRouteScope> createState() =>
      _PerformanceRouteScopeState();
}

class _PerformanceRouteScopeState extends ConsumerState<PerformanceRouteScope> {
  @override
  void initState() {
    super.initState();
    _markRouteAfterFrame(widget.route);
  }

  @override
  void didUpdateWidget(covariant PerformanceRouteScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.route == widget.route) return;
    _markRouteAfterFrame(widget.route);
  }

  void _markRouteAfterFrame(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _markRoute(route);
    });
  }

  void _markRoute(String route) {
    ref.read(performanceEngineProvider.notifier).markRouteVisible(route);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: widget.child);
  }
}
