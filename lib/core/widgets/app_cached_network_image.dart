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
    this.backgroundColor,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? cs.surfaceContainerHigh;
    final br = borderRadius;

    Widget placeholder() {
      return ColoredBox(color: bg);
    }

    Widget error() {
      return ColoredBox(
        color: bg,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: cs.onSurface.withValues(alpha: 0.55),
          ),
        ),
      );
    }

    final image = url.trim().isEmpty
        ? error()
        : CachedNetworkImage(
            imageUrl: url,
            width: width,
            height: height,
            fit: fit,
            fadeInDuration: const Duration(milliseconds: 120),
            placeholder: (context, _) => placeholder(),
            errorWidget: (context, _, __) => error(),
            memCacheWidth: memCacheWidth,
            memCacheHeight: memCacheHeight,
          );

    if (br == null) return image;

    return ClipRRect(borderRadius: br, child: image);
  }
}
