import 'package:flutter/material.dart';

class ResponsiveGridDelegate {
  const ResponsiveGridDelegate._();

  static int crossAxisCountForWidth(double width) {
    if (width < 360) return 2;
    if (width < 480) return 3;
    if (width < 720) return 4;
    if (width < 920) return 5;
    return 6;
  }

  static int browseCrossAxisCountForWidth(double width) {
    if (width < 360) return 2;
    if (width < 480) return 2;
    if (width < 720) return 3;
    if (width < 920) return 4;
    return 5;
  }

  static SliverGridDelegate sliverGridDelegate({
    required double width,
    required double spacing,
    required double tileHeight,
  }) {
    final count = crossAxisCountForWidth(width);
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: count,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      mainAxisExtent: tileHeight,
    );
  }

  static SliverGridDelegate browseSliverGridDelegate({
    required double width,
    required double spacing,
    required double tileHeight,
  }) {
    final count = browseCrossAxisCountForWidth(width);
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: count,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      mainAxisExtent: tileHeight,
    );
  }

  static int maxVisibleItems({required double width, required int maxRows}) {
    final count = crossAxisCountForWidth(width);
    return count * maxRows;
  }
}
