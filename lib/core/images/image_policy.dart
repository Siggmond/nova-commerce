import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

enum NovaImageRoute { productsGrid, productDetails, generic }

class NovaImageCachePolicy {
  const NovaImageCachePolicy({
    required this.memCacheWidth,
    required this.memCacheHeight,
    required this.maxWidthDiskCache,
    required this.maxHeightDiskCache,
  });

  final int? memCacheWidth;
  final int? memCacheHeight;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;
}

class NovaImagePolicy {
  const NovaImagePolicy._();

  static const int _productsGridMaxLogicalPx = 384;
  static const int _productDetailsMaxLogicalPx = 760;
  static const int _genericMaxLogicalPx = 640;

  static const int _productsGridPrefetchCount = 8;
  static const int _productDetailsPrefetchCount = 1;
  static const bool clearLargeDetailsImagesOnPop = bool.fromEnvironment(
    'NOVA_CLEAR_DETAILS_IMAGES_ON_POP',
    defaultValue: false,
  );

  static int decodeCapLogicalPx(NovaImageRoute route) {
    return switch (route) {
      NovaImageRoute.productsGrid => _productsGridMaxLogicalPx,
      NovaImageRoute.productDetails => _productDetailsMaxLogicalPx,
      NovaImageRoute.generic => _genericMaxLogicalPx,
    };
  }

  static int prefetchCountForRoute(NovaImageRoute route) {
    return switch (route) {
      NovaImageRoute.productsGrid => _productsGridPrefetchCount,
      NovaImageRoute.productDetails => _productDetailsPrefetchCount,
      NovaImageRoute.generic => 0,
    };
  }

  static int? _sanitizePx(int value) {
    if (value <= 0) return null;
    return value.clamp(32, 4096);
  }

  static int? _resolveCacheDimensionPx({
    required double logicalDimension,
    required double devicePixelRatio,
    required NovaImageRoute route,
  }) {
    if (!logicalDimension.isFinite || logicalDimension <= 0) return null;
    final logicalCap = decodeCapLogicalPx(route).toDouble();
    final boundedLogical = logicalDimension.clamp(1.0, logicalCap);
    final px = (boundedLogical * devicePixelRatio).round();
    return _sanitizePx(px);
  }

  static NovaImageCachePolicy cachePolicyForLayout({
    required double logicalWidth,
    required double logicalHeight,
    required double devicePixelRatio,
    required NovaImageRoute route,
  }) {
    final memWidth = _resolveCacheDimensionPx(
      logicalDimension: logicalWidth,
      devicePixelRatio: devicePixelRatio,
      route: route,
    );
    final memHeight = _resolveCacheDimensionPx(
      logicalDimension: logicalHeight,
      devicePixelRatio: devicePixelRatio,
      route: route,
    );

    return NovaImageCachePolicy(
      memCacheWidth: memWidth,
      memCacheHeight: memHeight,
      maxWidthDiskCache: memWidth,
      maxHeightDiskCache: memHeight,
    );
  }

  static String normalizeNetworkUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('//')) return 'https:$trimmed';
    return trimmed;
  }

  static Future<void> prefetchRouteImages({
    required BuildContext context,
    required Iterable<String> urls,
    required NovaImageRoute route,
    required double logicalWidth,
    required double logicalHeight,
    int? maxItems,
  }) async {
    final routeLimit = prefetchCountForRoute(route);
    if (routeLimit <= 0) return;

    final requested = maxItems ?? routeLimit;
    final limit = requested.clamp(0, routeLimit);
    if (limit <= 0) return;

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final policy = cachePolicyForLayout(
      logicalWidth: logicalWidth,
      logicalHeight: logicalHeight,
      devicePixelRatio: dpr,
      route: route,
    );

    var prefetched = 0;
    for (final raw in urls) {
      if (prefetched >= limit) break;

      final url = normalizeNetworkUrl(raw);
      if (url.isEmpty) continue;

      final provider = ResizeImage.resizeIfNeeded(
        policy.memCacheWidth,
        policy.memCacheHeight,
        CachedNetworkImageProvider(url),
      );

      try {
        await precacheImage(provider, context);
      } catch (_) {
        // Ignore prefetch failures to avoid impacting user-visible flow.
      }

      prefetched += 1;
    }
  }

  static Future<void> maybeEvictDetailsImagesOnPop({
    required Iterable<String> urls,
  }) async {
    if (!clearLargeDetailsImagesOnPop) return;

    for (final raw in urls) {
      final url = normalizeNetworkUrl(raw);
      if (url.isEmpty) continue;
      final provider = CachedNetworkImageProvider(url);
      try {
        await provider.evict();
      } catch (_) {
        // Best-effort memory relief only.
      }
    }
  }
}
