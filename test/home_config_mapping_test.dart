import 'package:flutter_test/flutter_test.dart';

import 'package:nova_commerce/domain/entities/home_config.dart';

void main() {
  test('HomeConfig.fromMap falls back to defaults when input is null', () {
    final c = HomeConfig.fromMap(null);

    expect(c.quickSquares.length, HomeConfig.defaults.quickSquares.length);
    expect(c.catalog.length, HomeConfig.defaults.catalog.length);
    expect(c.styles.length, HomeConfig.defaults.styles.length);
    expect(c.superDeals.limit, HomeSuperDealsConfig.defaults.limit);
    expect(c.superDeals.mode, HomeSuperDealsConfig.defaults.mode);
  });

  test('HomeConfig.fromMap filters invalid entries and sorts by order', () {
    final c = HomeConfig.fromMap({
      'quickSquares': [
        {
          'id': 'x',
          'title': 'X',
          'deeplink': '/x',
          'order': 2,
          'enabled': false,
        },
        {
          'id': 'y',
          'title': 'Y',
          'deeplink': '/y',
          'order': 1,
        },
        {
          'id': '',
          'title': 'Bad',
          'deeplink': '/bad',
          'order': 0,
        },
      ],
      'catalog': [],
      'styles': [
        {
          'id': 's2',
          'title': 'Style 2',
          'deeplink': '/s2',
          'order': 2,
        },
        {
          'id': 's1',
          'title': 'Style 1',
          'deeplink': '/s1',
          'order': 1,
        },
        {'bad': true},
      ],
      'superDeals': {
        'limit': 5,
      },
    });

    expect(c.quickSquares.length, 1);
    expect(c.quickSquares.first.id, 'y');

    expect(c.catalog.length, HomeConfig.defaults.catalog.length);

    expect(c.styles.map((e) => e.id).toList(growable: false), ['s1', 's2']);

    expect(c.superDeals.limit, 5);
    expect(c.superDeals.mode, HomeSuperDealsConfig.defaults.mode);
  });
}
