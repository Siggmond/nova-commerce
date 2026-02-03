import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_v2_feed.dart';

class HomeV2Screen extends ConsumerWidget {
  const HomeV2Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(body: const HomeV2Feed());
  }
}
