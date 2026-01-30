class HomeNavItem {
  const HomeNavItem({
    required this.id,
    required this.title,
    required this.deeplink,
    required this.order,
    this.enabled = true,
  });

  final String id;
  final String title;
  final String deeplink;
  final int order;
  final bool enabled;

  static HomeNavItem? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final id = (raw['id'] as String?)?.trim() ?? '';
    final title = (raw['title'] as String?)?.trim() ?? '';
    final deeplink = (raw['deeplink'] as String?)?.trim() ?? '';
    final order = raw['order'] is int ? raw['order'] as int : 0;
    final enabled = raw['enabled'] is bool ? raw['enabled'] as bool : true;
    if (id.isEmpty || title.isEmpty || deeplink.isEmpty) return null;
    if (!enabled) return null;
    return HomeNavItem(
      id: id,
      title: title,
      deeplink: deeplink,
      order: order,
      enabled: enabled,
    );
  }
}

class HomeSuperDealsConfig {
  const HomeSuperDealsConfig({required this.limit, required this.mode});

  final int limit;
  final String mode;

  static const defaults = HomeSuperDealsConfig(limit: 12, mode: 'default');

  static HomeSuperDealsConfig fromMap(Object? raw) {
    if (raw is! Map) return defaults;
    final limit = raw['limit'] is int ? raw['limit'] as int : defaults.limit;
    final mode = (raw['mode'] as String?)?.trim();
    return HomeSuperDealsConfig(
      limit: limit,
      mode: (mode == null || mode.isEmpty) ? defaults.mode : mode,
    );
  }
}

class HomeConfig {
  const HomeConfig({
    required this.quickSquares,
    required this.catalog,
    required this.styles,
    required this.superDeals,
  });

  final List<HomeNavItem> quickSquares;
  final List<HomeNavItem> catalog;
  final List<HomeNavItem> styles;
  final HomeSuperDealsConfig superDeals;

  static const defaults = HomeConfig(
    quickSquares: [
      HomeNavItem(id: 'browse', title: 'Browse', deeplink: '/browse', order: 1),
    ],
    catalog: [
      HomeNavItem(id: 'new', title: 'New In', deeplink: '/new-in', order: 1),
    ],
    styles: [
      HomeNavItem(id: 'style', title: 'Styles', deeplink: '/styles', order: 1),
    ],
    superDeals: HomeSuperDealsConfig.defaults,
  );

  static HomeConfig fromMap(Map<String, dynamic>? map) {
    if (map == null) return defaults;

    List<HomeNavItem> parseList(Object? raw, List<HomeNavItem> fallback) {
      if (raw is! List) return fallback;
      final parsed = raw
          .map(HomeNavItem.fromMap)
          .whereType<HomeNavItem>()
          .toList(growable: true);
      if (parsed.isEmpty) return fallback;
      parsed.sort((a, b) => a.order.compareTo(b.order));
      return parsed;
    }

    final quickSquares = parseList(map['quickSquares'], defaults.quickSquares);
    final catalog = parseList(map['catalog'], defaults.catalog);
    final styles = parseList(map['styles'], defaults.styles);
    final superDeals = HomeSuperDealsConfig.fromMap(map['superDeals']);

    return HomeConfig(
      quickSquares: quickSquares,
      catalog: catalog,
      styles: styles,
      superDeals: superDeals,
    );
  }
}
