import 'package:flutter/foundation.dart';

class PerformanceRuntimeHints {
  PerformanceRuntimeHints._();

  static final ValueNotifier<int> imageDecodeMaxDimension = ValueNotifier<int>(
    1600,
  );

  static final ValueNotifier<int> imageDecodeScalePercent = ValueNotifier<int>(
    100,
  );

  static final ValueNotifier<int> imageFadeInMs = ValueNotifier<int>(120);

  static final ValueNotifier<bool> allowRouteTransitions = ValueNotifier<bool>(
    true,
  );

  static void applyProfile({
    required int decodeMaxDimension,
    required int decodeScalePercent,
    required int fadeInMs,
    required bool routeTransitionsEnabled,
  }) {
    final safeDecode = decodeMaxDimension.clamp(320, 2400);
    final safeScale = decodeScalePercent.clamp(45, 100);
    final safeFade = fadeInMs.clamp(0, 220);

    if (imageDecodeMaxDimension.value != safeDecode) {
      imageDecodeMaxDimension.value = safeDecode;
    }
    if (imageDecodeScalePercent.value != safeScale) {
      imageDecodeScalePercent.value = safeScale;
    }
    if (imageFadeInMs.value != safeFade) {
      imageFadeInMs.value = safeFade;
    }
    if (allowRouteTransitions.value != routeTransitionsEnabled) {
      allowRouteTransitions.value = routeTransitionsEnabled;
    }
  }
}
