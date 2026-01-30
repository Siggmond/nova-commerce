import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppCachedNetworkImage extends StatelessWidget {
  const AppCachedNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.memCacheWidth,
    this.memCacheHeight,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    this.backgroundColor,
    this.fallbackUrl,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;
  final Color? backgroundColor;
  final String? fallbackUrl;

  static const String _defaultFallbackUrl =
      'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=900&q=70';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? cs.surfaceContainerHigh;
    final br = borderRadius;

    String normalizeUrl(String raw) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return '';
      if (trimmed.startsWith('https://')) return trimmed;
      if (trimmed.startsWith('http://')) {
        return 'https://${trimmed.substring(7)}';
      }
      if (trimmed.startsWith('//')) return 'https:$trimmed';
      if (trimmed.startsWith('www.')) return 'https://$trimmed';
      final uri = Uri.tryParse(trimmed);
      if (uri == null || uri.host.isEmpty) return '';
      return trimmed;
    }

    final normalizedUrl = normalizeUrl(url);

    Widget placeholder() {
      return ColoredBox(color: bg);
    }

    Widget error() {
      final fallback = normalizeUrl(fallbackUrl ?? _defaultFallbackUrl);
      if (fallback.isNotEmpty && fallback != normalizedUrl) {
        return CachedNetworkImage(
          imageUrl: fallback,
          width: width,
          height: height,
          fit: fit,
          fadeInDuration: const Duration(milliseconds: 120),
          placeholder: (context, _) => placeholder(),
          errorWidget: (context, _, __) => ColoredBox(color: bg),
        );
      }

      return ColoredBox(color: bg);
    }

    final image = normalizedUrl.isEmpty
        ? error()
        : CachedNetworkImage(
            imageUrl: normalizedUrl,
            width: width,
            height: height,
            fit: fit,
            fadeInDuration: const Duration(milliseconds: 120),
            placeholder: (context, _) => placeholder(),
            errorWidget: (context, _, __) => error(),
            memCacheWidth: memCacheWidth,
            memCacheHeight: memCacheHeight,
            maxWidthDiskCache: maxWidthDiskCache ?? memCacheWidth,
            maxHeightDiskCache: maxHeightDiskCache ?? memCacheHeight,
          );

    if (br == null) return image;

    return ClipRRect(borderRadius: br, child: image);
  }
}
