import 'package:flutter/material.dart';

import 'package:nova_commerce/core/images/image_policy.dart';
import 'package:nova_commerce/core/widgets/app_cached_network_image.dart';

class NovaImage extends StatelessWidget {
  const NovaImage({
    super.key,
    required this.url,
    this.route = NovaImageRoute.generic,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment,
    this.borderRadius,
    this.backgroundColor,
    this.fallbackUrl,
    this.filterQuality = FilterQuality.low,
    this.fadeInDuration = Duration.zero,
    this.fadeOutDuration = Duration.zero,
    this.useOldImageOnUrlChange = true,
    this.cacheKey,
    this.logicalDecodeWidth,
    this.logicalDecodeHeight,
  });

  final String url;
  final NovaImageRoute route;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry? alignment;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final String? fallbackUrl;
  final FilterQuality filterQuality;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final bool useOldImageOnUrlChange;
  final String? cacheKey;
  final double? logicalDecodeWidth;
  final double? logicalDecodeHeight;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);

    AppCachedNetworkImage buildResolved({
      required double logicalWidth,
      required double logicalHeight,
    }) {
      final policy = NovaImagePolicy.cachePolicyForLayout(
        logicalWidth: logicalWidth,
        logicalHeight: logicalHeight,
        devicePixelRatio: dpr,
        route: route,
      );

      return AppCachedNetworkImage(
        url: url,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        borderRadius: borderRadius,
        memCacheWidth: policy.memCacheWidth,
        memCacheHeight: policy.memCacheHeight,
        maxWidthDiskCache: policy.maxWidthDiskCache,
        maxHeightDiskCache: policy.maxHeightDiskCache,
        backgroundColor: backgroundColor,
        fallbackUrl: fallbackUrl,
        filterQuality: filterQuality,
        fadeInDuration: fadeInDuration,
        fadeOutDuration: fadeOutDuration,
        useOldImageOnUrlChange: useOldImageOnUrlChange,
        cacheKey: cacheKey,
      );
    }

    final hintedWidth = logicalDecodeWidth ?? width;
    final hintedHeight = logicalDecodeHeight ?? height;
    if (hintedWidth != null &&
        hintedHeight != null &&
        hintedWidth > 0 &&
        hintedHeight > 0) {
      return buildResolved(
        logicalWidth: hintedWidth,
        logicalHeight: hintedHeight,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final logicalWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : (hintedWidth ?? 120.0);
        final logicalHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : (hintedHeight ?? 120.0);

        return buildResolved(
          logicalWidth: logicalWidth,
          logicalHeight: logicalHeight,
        );
      },
    );
  }
}
