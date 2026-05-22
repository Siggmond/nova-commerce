import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';

class PerfRouteScreen extends StatelessWidget {
  const PerfRouteScreen({super.key});

  static const String _demoQuery = 'hoodie';
  static const String _demoProductId = 'p1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perf')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Perf route'),
            subtitle: Text(
              'Quick navigation targets for profiling. This route is only registered in debug/profile builds.',
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Open Home feed (HomeV2)'),
            onTap: () => context.go(AppRoutes.home),
          ),
          ListTile(
            title: const Text('Open Search results'),
            subtitle: const Text('Query: "hoodie"'),
            onTap: () => context.go('${AppRoutes.search}?q=$_demoQuery'),
          ),
          ListTile(
            title: const Text('Open Product details'),
            subtitle: const Text('Product id: p1'),
            onTap: () => context.go('${AppRoutes.product}?id=$_demoProductId'),
          ),
        ],
      ),
    );
  }
}
