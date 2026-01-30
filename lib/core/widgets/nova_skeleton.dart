import 'package:flutter/material.dart';

import 'shimmer.dart';

class NovaSkeleton extends StatelessWidget {
  const NovaSkeleton({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer(child: child);
  }
}

class NovaSkeletonBox extends StatelessWidget {
  const NovaSkeletonBox({super.key, required this.height, this.radius});

  final double height;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(height: height, radius: radius);
  }
}
