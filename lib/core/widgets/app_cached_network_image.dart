import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/perf/performance_runtime_hints.dart';

class AppCachedNetworkImage extends StatelessWidget {
  const AppCachedNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment,
    this.borderRadius,
    this.memCacheWidth,
    this.memCacheHeight,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    this.backgroundColor,
    this.fallbackUrl,
    this.filterQuality = FilterQuality.low,
    this.fadeInDuration = Duration.zero,
    this.fadeOutDuration = Duration.zero,
    this.useOldImageOnUrlChange = true,
    this.cacheKey,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry? alignment;
  final BorderRadius? borderRadius;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;
  final Color? backgroundColor;
  final String? fallbackUrl;
  final FilterQuality filterQuality;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final bool useOldImageOnUrlChange;
  final String? cacheKey;

  static const Set<String> _trackingParams = <String>{
    'fbclid',
    'gclid',
    'dclid',
    'mc_cid',
    'mc_eid',
    '_branch_match_id',
  };

  static int? _autoCacheDimension(double logical, double dpr) {
    if (!logical.isFinite || logical <= 0) return null;
    final px = (logical * dpr).round();
    if (px <= 0) return null;
    return _sanitizeCacheDimension(px);
  }

  static int? _sanitizeCacheDimension(int? px) {
    if (px == null || px <= 0) return null;
    return px.clamp(32, 2048);
  }

  static int? _applyRuntimeDecodeHints(int? px) {
    final sanitized = _sanitizeCacheDimension(px);
    if (sanitized == null) return null;

    final scale = (PerformanceRuntimeHints.imageDecodeScalePercent.value / 100)
        .clamp(0.45, 1.0);
    final maxDimension = PerformanceRuntimeHints.imageDecodeMaxDimension.value
        .clamp(320, 2400);
    final scaled = (sanitized * scale).round();
    return scaled.clamp(32, maxDimension);
  }

  static String _normalizeUrl(String? raw) {
    var value = (raw ?? '').trim();
    if (value.isEmpty) return '';
    if (value.startsWith('//')) {
      value = 'https:$value';
    } else if (!value.contains('://') && value.startsWith('www.')) {
      value = 'https://$value';
    }

    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) return value;

    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    final keepPort =
        uri.hasPort &&
        !((scheme == 'https' && uri.port == 443) ||
            (scheme == 'http' && uri.port == 80));
    return Uri(
      scheme: scheme,
      userInfo: uri.userInfo.isEmpty ? null : uri.userInfo,
      host: host,
      port: keepPort ? uri.port : 0,
      path: uri.path.isEmpty ? '/' : uri.path,
      query: uri.hasQuery ? uri.query : null,
    ).toString();
  }

  static bool _isValidNetworkUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    if (!uri.hasAuthority || uri.host.trim().isEmpty) return false;
    final scheme = uri.scheme.toLowerCase();
    return scheme == 'https' || scheme == 'http';
  }

  static bool _isAssetPath(String value) {
    final normalized = value.trim();
    return normalized.startsWith('assets/');
  }

  static String _canonicalCacheKey(String url) {
    final normalized = _normalizeUrl(url);
    final uri = Uri.tryParse(normalized);
    if (uri == null) return normalized;

    final entries = <MapEntry<String, String>>[];
    uri.queryParametersAll.forEach((rawKey, values) {
      final key = rawKey.trim();
      if (key.isEmpty) return;
      final lower = key.toLowerCase();
      if (lower.startsWith('utm_') || _trackingParams.contains(lower)) return;

      if (values.isEmpty) {
        entries.add(MapEntry(key, ''));
      } else {
        for (final value in values) {
          entries.add(MapEntry(key, value));
        }
      }
    });

    entries.sort((a, b) {
      final keyCmp = a.key.toLowerCase().compareTo(b.key.toLowerCase());
      if (keyCmp != 0) return keyCmp;
      return a.value.compareTo(b.value);
    });

    final query = entries
        .map(
          (entry) =>
              '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}',
        )
        .join('&');

    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    final keepPort =
        uri.hasPort &&
        !((scheme == 'https' && uri.port == 443) ||
            (scheme == 'http' && uri.port == 80));

    return Uri(
      scheme: scheme,
      userInfo: uri.userInfo.isEmpty ? null : uri.userInfo,
      host: host,
      port: keepPort ? uri.port : 0,
      path: uri.path.isEmpty ? '/' : uri.path,
      query: query.isEmpty ? null : query,
    ).toString();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? cs.surfaceContainerHigh;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final iconScale = switch (fit) {
      BoxFit.cover => 0.34,
      BoxFit.fill => 0.34,
      BoxFit.contain => 0.26,
      _ => 0.30,
    };
    final resolvedAlignment = alignment is Alignment
        ? alignment as Alignment
        : Alignment.center;

    Widget buildResolvedImage({
      required double logicalWidth,
      required double logicalHeight,
    }) {
      final shortestSide = logicalWidth < logicalHeight
          ? logicalWidth
          : logicalHeight;
      final iconSize = (shortestSide * iconScale).clamp(18.0, 48.0).toDouble();

      final placeholder = ColoredBox(
        color: bg,
        child: Align(
          alignment: alignment ?? Alignment.center,
          child: Icon(
            Icons.image_outlined,
            size: iconSize,
            color: cs.onSurface.withValues(alpha: 0.36),
          ),
        ),
      );

      final rawPrimary = url.trim();
      final rawFallback = (fallbackUrl ?? '').trim();
      final primaryAsset = _isAssetPath(rawPrimary) ? rawPrimary : '';
      final fallbackAsset = _isAssetPath(rawFallback) ? rawFallback : '';
      final primary = _normalizeUrl(rawPrimary);
      final fallback = _normalizeUrl(rawFallback);
      final validPrimary = _isValidNetworkUrl(primary) ? primary : '';
      final validFallback = _isValidNetworkUrl(fallback) ? fallback : '';
      final resolvedUrl = validPrimary.isNotEmpty
          ? validPrimary
          : validFallback;

      final resolvedMemWidth = _applyRuntimeDecodeHints(
        _sanitizeCacheDimension(memCacheWidth) ??
            _autoCacheDimension(logicalWidth, dpr),
      );
      final resolvedMemHeight = _applyRuntimeDecodeHints(
        _sanitizeCacheDimension(memCacheHeight) ??
            _autoCacheDimension(logicalHeight, dpr),
      );
      final resolvedDiskWidth = _applyRuntimeDecodeHints(
        _sanitizeCacheDimension(maxWidthDiskCache) ?? resolvedMemWidth,
      );
      final resolvedDiskHeight = _applyRuntimeDecodeHints(
        _sanitizeCacheDimension(maxHeightDiskCache) ?? resolvedMemHeight,
      );

      Widget buildAssetImage(String assetPath, {String? altAssetPath}) {
        return Image.asset(
          assetPath,
          fit: fit,
          alignment: resolvedAlignment,
          filterQuality: filterQuality,
          cacheWidth: resolvedMemWidth,
          cacheHeight: resolvedMemHeight,
          errorBuilder: (_, __, ___) {
            if (altAssetPath != null &&
                altAssetPath.trim().isNotEmpty &&
                altAssetPath != assetPath) {
              return buildAssetImage(altAssetPath);
            }
            return placeholder;
          },
        );
      }

      if (primaryAsset.isNotEmpty) {
        return buildAssetImage(
          primaryAsset,
          altAssetPath: fallbackAsset.isNotEmpty ? fallbackAsset : null,
        );
      }

      if (resolvedUrl.isEmpty) {
        if (fallbackAsset.isNotEmpty) {
          return buildAssetImage(fallbackAsset);
        }
        return placeholder;
      }

      Widget buildImage(String imageUrl, {required bool allowFallback}) {
        final resolvedCacheKey = cacheKey ?? _canonicalCacheKey(imageUrl);
        return CachedNetworkImage(
          imageUrl: imageUrl,
          cacheKey: resolvedCacheKey,
          fit: fit,
          alignment: resolvedAlignment,
          memCacheWidth: resolvedMemWidth,
          memCacheHeight: resolvedMemHeight,
          maxWidthDiskCache: resolvedDiskWidth,
          maxHeightDiskCache: resolvedDiskHeight,
          filterQuality: filterQuality,
          fadeInDuration: fadeInDuration,
          fadeOutDuration: fadeOutDuration,
          useOldImageOnUrlChange: useOldImageOnUrlChange,
          placeholder: (_, __) => placeholder,
          errorWidget: (_, __, ___) {
            if (allowFallback &&
                validFallback.isNotEmpty &&
                validFallback != imageUrl) {
              return buildImage(validFallback, allowFallback: false);
            }
            if (allowFallback && fallbackAsset.isNotEmpty) {
              return buildAssetImage(fallbackAsset);
            }
            return placeholder;
          },
        );
      }

      return buildImage(resolvedUrl, allowFallback: true);
    }

    final canSkipLayoutBuilder =
        (width != null && height != null) ||
        (memCacheWidth != null && memCacheHeight != null);

    Widget image;
    if (canSkipLayoutBuilder) {
      final logicalWidth = width ?? (memCacheWidth! / dpr);
      final logicalHeight = height ?? (memCacheHeight! / dpr);
      image = buildResolvedImage(
        logicalWidth: logicalWidth,
        logicalHeight: logicalHeight,
      );
    } else {
      image = LayoutBuilder(
        builder: (context, constraints) {
          final logicalWidth = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : (width ?? 120.0);
          final logicalHeight = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : (height ?? 120.0);
          return buildResolvedImage(
            logicalWidth: logicalWidth,
            logicalHeight: logicalHeight,
          );
        },
      );
    }

    if (width != null || height != null) {
      image = SizedBox(width: width, height: height, child: image);
    }

    final br = borderRadius;
    if (br == null) return image;
    return ClipRRect(borderRadius: br, child: image);
  }
}
