import 'package:flutter/painting.dart';

class NovaImageCacheBudget {
  const NovaImageCacheBudget._();

  // Tuned to keep grid thumbnails warm while allowing a few details images.
  static const int defaultMaximumEntries = 240;
  static const int defaultMaximumSizeBytes = 120 * 1024 * 1024;

  static bool _applied = false;

  static void applyDefaults() {
    if (_applied) return;
    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSize = defaultMaximumEntries;
    cache.maximumSizeBytes = defaultMaximumSizeBytes;
    _applied = true;
  }
}
